import {combineReducers} from 'redux';
import quoteReducer from './quoteReducer';
//import authReducer from './authReducer';
// import errorReducer from './errorReducer';
import statusReducer from './statusReducer';





const init = {
  assets: {}
};

let mainReducer = (state = init, action) => {
  let newState = Object.assign({}, state);

  switch(action.type){
    case "LOAD_ASSETS":
      return newState.assets = action.assets;

    default:
      return state;
  }

}


export default combineReducers({
  main: mainReducer,
  quote: quoteReducer,
  auth: authReducer,
  status: statusReducer
})
