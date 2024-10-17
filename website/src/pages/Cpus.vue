<template>
    <el-container style="height: 100%;" v-loading="loading">
        <el-header v-loading="headerLoading" :element-loading-text="headerLoadingText" class="control-header">
            <el-card class="control-card" shadow="hover">
                <div class="control-bar">
                    <span>最近更新时间: {{ lastCpuUpdate }}</span>
                    <el-button type="primary" @click="getCpuList">获取CPU信息</el-button>
                </div>
            </el-card>
        </el-header>
        <el-main style="width: 100%;">
            <el-row :gutter="20" style="height: 100%; width: 100%;">
                <el-col :span="6" style="height: 100%;">
                    <el-card class="box-card">
                        <el-menu default-active="0" @select="handleCpuSelect">
                            <el-menu-item v-for="(cpu, index) in cpuList" :key="index" :index="index.toString()">
                                <template #default>
                                    <div class="cpu-row">
                                        <div class="cpu-info">
                                            <div class="ellipsis">{{ cpu.name }}</div>
                                            <h1>状态:
                                                <el-tag v-if="cpu.busy" type="warning" effect="light">繁忙</el-tag>
                                                <el-tag v-else type="success" effect="light">空闲</el-tag>
                                            </h1>
                                            <h1>可存储: {{ cpu.storage / 1024 }} KB</h1>
                                            <h1>并行: {{ cpu.coprocessors }}</h1>
                                        </div>
                                        <div class="cpu-output">
                                            <img v-if="cpu.output.image" :src="cpu.output.image" alt="output"
                                                class="output-image" />
                                        </div>
                                    </div>
                                </template>
                            </el-menu-item>
                        </el-menu>
                    </el-card>
                </el-col>

                <el-col :span="18" style="height: 100%;">
                    <el-card class="box-card">
                        <el-row :gutter="20">
                            <el-col v-for="(item, index) in currentCpu.items" :key="index" :span="8">
                                <el-card :class="'item-card ' + getItemCardClass(item)" shadow="hover">
                                    <div class="image-wrapper">
                                        <img :src="item.image || ''" class="component-image" />
                                        <div class="item-info">
                                            <div class="ellipsis" style="font-size: 20px;">{{ item.label }}</div>
                                            <div v-if="item.active">正在合成: {{ item.active }}</div>
                                            <div v-if="item.pending">计划合成: {{ item.pending }}</div>
                                            <div v-if="item.stored">现存: {{ item.stored }}</div>
                                        </div>
                                    </div>
                                </el-card>
                            </el-col>
                        </el-row>
                    </el-card>
                </el-col>
            </el-row>
        </el-main>

    </el-container>
</template>

<script>
import { fetchStatus, addTask, createPollingController } from '@/utils/task'
import itemUtil from "@/utils/items";

