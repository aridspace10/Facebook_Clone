import {getUsers, getUserSingular, addUser, getRequests,getUserByLogin} from './database.js'


const users = await getUsers()
for (let person in users) {
    console.log(users[person].fname)
}
//<%= persons[person].fname %>