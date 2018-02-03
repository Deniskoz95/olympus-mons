import React from 'react';
import { Route, hashHistory, IndexRedirect, IndexRoute } from 'react-router';
import { Provider } from 'react-redux';
import { BrowserRouter } from 'react-router-dom'

import store from './store';
import App from './app';




export default () => {
    return (
        <Provider store={store}>
                <BrowserRouter>
                    <Route path='/' component={App} />
                </BrowserRouter>
        </Provider>
    )
}
