import Yaris from 'yaris-wrapper';

const yaris = new Yaris('dQhPyXTb5eK6');

yaris.getUser('188667839886917633').then(user => {
    console.log(user);
})