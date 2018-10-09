// counter удалить!

import React from 'react';
import {render} from 'react-dom';
import firebase from '../../fire.js';

import News from '../News/News.js';

import './NewsFeed.css';
import './FormCreateNews.css';

class NewsFeed extends React.Component {
  constructor(props){
    super(props);
    this.state = {
      counterId: 0,
      lastNewsKey: '',
      news: [],
      requestSent: false
    }

    this.handleOnScroll = this.handleOnScroll.bind(this);
    this.doQuery = this.doQuery.bind(this);
    this.handleDeleteNews = this.handleDeleteNews.bind(this);

  }

  //
  componentWillMount(){
    // this.createFakeData();
    this.getNewsOnce();           // работает вроде
    // this.getNewsOn();          // не нормально работает delete
  }
  componentDidMount() {
    window.addEventListener('scroll', this.handleOnScroll);

  }
  componentWillUnmount() {
    window.removeEventListener('scroll', this.handleOnScroll);
  }


  createFakeData() {
    var i = 0;
    let data = [];
    for (i = 0; i < 100; i++) {
      let aNews = { id: i, timestamp: "timestamp", title: "title " + i, text: "text " + i };
      data.push(aNews);
    }
    this.setState({ news: data });

  }
  createNewFakeData(startKey, counter) {
    var i = 0;
    let data = []
    for (i = 0; i < counter; i++) {
      let newI = startKey + i;
      let aNews = { id: newI, timestamp: "timestamp", title: "title " + newI, text: "text " + newI };
      data.push(aNews);
    }
    this.setState({ news: this.state.news.concat(data) });

    // console.log(this.state.news);
  }

  // начальное получение данных и подгрузка их
  getNewsOn(){
    let newsRef = firebase.database().ref('news').orderByKey().limitToLast(10);
    let counter = 0;
    newsRef.on('child_added', snapshot => {

      if (!this.state.lastNewsKey){
        this.setState({ lastNewsKey: snapshot.key });
      } else {

      /* Update React state when message is added at Firebase Database */
      let aNews = { id: snapshot.key, timestamp: snapshot.val().timestamp, title: snapshot.val().title, text: snapshot.val().text };
      this.setState({ news: [aNews].concat(this.state.news) });

    }
    });

  }
  getNewsOnce(){
    const items = [];
    let lastItemKey = '';
    let newsRef = firebase.database().ref('news').orderByKey().limitToLast(10);
    let counter = 0;
    newsRef.once('value', snapshot => {
      // console.log("qwerty " + snapshot);
      snapshot.forEach(item => {
        if (!lastItemKey){

            // console.log("привет");
          lastItemKey = item.key;
        } else {

        let aNews = { id: item.key, timestamp: item.val().timestamp, title: item.val().title, text: item.val().text };
        items.push(aNews);
        console.log(aNews);

        }
      });
      this.setState({ news: items.reverse() });
      this.setState({ lastNewsKey: lastItemKey });
      this.setState({ counterId: counter });
    });

  }
  getNewNews(startKey, limit){

    const items = [];
    let lastItemKey = '';
    let newsRef = firebase.database().ref('news').orderByKey().endAt(this.state.lastNewsKey).limitToLast(limit);
    let counter = startKey;
    newsRef.once('value', snapshot => {
      snapshot.forEach(item => {
        if (!lastItemKey){

            console.log("привет");
          lastItemKey = item.key;
        } else {

        let aNews = { id: item.key, timestamp: item.val().timestamp, title: item.val().title, text: item.val().text };
        items.push(aNews);
        console.log(aNews);

        }
      });

      const allNews = this.state.news.concat(items.reverse());
      this.setState({ news: allNews });
      this.setState({ lastNewsKey: lastItemKey });
    });

  }

  querySearchResult() {
    // console.log(this.state.requestSent);
    if (this.state.requestSent) {

      return;
    }

    // дожидаться исполнения
    let promise = new Promise((resolve, reject) => {
      this.doQuery();
    });

    promise.then(
      result => {
        this.setState({requestSent: true});
      },
      error => {
        console.log(error);
      }
    );
  }
  doQuery() {
    // this.createNewFakeData(this.state.news.length, 20);
    this.getNewNews(this.state.news.length, 5);

    this.setState({requestSent: false});

  }


  // действия
  //добавить
  handleAddNews(e){
    e.preventDefault(); // <- prevent form submit from reloading the page
    /* Send the message to Firebase */
    var pushNews = firebase.database().ref('news').push({
      timestamp: Math.round(Date.now() / 1000),
      title: this.inputTitle.value,
      text: this.inputText.value
    });


    // ЕСЛИ firebase.ON, ТО НЕ НУЖНО, А ЕСЛИ firebase.ONCE, ТО НУЖНО, но тогда нужно КАК ТО ДОДЕЛЫВАТЬ DELETE

    var item = [];
    item.push({ id: pushNews.key, title: this.inputTitle.value, text: this.inputText.value });
    this.setState({ news: item.concat(this.state.news)});


    this.inputTitle.value = ''; // <- clear the input
    this.inputText.value = '';

    // console.log(this.state.news);
  }
  // удалить
  handleDeleteNews(newsId){
    firebase.database().ref('news/' + newsId).remove();

    var index = this.state.news.map((item) => {return item.id}).indexOf(newsId);
    if (index > -1){
      this.state.news.splice(index,1);
      this.forceUpdate();
    }

    // console.log(this.state.news);
  }
  handleOnScroll() {
    // http://stackoverflow.com/questions/9439725/javascript-how-to-detect-if-browser-window-is-scrolled-to-bottom
    var scrollTop = (document.documentElement && document.documentElement.scrollTop) || document.body.scrollTop;
    var scrollHeight = (document.documentElement && document.documentElement.scrollHeight) || document.body.scrollHeight;
    var clientHeight = document.documentElement.clientHeight || window.innerHeight;
    var scrolledToBottom = Math.ceil(scrollTop + clientHeight) >= scrollHeight;

    if (scrolledToBottom) {
      this.querySearchResult();
    }
  }


  render () {
    const divFixed = {
      border: '10px solid white',
      position: 'sticky',
      top: '0px',
      background: 'white'
    };

    var date = Math.round(Date.now() / 1000)

    return (
      <div>
        <div className="news--container-form">
          <form className="news--form" onSubmit={this.handleAddNews.bind(this)}>
            <div className="field">
              <input type="text" name="title" placeholder="Заголовок" ref={ title => this.inputTitle = title } />
            </div>
            <div className="field">
              <textarea type="text" name="text" placeholder="Текст" ref={ text => this.inputText = text }></textarea>
            </div>
            <button className="news--button-submit news--button-create-news" type="submit">Добавить</button>
            </form>
        </div>
        <div className="news--container-cards">
          <div>
            {  this.state.news.map((anews) => <News key={anews.id} value={anews} delete={this.handleDeleteNews}/> ) }
          </div>
        </div>
      </div>
    );
  }
}

export default NewsFeed;
