<template>
    <div>
        <el-form label-position="left" label-width="auto" style="max-width: 600px; margin: 20px;">
            <el-space fill style="width: 100%; margin-bottom: 5px;">
                <el-alert type="info" show-icon :closable="false">
                    <p>该页面内容请勿泄露给他人</p>
                </el-alert>
            </el-space>
            <el-form-item label="服务端地址">
                <el-input v-model="backendUrl" placeholder="Backend URL"></el-input>
            </el-form-item>
            <el-form-item label="服务端令牌">
                <el-input v-model="token" placeholder="Token"></el-input>
            </el-form-item>
            <el-form-item>
                <el-button type="primary" @click="saveSettings">保存</el-button>
            </el-form-item>
        </el-form>
    </div>
</template>

<script>
export default {
    name: 'Settings',
    data() {
        return {
            backendUrl: localStorage.getItem('backendUrl') || '',
            token: localStorage.getItem('token') || '',
        };
    },
    methods: {
        saveSettings() {
            localStorage.setItem('backendUrl', this.backendUrl);
            localStorage.setItem('token', this.token);
            this.$message.success('设置已保存');
        },
    },
};
</script>