export default {
    name: 'Cpus',
    data() {
        return {
            loading: true,
            headerLoading: false,
            headerLoadingText: "请求已发送，等待客户端响应... Task id: getCpuDetailList",
            lastCpuUpdate: "",
            cpuList: [],
            currentCpu: { items: [] },
            pollingController: null,
        };
    },
    created() {
    },
    mounted() {
        this.startPolling("getCpuDetailList");
    },
    methods: {
        handleCpuSelect(index) {
            this.currentCpu = this.cpuList[index];
        },
        getItemCardClass(item) {
            if (item.active) {
                return 'active-card';
            } else if (item.pending) {
                return 'pending-card';
            } else if (item.stored) {
                return 'stored-card';
            } else {
                return '';
            }
        },
        startPolling(taskId) {
            this.pollingController = createPollingController();
            fetchStatus(taskId, this.handleTaskResult, 1000, this.pollingController);
        },
        stopPolling() {
            if (this.pollingController) {
                this.pollingController.stop();
                console.log('Polling stopped.');
            }
        },
        parseItemStack(data) {
            const itemMap = new Map();

            // 处理 activeItems
            data.activeItems.forEach(item => {
                const key = `${item.name}:${item.damage}`;
                itemMap.set(key, {
                    label: itemUtil.getName(item),
                    active: item.size,
                    pending: 0,
                    stored: 0,
                    image: itemUtil.getIcon(item)
                });
            });

            // 处理 pendingItems
            data.pendingItems.forEach(item => {
                const key = `${item.name}:${item.damage}`;
                if (itemMap.has(key)) {
                    itemMap.get(key).pending = item.size;
                } else {
                    itemMap.set(key, {
                        label: itemUtil.getName(item),
                        active: 0,
                        pending: item.size,
                        stored: 0,
                        image: itemUtil.getIcon(item)
                    });
                }
            });

            // 处理 storedItems
            data.storedItems.forEach(item => {
                const key = `${item.name}:${item.damage}`;
                if (itemMap.has(key)) {
                    itemMap.get(key).stock = item.size;
                } else {
                    itemMap.set(key, {
                        label: itemUtil.getName(item),
                        active: 0,
                        pending: 0,
                        stored: item.size,
                        image: itemUtil.getIcon(item)
                    });
                }
            });

            return Array.from(itemMap.values());
        },
        handleTaskResult(data) {
            console.log('Task result:', data);
            this.loading = false;
            this.headerLoading = false;

            if (data.result) {
                try {
                    let result = JSON.parse(data.result[0]);
                    console.log(result);
                    
                    this.lastCpuUpdate = data.completed_time ? data.completed_time.split(".")[0].replace("T", " ") : '未知';

                    const previousCpuName = this.currentCpu?.name;
                    this.currentCpu = { name: undefined, items: [] };

                    let cpuList = [];
                    for (let cpu of result) {
                        let name = cpu.name !== "" ? cpu.name : `CPU #${cpuList.length + 1}`;
                        cpuList.push({
                            name: name,
                            busy: cpu.busy,
                            coprocessors: cpu.coprocessors,
                            storage: cpu.storage,
                            output: {},
                            items: this.parseItemStack(cpu.cpu),
                        });

                        if (previousCpuName && previousCpuName === name) {
                            this.currentCpu = cpuList[cpuList.length - 1];
                        }
                    }

                    if (!this.currentCpu.name) {
                        this.currentCpu = cpuList[0];
                    }

                    this.cpuList = cpuList;
                } catch (e) {
                    console.error(e, data);
                    this.$message.warning(e);
                }
            } else {
                this.$message.warning(`返回数据为空!`);
            }
        },
        getCpuList() {
            this.headerLoading = true;
            addTask("getCpuDetailList")
            this.startPolling("getCpuDetailList");
        }
    }
};
</script>

<style>
.box-card .el-card__body {
    padding: 16px;
}

.box-card .el-menu-item {
    padding-top: 4px;
    padding-bottom: 4px;
    line-height: 15px;
    height: auto;
    border: 1px solid var(--el-menu-border-color);
    border-radius: 5px;
    margin-bottom: 5px;
}

.box-card .el-menu-item.is-active {
    color: var(--el-menu-text-color);
    background-color: var(--el-color-primary-light-9);
}

.box-card .el-menu {
    border: none;
}

.item-card {
    height: 100px;
}

.item-card .el-card__body {
    height: 100%;
    padding: 8px;
}

.control-header {
    width: calc(100% - 20px);
    margin-top: 10px;
}

.control-header .el-card__body {
    height: 100%;
    padding: 8px;
}

.control-header .el-loading-spinner .circular {
    height: 24px;
    width: 24px;
}
</style>

<style scoped>
.el-container {
    height: 100%;
}

.control-card {
    padding: 10px;
    margin-bottom: 10px;
}

.control-bar {
    display: flex;
    justify-content: space-between;
    align-items: center;
}



.box-card {
    height: 100%;
    overflow-y: auto;
}

.box-card::-webkit-scrollbar {
    display: none;
    /* 隐藏滚动条 */
}

.cpu-row {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
}

.cpu-info {
    width: calc(100% - 74px);
    padding-right: 10px;
    font-size: 14px;
}

.cpu-output {
    display: flex;
    justify-content: flex-end;
    align-items: center;
    flex-grow: 1;
    width: 64px;
    height: 64px;
}

.output-image {
    width: 64px;
    height: 64px;
}

.cpu-info h1 {
    margin-bottom: 4px;
}

.ellipsis {
    font-size: 20px;
    line-height: 25px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    width: 100%;
}

.image-wrapper {
    display: flex;
    /* align-items: center; */
    height: calc(100% - 16px);
}

.item-card {
    margin-bottom: 8px;
}

.component-image {
    margin: auto 0;
    width: 48px;
    height: 48px;
    margin-right: 12px;
}

.item-info {
    display: flex;
    flex-direction: column;
    justify-content: flex-start;
    /* 让信息块顶部对齐 */
    width: calc(100% - 60px);
    line-height: 1.5;
}

.stored-card {
    background-color: none;
}

.pending-card {
    background-color: #f4f2e4;
}

.active-card {
    background-color: #d4e5ce;
}
</style>