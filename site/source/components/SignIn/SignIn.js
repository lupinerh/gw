import React from 'react';
import {render} from 'react-dom';
import firebase from '../../fire.js';


import Dashboard from '../Dashboard/Dashboard.js';

import './SignIn.css';


class SignIn extends React.Component {
  constructor(){
    super()
    this.state = {
      isAuthorized: false,
      uid: '',
      name: '',
      email: ''
    }

    this.handleSignIn = this.handleSignIn.bind(this)
    this.componentWillMount = this.componentWillMount.bind(this);

  }


  componentWillMount(){
    var visibleThis = this

    firebase.auth().onAuthStateChanged(function(user) {
      if (user) {
        // User is signed in.
        var email = user.email;

        let usersRef = firebase.database().ref('users/').orderByKey();
        usersRef.once('value', snapshot => {
          snapshot.forEach(item => {
            if (email == item.val().email) {

              visibleThis.setState({
                isAuthorized: true,
                email: email,
                name: item.val().name,
                uid: item.key
              });


            }
          });
        });

        // ...
      } else {
        // User is signed out.
        // ...
      }
    });
  }

  handleSignIn(e){
    e.preventDefault(); // <- prevent form submit from reloading the page
    var email = this.inputEmail.value
    var password = this.inputPassword.value
    var visibleThis = this

    firebase.auth().signInWithEmailAndPassword(email, password).catch(function(error) {
        // Handle Errors here.
        var errorCode = error.code;
        var errorMessage = error.message;
        // ...
    });

    firebase.auth().onAuthStateChanged(function(user) {
      if (user) {
        // User is signed in.
        var email = user.email;

        let usersRef = firebase.database().ref('users/').orderByKey();
        usersRef.once('value', snapshot => {
          snapshot.forEach(item => {
            if (email == item.val().email) {
              visibleThis.setState({
                isAuthorized: true,
                email: email,
                name: item.val().name,
                uid: item.key
              });
            }
          });
        });

        // ...
      } else {
        // User is signed out.
        // ...
      }
    });
  }

  setupRender(){
    var isAuthorized = this.state.isAuthorized
    console.log(isAuthorized);

    if (isAuthorized) {
      return (
        <Dashboard />
      )
    } else {
      return(
        <div className='wrap'>
          <p className='titleAuth'>Авторизация</p>
          <form onSubmit={this.handleSignIn}>
              <input type='text' id='email' placeholder='Почта' ref={ email => this.inputEmail = email } value='admin@mail.test'/>
              <input type='password' id='password' placeholder='Пароль' ref={ password => this.inputPassword = password } value='123456'/>
              <button className='button-signin' type='submit'>Войти</button>
        </form>
        </div>

        );
    }
  }

  render() {
    return (
      <div>
        { this.setupRender() }
      </div>
    );
  }
}


render(
  <SignIn />,
  document.getElementById("root")
);
