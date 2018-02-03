const init = {
    quoteData: {},
    loading: false
  }
  
  export default (state = init, action) => {
    let newState = Object.assign({}, state, action);
  
    switch(action.type){
      case "REQUEST_QUOTE_DATA":
        newState.loading = true;
      break;
      case "RECEIVE_QUOTE_DATA":
        newState.quoteData = action.data; newState.loading = false;
      break;
      default:
      return state;
    }
    return newState;
  
  }
  
  