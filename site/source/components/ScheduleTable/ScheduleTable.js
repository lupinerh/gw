import React from 'react';
import XLSX from 'xlsx';
import firebase from '../../fire.js';

import './ScheduleTable.css';

function deleteRow(matrix, row) {
   matrix = matrix.slice(0); // make copy
   matrix.splice(row, 1);
   return matrix;
}

function getTeacher(words) {
    var n = words.split(" ");
    var fio = n[n.length - 2] + " " + n[n.length - 1];

    return fio;

}





class ScheduleTable extends React.Component {
  constructor(){
    super()
    this.state = {
      htmlTables: " ",
      teacher: {}
    }

    this.chooseFile = this.chooseFile.bind(this);
    this.returnHTMLTable = this.returnHTMLTable.bind(this);
    this.getTableInFirebase = this.getTableInFirebase.bind(this);
    this.arrayToTable = this.arrayToTable.bind(this);
    this.csvToJSON = this.csvToJSON.bind(this);
    this.getTeacherFirebase = this.getTeacherFirebase.bind(this);
    this.handleAcceptChange = this.handleAcceptChange.bind(this);

  }

  componentWillMount(){


    this.getTeacherFirebase();
    this.getTableInFirebase();

      console.log("will");
  }
  componentDidUpdate(){

  }
  componentDidMount(){
    // // console.log("did");
  }

  componentWillUnmount(){
    this.chooseFile = false;
    this.returnHTMLTable = false;
    this.getTableInFirebase = false;
  }

  returnHTMLTable(){
    return {__html: this.state.htmlTables};
  }

  getTableInFirebase(){
    let scheduleRef = firebase.database().ref('schedule').child('htmlTables');
    scheduleRef.on('value', snapshot => {
        this.setState({
          htmlTables: snapshot.val()
        });
    });
  }

  getTeacherFirebase(){
    var visibleThis = this;
    firebase.database().ref('users').orderByChild('role').equalTo('teacher').once('value', function(snapshot){
      snapshot.forEach(function(snap){
        var n = snap.val().name.split(" ");
        var firstNameFirebase = n[0];
        var initials = n[1][0] + '.' + n[2][0] + '.';
        var fio = firstNameFirebase + initials;
        // console.log(initials);
        var teacherFirebaseUID = snap.key

        visibleThis.state.teacher[fio] = teacherFirebaseUID;
        // console.log(teacherFirebaseUID);
        // console.log(firstNameFirebase);

      });
    });

    console.log(this.state.teacher);

  }


  arrayToTable(matrix, countTimeInDay){
    // console.log(countTimeInDay);
    // console.log(matrix);
    var daysOfWeek = ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Субботу'];
    var table, thead, tbody, tr, td, tn, col, row;

    // добавляю дни недели к строкам
    var numberLesson = 2;
    for (var row = 0; row < matrix.length; ++row){
      var newDay = (row - 1) % countTimeInDay == 0;
      if (newDay){
         matrix[row].splice(0, 0, daysOfWeek[Math.floor(row / countTimeInDay)]);
         numberLesson = 2;
      } else matrix[row].splice(0, 0, '');

      if ((row+1) % 2 == 0) matrix[row].splice(1,0, Math.floor(numberLesson / 2));
      else matrix[row].splice(0, 0, '');
      numberLesson++;
    }


    table = document.createElement('table');
    thead = document.createElement('thead');
    tbody = document.createElement('tbody');
    for (row = 0; row < matrix.length; row++){
      tr = document.createElement('tr');
      for (col = 0; col < matrix[row].length; col++){
        td = document.createElement('td');
        tn = document.createTextNode(matrix[row][col]);
        td.setAttribute('contenteditable','true');
        td.appendChild(tn);
        tr.appendChild(td);
      }
      if (row == 0) thead.appendChild(tr);
      else tbody.appendChild(tr);
    }

    table.appendChild(thead);
    table.appendChild(tbody);

    // console.log(table);
    //
    //     console.log(table.outerHTML);
    this.setState({
      htmlTables: table.outerHTML
    });

    firebase.database().ref('schedule').update({
              htmlTables: table.outerHTML
            });
    // console.log(table.outerHTML);

  }

