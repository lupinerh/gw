import React from 'react';
import {render} from 'react-dom';

import VerticalMenu from '../VerticalMenu/VerticalMenu.js';
import NavNews from '../NavNews/NavNews.js';
import NavSchedule from '../NavSchedule/NavSchedule.js';

import './Dashboard.css';

class Dashboard extends React.Component {
  constructor(){
    super();
    this.state = {
        numberNav: 2
    };
    this.handleClick = this.handleClick.bind(this);
  }

  handleClick(numberNav) {
        this.setState({
            numberNav: numberNav,
        });


    }


  renderDashboard(){
    var numberNav = this.state.numberNav

    switch(numberNav){
      case 1:
        return (
          <NavNews />
          );
        break;
      case 2:
        return(
          <NavSchedule />
        );
        break;
      default:
        break;
      }
  }

  render(){

    return (
        <div>
          <VerticalMenu activeNav={this.state.numberNav} selectedNav={this.handleClick}/>
          {this.renderDashboard()}
        </div>
    );
  }
}

export default Dashboard;
// render(
//   <Dashboard />,
//   document.getElementById("root")
// );
