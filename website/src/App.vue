<template>
    <el-container style="height: 100%;">
        <el-header style="height: 60px;">
            <div class="toolbar">
                <div class="title-container">
                    <el-link href="/" :underline="false">
                        <h1 class="title">RemoteOC</h1>
                    </el-link>
                </div>
                <div class="content">
                </div>
            </div>
        </el-header>
        <el-container style="height: 100%;">
            <el-aside width="200px" style="height: calc(100vh - 60px);">
                <el-menu default-active="index" class="el-menu-vertical-demo" @select="handleSelect"
                    style="height: 100%;">
                    <el-menu-item index="index">主页</el-menu-item>
                    <el-menu-item index="items">物品</el-menu-item>
                    <el-menu-item index="cpus">合成处理器</el-menu-item>
                    <el-menu-item index="settings">设置</el-menu-item>
                </el-menu>
            </el-aside>
            <el-main style="height: calc(100vh - 60px); padding: 0;">
                <router-view v-slot="{ Component }">
                    <keep-alive>
                        <component :is="Component" />
                    </keep-alive>
                </router-view>
            </el-main>
        </el-container>
    </el-container>
</template>

<script>
export default {
    methods: {
        handleSelect(key, keyPath) {
            this.$router.push({ name: key });
        },
    },
};
</script>

<style scoped>
.el-container {
    height: 100%;
}

.el-header {
    position: relative;
    background-color: var(--el-color-primary-light-9);
    color: var(--el-text-color-primary);
    padding: 0 32px;
}

.toolbar {
    display: flex;
    align-items: center;
    justify-content: center;
    height: 100%;
    right: 20px;
}

.toolbar .title-container {
    display: flex;
    align-items: center;
    height: 100%;
}

.toolbar .content {
    display: flex;
    justify-content: flex-end;
    align-items: center;
    flex-grow: 1;
    height: 100%;
}

.title {
    font-size: 18px;
}
</style>
