const init = {
    status: '',
    loading: false,
  };
  
  export default (state = init, action) => {
    switch (action.type){
      case 'SET_STATUS':
        return {...state,
          status: action.status
        };
      case 'SET_LOADING_STATUS':
        return { ...state,
          loading: action.loading
        }
      default:
        return state;
    }
  }
  