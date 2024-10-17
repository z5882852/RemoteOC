import axios from 'axios';

class Requests {
  constructor() {
    this.axiosInstance = axios.create({
      baseURL: localStorage.getItem('backendUrl'),
      headers: {
        'x-server-token': localStorage.getItem('token'),
      },
    });
  }

  get(url, params = {}) {
    return this.axiosInstance.get(url, { params });
  }

  post(url, data = {}) {
    return this.axiosInstance.post(url, data);
  }

}

export default new Requests();
