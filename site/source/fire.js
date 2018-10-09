import firebase from 'firebase';

var config = {
    apiKey: "",
    authDomain: "",
    databaseURL: "",
    projectId: "",
    storageBucket: "",
    messagingSenderId: ""
  };

  let fire = firebase.initializeApp(config);

  export default fire;
