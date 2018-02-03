'use strict';

import {createStore, applyMiddleware, compose} from 'redux';
import rootReducer from './reducers/rootReducer';

import { composeWithDevTools } from 'redux-devtools-extension';
import {createLogger} from 'redux-logger';
import thunkMiddleware from 'redux-thunk';

//take logger,  dev tools out for prod
const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;
export default createStore(
  rootReducer,
  composeEnhancers(
  applyMiddleware(
    thunkMiddleware,
    createLogger({collapsed: true}),
  ))
);
