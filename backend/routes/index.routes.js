import geekup from './api.routes.js';

const initRoutes = (app) => {
    app.use('/api/geek-up/', geekup);
}

export default initRoutes;
