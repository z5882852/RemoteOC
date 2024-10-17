import Requests from './requests';
import { ElMessage } from 'element-plus';


// 轮询获取任务状态
const fetchStatus = async (task_id, handleResult, interval = 1000, pollingController = createPollingController()) => {
    try {
        const response = await Requests.get('/api/cmd/status', { task_id });
        const data = response.data;
        if (data.code === 200) {
            if (data.data.status === 'completed') {
                if (handleResult) handleResult(data.data);
                if (pollingController) {
                    pollingController.stop();
                }
            } else {
                if (pollingController && pollingController.running) {
                    pollingController.timeoutId = setTimeout(() => {
                        fetchStatus(task_id, handleResult, interval, pollingController);
                    }, interval);
                }
            }
        } else {
            ElMessage.error(`查询任务失败: ${data.code}, ${data.message ? data.message : data}`);
            console.error(data);
        }
    } catch (error) {
        console.log(error)
        ElMessage.error(`查询任务失败: ${error}`);
        console.error(`Error fetching task status: ${error}`);
    }
};

const addTask = async (task_id, client_id, handleResult) => {
    try {
        const response = await Requests.post('/api/cmd/task', {
            task_id: task_id,
            client_id: client_id,
        });
        const { code, data } = response.data;
        if (code === 200) {
            console.log(`Task '${data.task_id}' added successfully.`);
            if (handleResult) handleResult(data);
        } else {
            ElMessage.error(`提交任务失败: ${data.code}, ${data.message ? data.message : data}`);

        }
    } catch (error) {
        ElMessage.error(`提交任务失败: ${error}`);
        console.error('Error adding task:', error);
    }
};

const createPollingController = () => {
    return {
        running: true,
        timeoutId: null,
        stop() {
            this.running = false;
            if (this.timeoutId) {
                clearTimeout(this.timeoutId);
                this.timeoutId = null;
            }
        },
    };
};

export { fetchStatus, addTask, createPollingController };