  csvToJSON(csv, mergeCell){
    var lines=csv.split("\n");
    var result = [];
    var headers=lines[0].split(",");

    var matrixCSV = [];
    for(var i=0;i<lines.length;i++){
      matrixCSV[i] = lines[i].split(",").map(function callback(currentValue, index, array) {
        // console.log(currentValue.trim());
        return (currentValue.trim());
      });
    }
    // console.log('mergeCell');
    // console.log(mergeCell);
    // console.log("no double");
    // console.log(matrixCSV);

    // дублируются объединеные элементы
    mergeCell.forEach(function(item, i, arr){
      var allItem = "";
      for (var i = item.s.r; i <= item.e.r; ++i){
        for (var j = item.s.c; j <= item.e.c; ++j){
            allItem += matrixCSV[i][j];
        }
      }
      for (var i = item.s.r; i <= item.e.r; ++i){
        for (var j = item.s.c; j <= item.e.c; ++j){
        matrixCSV[i][j] = allItem;
        }
      }

    });

    // на этап этапе объединенные ячейки продублированы
    // console.log("double");
    // console.log(matrixCSV);


    // поиск заголовков

    var gi = 0;
    var gj = 0;
    var isFind = false;

    exit:
    for (gi=0;gi<matrixCSV.length;gi++){
      for(gj=0; gj<matrixCSV[gi].length;++gj){
        console.log('ищем');
        if ((matrixCSV[gi][gj]).replace(/\s/g,'').toLowerCase() == 'группа'){
          isFind = true;
          break exit;
        }
      }
    }

    if (isFind){
      console.log("нашли");


    // удаляем все строки до группы
    for (var i = 0; i < gi; i++){
      matrixCSV = deleteRow(matrixCSV, i);
    }

    // ВЫЧИСЛЯЕМ СКОЛЬКО СТРОК РАВНО ОДНОМУ ДНЮ
    var countTimeInDay;
    var prevDay = matrixCSV[1][0];
    for (countTimeInDay = 2; countTimeInDay < matrixCSV.length; countTimeInDay++){
      if (prevDay != matrixCSV[countTimeInDay][0]) break;
    }
    countTimeInDay--;
    // все столбцы до группы
    for (var i = 0; i < matrixCSV.length; i++){
        matrixCSV[i].splice(0,gj);
    }

    if (matrixCSV[0][1] != matrixCSV[0][2]){
      // console.log(matrixCSV[0][1]);
      // console.log(matrixCSV[0][2]);
      console.log('не повторяются');
      return;
    }
    // удаляем повторные элементы
    console.log('повторяются');

    for (var i = 0; i < matrixCSV.length; i++){
      for (var j = 1; j < matrixCSV[i].length; j+=2){
        matrixCSV[i].splice(j,1);
      }
    }

    // ARRAY
    // !!!!!!!! здесь уже можно строить нормальную таблицу


    // !!! удаляем лишние ячейки (почему в конце иногда лишние попадают ячейки)

    // тут во всех ячейках должно быть время!!!
    // если нет, то удалить строку
    // если пустые строки
    for (var i = 1; i < matrixCSV.length; i++){
      if (matrixCSV[i].length < matrixCSV[0].length) {
        matrixCSV = deleteRow(matrixCSV,i);
        --i;
      }
    }

    // если пустые элементы
    for (var i = 1; i < matrixCSV.length; i++){
      if (matrixCSV[i][0].length < 4) {
        // console.log(matrixCSV[i][0].length);
        matrixCSV = deleteRow(matrixCSV,i);
        --i;
      }
    }


    // console.log(matrixCSV);

    // таким способом создается НОВАЯ МАТРИЦА (НЕ ССЫЛКА) со старыми значенями !!!
    var newMatrixCSV = JSON.parse(JSON.stringify(matrixCSV));
    this.arrayToTable(newMatrixCSV, countTimeInDay);



    // JSON
    // !!!!! здесь строить json для норм загрузки
    console.log("строим json");
    // console.log(matrixCSV);
    var obj = {};
    var groups = matrixCSV[0];
    var times = [];
    for (var i = 1; i < matrixCSV.length; i++){
      times.push(matrixCSV[i][0].substr(0,5).replace(/\s/g,''));
    }
    var daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    // вычисляем дни которые есть в понедельника, ненужные удаляю
    var realDays = Math.floor(times.length / countTimeInDay);
    daysOfWeek.splice(realDays);

    // после вехрнего вычисления и подсчета дней удаляем ненужное время
    times.splice(countTimeInDay);


    var ND = ['numerator', 'denominator'];
    // console.log(groups);
    // console.log(times);


    // РАСПИСАНИЕ ПРЕПОДАВАТЕЛЕЙ
    var objTeacher = {};
    // ДЛЯ ЖУРНАЛА ПРЕПОДАВАТЕЛЕЙ
    var objJournal = {};
    var objTeacherCopy = {};

    var counterJournal = 0;


    // работает
    for (var i = 0; i < groups.length-1; ++i){
      var objG = obj[groups[i+1]] = {};

      counterJournal = 0;
      for (var j = 0; j < daysOfWeek.length; ++j){
        var objD = objG[daysOfWeek[j]] = {}
        for (var k = 0; k <  countTimeInDay; k+=2){
          objD[(k / 2) + 1] = {'timestamp': times[k], 'ND': {}};
          var objND = objD[(k / 2) + 1]['ND'];
          for (var m = 0; m < ND.length; ++m){
            // !!! ставим значения в расписание
            // смещение по дням недели!
            var shiftDay = countTimeInDay*j;
            // главная ячейка (сама пара)

            var teacherName = getTeacher(matrixCSV[(k+m+1) + shiftDay][i+1].trim());


            if (typeof teacherName.replace(/\s/g,'') === 'undefined') {
              teacherName = ""
            }

            objD[(k / 2) + 1]["teacherName"] = teacherName;
            objND[ND[m]] = matrixCSV[(k+m+1) + shiftDay][i+1];

            // console.log(firstTeacherName);

            // ФОРМИРУЕМ РАСПИСАНИЕ ДЛЯ ПРЕПОДАВАТЕЛЕЙ
            if ((teacherName.replace(/\s/g,'') !== "") && (teacherName.replace(/\s/g,'') !== 'РС') && (teacherName.replace(/\s/g,'') !== 'КСРС')){
              // ищем именя преподавателя и возвращаем его uid

              // сохраняем по uid
              // var teacherUID = this.state.teacher[teacherName.replace(/\s/g,'')]

              // сохраняем по fio
              var teacherUID = teacherName.replace(/\s/g,'').replace(/\./g,'');



              if (teacherUID !== "undefined"){

                console.log("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
                console.log(teacherUID);
                console.log(teacherUID.length);
                console.log("undefined".length);

              // firebase.database().ref('users').orderByKey().on('child_added', function(snapshot){
              //   console.log(firstTeacherNameForFirebase);
              // });



              // строим расписание для преподавателей!!!

              var objT;
              var objTG;
              var objTG;
              var objTD;
              var objTND;
              var testObj = {};
              var objJ;
              var objJG;
              var objJL;


            if (typeof objTeacher[teacherUID] === 'undefined') {
                objT = objTeacher[teacherUID] = {};
                objJ = objTeacherCopy[teacherUID] = {'lessons':[]};

            } else {
              objT = objTeacher[teacherUID];
              objJ = objTeacherCopy[teacherUID];
            }


            objJL = objJ['lessons'];


            if (typeof objT[daysOfWeek[j]] === 'undefined'){
              objTD = objT[daysOfWeek[j]] = {};
            } else {objTD = objT[daysOfWeek[j]]}
            if (typeof objTD[(k / 2) + 1] === 'undefined') {
              // console.log((k / 2) + 1);
              objTD[(k / 2) + 1] = {'timestamp': times[k], 'ND': {}};
            }
            objTND = objTD[(k / 2) + 1]['ND'];
            objTND[ND[m]] = {};
            objTND[ND[m]]['group'] = groups[i+1];
            objTND[ND[m]]['title'] = matrixCSV[(k+m+1) + shiftDay][i+1];


            // построение журнала!

            var splitTitleLesson = (matrixCSV[(k+m+1) + shiftDay][i+1]).split(' ');
            var titleNotFio = [];
            var counter = 0;
            var currentValue;
            splitTitleLesson.forEach(function(world, i){
                if (world.length == 1) {
                  if ((splitTitleLesson[i-1] != "") || (splitTitleLesson[i] != "")){
                    titleNotFio.push(world);
                    currentValue = "";
                  } else {
                  currentValue += world;
                  ++counter;
                }
                } else if (world == "") {
                  if (counter != 0) {
                    titleNotFio.push(currentValue);
                    counter = 0;
                  }
                  currentValue = "";
                } else if (world !== "") {
                  titleNotFio.push(world);
                  currentValue = "";
                }

            })
            titleNotFio = titleNotFio.splice(0, titleNotFio.length - 2);
            var stringTitleLesson = titleNotFio.join(' ');



            // if (typeof objJL[stringTitleLesson] === 'undefined'){
            //     objJG = objJL[stringTitleLesson] = [];
            // } else {
            //     objJG = objJL[stringTitleLesson];
            // }

            var isTitle = false;
            var iTitle;
            objJL.forEach(function(item, i){
              if (item['title'] == stringTitleLesson) {
                isTitle = true;
                iTitle = i;
                return
              }
            });

            if (!isTitle){
                objJL.push({'title': stringTitleLesson, 'groups':[]});
                objJG = objJL[objJL.length-1]['groups'];
            } else {
                objJG = objJL[iTitle]['groups'];
            }


            // журнал
            var inSet = false;
            objJG.forEach(function(group){
              if (group === groups[i+1]) inSet = true;
            });
            if (!inSet) {
              objJG.push(groups[i+1]);
            }








            // console.log("objT");
            // console.log(objTeacher);
            // console.log("objJ");
            // console.log(objTeacherCopy);

            }
          }
          }
        }
      }
    }

    // запись json в firebase
    firebase.database().ref('schedule/groups').remove();
    firebase.database().ref('schedule/teachers').remove();
    firebase.database().ref('journals').remove();

    // console.log(objTeacherCopy);

    firebase.database().ref('schedule/groups').set(obj);
    firebase.database().ref('schedule/teachers').set(objTeacher);
    firebase.database().ref('journals').set(objTeacherCopy);


  } else {
    console.log('не нашли');
  }

    return obj;
  }

  handleAcceptChange(e){
    console.log(e);
  }


  chooseFile(e){
    const visibleThis = this;
    var file = e.target.files[0];
    let allHTMLTables = "";
    visibleThis.setState({
      htmlTables: ""
    });


    var reader = new FileReader();

    reader.onload = function(e) {
      var data = e.target.result;
      var workbook = XLSX.read(data, {
        type: 'binary',
        sheetStubs: true,
      });
      // // console.log(workbook['!merges']);


      workbook.SheetNames.forEach(function(sheetName) {
        // console.log(sheetName);
        // Here is your object
        // var XLSX_object_json = XLSX.utils.sheet_to_json(workbook.Sheets[sheetName], {row:true});
        // var json_object = JSON.stringify(XLSX_object_json);
        // var XLSX_object_html = XLSX.utils.sheet_to_html(workbook.Sheets[sheetName], {editable:true}).replace("<table", '<table className="schedule--table" border="1"');


        var XLSX_object_csv = XLSX.utils.sheet_to_csv(workbook.Sheets[sheetName]);
        var mergeCell = workbook.Sheets[sheetName]['!merges'];
        visibleThis.csvToJSON(XLSX_object_csv, mergeCell);



        // allHTMLTables += visibleThis.state.htmlTables + XLSX_object_html.toString();
        // visibleThis.setState({ htmlTables: allHTMLTables});

        // firebase.database().ref('schedule').update({
        //           htmlTables: allHTMLTables
        //         });

      });

    };

    reader.onerror = function(ex) {
      // // console.log(ex);
    };

    reader.readAsBinaryString(file);

  }

  render(){
    console.log("render");
    return (
      <div className="schedule">
        <div className="schedule--chooseFile">
          <input type="file" onChange={ (e) => this.chooseFile(e)} />
        </div>
        <div className="schedule--acceptChange">
          <button onClick={ () => this.handleAcceptChange(1)}> Принять </button>
        </div>
        <div id="schedule--tableDiv" dangerouslySetInnerHTML={this.returnHTMLTable()}/>
      </div>
    );
  }
}


export default ScheduleTable;
