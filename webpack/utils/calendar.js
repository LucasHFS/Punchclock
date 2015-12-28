import Immutable from 'immutable';
import moment from 'moment';

const daysPerWeek = 7;
const Day = Immutable.Record({day: undefined, inner: undefined, today: false});
const Week = Immutable.Record({days: Immutable.List()});

export function prev(base){
  return base.clone().subtract(1, 'M').date(base.date());
}

export function next(base){
  return base.clone().add(1, 'M').date(base.date());
}

export function week(date, range){
  return Immutable.Range(0, daysPerWeek).map((i)=> {
    let day = date.clone().add(i, 'd');
    let [from, to] = range;
    let inner = day.isBetween(from, to, 'day');
    let today = day.isSame(moment(), 'day');
    return new Day({ day: day, inner: inner, today: today });
  });
}

export function weeks(start, range){
  let weeksToShow = range[1].clone().endOf('w').diff(start, 'w');
  return Immutable.Range(0, weeksToShow).map((i)=> {
    return new Week({days: week(start.clone().add(i, 'w'), range)});
  });
}

export function innerRange(base){
  return [base.clone().subtract(1, 'M').date(base.date()),
          moment.min(base.clone().add(1, 'd'), moment().add(1, 'd'))];
}

export function monthNames(range){
  let [from, to] = range;

  if(from.year() != to.year()) {
    return [from.format('MMM YYYY'), to.format('MMM YYYY')].join(' / ');
  } else if(from.month() == to.month()) {
    return from.format('MMMM YYYY');
  }

  return [from.format('MMM'), to.format('MMM')].join(' / ') + to.format(' YYYY');
}

export function startDate(base){
  return base.clone().subtract(1, 'M').date(base.date()).add(1, 'day').day(0);
}

export function current() {
  return moment().add(1, 'M');
}

export function constraintMonth(year, month) {
  return parseInt(current().format('YYYYMM')) < parseInt(`${year}${month}`);
}
