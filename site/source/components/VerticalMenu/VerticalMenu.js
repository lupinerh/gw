import React from 'react';
import firebase from '../../fire.js';
import './VerticalMenu.css';

class VerticalMenu extends React.Component {
  constructor(){
    super()


  }

  handleSignOut(){
    firebase.auth().signOut().then(function() {
      console.log('Signed Out');
      document.location.reload(true);
    }, function(error) {
      console.error('Sign Out Error', error);
    });
  }


  render(){
    console.log(this.props.activeNav)

    var activeNav = this.props.activeNav;

    return (

      <div className="vertical-menu">
        <nav>
        <a href="#" className=
          {
            activeNav == 1 ? "menu-active" : ""
          }
          onClick={() => this.props.selectedNav(1)}>Новости</a>
        <a href="#" className=
          {
            activeNav == 2 ?  "menu-active" : ""
          }
           onClick={() => this.props.selectedNav(2)}>Расписание</a>
        </nav>

        <button className='button-signout' onClick={this.handleSignOut}>Выйти</button>
      </div>

    );
  }
}

export default VerticalMenu;
