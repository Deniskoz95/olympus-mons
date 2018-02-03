import React from 'react';

import Sidebar from './components/Sidebar';
import NavBar from './components/NavBar';
import Trade from './components/Trade';



export default (props) => {
  return (
    <div>
    <div className='navBarWrapper'>
      <NavBar />
    </div>
      <div className='bottomWrapper wireframe'>
        <div className='sideBarWrapper '>
          <Sidebar />
        </div>
        <div className='main'>
          <Trade />
        </div>
      </div>
      </div>
  )
}
