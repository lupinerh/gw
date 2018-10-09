import React from 'react';
import {render} from 'react-dom';
import firebase from '../../fire.js';

import './News.css';

class News extends React.Component {
  constructor(props){
    super(props);
    this.state = {
      isActive: false,
      isChanging: false,

      timestamp: this.props.value.timestamp,
      title: this.props.value.title,
      text: this.props.value.text
    }

    this.handleIsActive = this.handleIsActive.bind(this);
    this.handleIsChanging = this.handleIsChanging.bind(this);
    this.acceptChange = this.acceptChange.bind(this);

  }


// действия
// открыть новость
  handleIsActive(){
    this.setState((prevState) => {
      return { isActive: !prevState.isActive };
    });
  }
// изменить
  handleIsChanging(){
    this.setState((prevState) => {
      return { isChanging: !prevState.isChanging };
    });

    // ???
    if (this.state.isChanging) {
      this.handleIsActive();
    }
  }
// принять изменения
  acceptChange(newsId){
    return event => {
      event.preventDefault();

      firebase.database().ref('news/' + newsId).update({
        title: this.inputTitle.value,
        text: this.inputText.value
      });

      this.setState((prevState) => {
        return { isChanging: !prevState.isChanging,
                 title: this.inputTitle.value,
                 text: this.inputText.value
               };
      });
    }
  }

  toDateTime(secs) {
    var monthNames = [
      "ЯНВАРЬ", "ФЕВРАЛЬ", "МАРТ",
      "АПРЕЛЬ", "МАЙ", "ИЮНЬ", "ИЮЛЬ",
      "АВГУСТ", "СЕНТЯБРЬ", "ОКТЯБРЬ",
      "НОЯБРЬ", "ДЕКАБРЬ"
    ];
    var monthNumbers = [
      "01", "02", "03",
      "04", "05", "06", "07",
      "08", "09", "10",
      "11", "12"
    ];
    var dayOfWeekNames = [
      "ПОНЕДЕЛЬНИК", "ВТОРНИК", "СРЕДА",
      "ЧЕТВЕРГ", "ПЯТНИЦА", "СУББОТА", "ВОСКРЕСЕНЬЕ"
    ];


    var currentSeconds = new Date().getTime() / 1000;
    var currentDate = new Date(1970, 0, 1);
    currentDate.setSeconds(currentSeconds);

    var secondsInDay = 60 * 60 * 24;

    var strDate;
    var strTime;

    var t = new Date(1970, 0, 1); // Epoch
    t.setSeconds(secs);

    if (currentDate.getDate() - t.getDate() > 7) {
      strDate = t.getDate().toString() + '.' + monthNumbers[t.getMonth()] + '.' + t.getFullYear().toString();
    } else if (currentDate.getDate() - t.getDate() > 1) {
      strDate = dayOfWeekNames[t.getDay()];
    } else if (currentDate.getDate() - t.getDate() > 0) {
      strDate = "ВЧЕРА";
    } else {
      strDate = "СЕГОДНЯ";
    }


    strTime = t.getHours().toString() + ":" + t.getMinutes().toString();
    console.log(strDate + strTime);
    return (strDate + " " + strTime);
}

  renderNewsCard(){
    const isChanging = this.state.isChanging;
    var isActive = this.state.isActive;
    var datetime = this.toDateTime(parseInt(this.state.timestamp));

    if (isChanging) {
      return (

        <div className="news--card">
          <form onSubmit={this.acceptChange(this.props.value.id)}>
          <div >
            <div className="news--timestamp">
              {datetime}
            </div>
            <div className="news--buttons">
              <button type="button" className="news--button-change" onClick={this.handleIsChanging}> Отмена </button><br/>
            </div>
            <div className="field">
              <h2><input className="titleNews" defaultValue={this.state.title} ref={title => this.inputTitle = title} /></h2>
            </div>
          </div>
            <div className="news--content field">
              <textarea className="change-textNews" defaultValue={this.state.text} ref={text => this.inputText = text}></textarea>
            </div>
            <button className="news--button-submit news--button-accept" type="submit">Отправить</button>
          </form>
        </div>

      )
    } else {
      return (
        <div className="news--card">
          <div className=
            {
              isActive ? 'news--header news--active' : 'news--header'
            }
              onClick={this.handleIsActive}>
            <div className="news--timestamp">
              {datetime}
            </div>
            <div className="news--buttons">
              <button className="news--button-change" onClick={this.handleIsChanging}>Изменить</button>
              <button className="news--button-delete" onClick={() => this.props.delete(this.props.value.id)}>Удалить</button>
            </div>
            <h2>{this.state.title}</h2>
          </div>
          <div className="news--content">
            <p>
              {this.state.text}
            </p>
          </div>
        </div>

      )
    }
  }

  render() {


    return (
      <div>
        { this.renderNewsCard() }
      </div>
    );
  }
}

export default News;
