import mysql from 'mysql2'

import dotenv from 'dotenv'
dotenv.config()

export const pool = mysql.createPool({
    host: process.env.MYSQL_HOST,
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASSWORD,
    database: process.env.MYSQL_DATABASE
}).promise()

export async function getUsers() {
    const [rows] = await pool.query('SELECT * FROM users')
    return rows
}

export async function getPostsByUser(id) {
    const [rows] = await pool.query('SELECT * FROM posts WHERE userid = ?', [id])
    return rows
}

export async function getCommentsByPost(id) {
    const [rows] = await pool.query('SELECT * FROM comments WHERE postid = ?', [id])
    return rows
}

export async function getCommentsByGroupPosts(id) {
    const [rows] = await pool.query('SELECT * FROM group_posts_comments WHERE postid = ?', [id])
    return rows
}

export async function getUserSingular(id) {
    // use ? instead of {id} to protect against sql attack
    const [rows] = await pool.query('SELECT * FROM users WHERE id = ?', [id])
    return rows[0]
}

export async function addUser(name, lname, DOB, email, address) {
    // use result.insertId to get id of newly created user
    if (email.includes('@') && email.includes('.')) {
        const result = await pool.query('INSERT INTO users (fname, lname, DOB, email, address ) VALUES (?,?,?,?,?)', [name, lname, DOB, email, address])
        return result
    }
}

export async function getRequests(id) {
    const [rows] = await pool.query('SELECT * FROM users AS U, requests AS R WHERE U.id = R.suserid AND R.ruserid = ?', [id])
    return rows
}

export async function getUserByLogin(email, password) {
    const [rows] = await pool.query('SELECT * FROM users WHERE email = ? AND password = ?', [email, password])
    if (rows.length) {
        return true
    } else {
        return false
    }
}

export async function getRelationship(id) {
    const [rows] = await pool.query('SELECT relationship FROM users WHERE id = ?', [id])
    if (rows.length) {
        const [result] = await pool.query('SELECT * FROM users WHERE id = ?', [rows[0].relationship])
        return result[0]
    } else {
        return 0
    }
}

export async function getHomeScreenPosts(id) {
    const friends = await findFriends(id)
    const posts = []
    for (let friend of friends) {
        const temps = await getPostsByUser(friend.suserid)
        for (let temp of temps) {
            posts.push(temp)
        }
    }
    return posts
}

export async function getGroups(id) {
    const [rows] = await pool.query('SELECT * FROM group_info AS i, group_members AS m WHERE i.id = m.groupid AND m.userid = ?', [id])
    return rows
}

export async function getWorks(id) {
    const [rows] = await pool.query('SELECT * FROM works WHERE userid = ?', [id])
    return rows
}

export async function getLikes(id) {
    const [rows] = await pool.query('SELECT COUNT(*) AS likes FROM likes WHERE postid = ? GROUP BY postid', [id])
    return rows[0]
}

export async function getLastGroupPost(id) {
    const [rows] = await pool.query('SELECT * FROM groups_post WHERE groupid = ? ORDER BY groupid DESC LIMIT 1', [id])
    let today = new Date()
    var dd = String(rows[0].created.getDate()).padStart(2, '0');
    return dd
}

export async function getGroupPostsByUser(id) {
    const [rows] = await pool.query('SELECT * FROM groups_post WHERE groupid IN (SELECT groupid FROM group_members WHERE userid = ?) ORDER BY created DESC', [id])
    return rows
}

export async function getGroupInfo(id) {
    const [rows] = await pool.query('SELECT * FROM group_info WHERE id = ?', [id])
    return rows
}

export async function getGroupMembers(id) {
    const [rows] = await pool.query('SELECT COUNT(*) AS members FROM group_members WHERE groupid = ?', [id])
    return rows[0].members
}

export async function getAmountofPosts(id) {
    const [rows] = await pool.query('SELECT COUNT(*) AS posts FROM groups_post WHERE groupid = ?', [id])
    return rows[0].posts
}

export async function getSuggestedGroups(id) {
    const [rows] = await pool.query('SELECT * FROM group_info WHERE id NOT IN (SELECT groupid FROM group_members WHERE userid = ?) ORDER BY created DESC', [id])
    return rows
}

export async function addLike(postid, userid) {
    const result = await pool.query('INSERT INTO likes (postid, userid) VALUES (?,?)', [postid, userid])
    return result
}

export async function addLikeGroup(postid, userid) {
    const result = await pool.query('INSERT INTO groupLikes (postid, userid) VALUES (?,?)', [postid, userid])
    return result
}

export async function getLiked(postid, userid) {
    const [result] = await pool.query('SELECT * FROM likes WHERE postid = ? AND userid = ?', [postid, userid])
    if (result.length) {
        return true
    } else {
        return false
    }
}

export async function addComment(postid, userid, comment) {
    const result = await pool.query('INSERT INTO comments (postid, userid, content, created) VALUES (?,?,?,?)', [postid, userid, comment, new Date()])
    return result
}

export async function isFriend(id1, id2) {
    const [rows] = await pool.query('SELECT * FROM friends WHERE (fuserid = ? AND suserid = ?) OR (fuserid = ? AND suserid = ?)', [id1, id2, id2, id1])
    if (rows.length == 0 && id1 != id2) {
        const [results] = await pool.query('SELECT * FROM requests WHERE (suserid = ? AND ruserid = ?) OR (suserid = ? AND ruserid = ?)', [id1, id2, id2, id1])
        if (results.length == 0) {
            return "Not friends"
        } else {
            return "Pending"
        }
    } else {
        return "friends"
    }
}

export async function addFriendship(id1, id2) {
    const result = await pool.query('INSERT INTO friends (fuserid, suserid, date) VALUES (?,?,?)', [id1, id2, new Date()])
    return result
}

export async function addRequest(id1, id2) {
    const result = await pool.query('INSERT INTO requests (suserid, ruserid, date) VALUES (?,?,?)', [id1, id2, new Date()])
    return result
}

export async function cancelRequest(id1, id2) {
    const result = await pool.query('DELETE FROM requests WHERE (suserid = ? AND ruserid = ?) OR (suserid = ? AND ruserid = ?)', [id1, id2, id2, id1])
    return result
}

export async function findFriends(id) {
    //const [rows] = await pool.query('SELECT * FROM friends as f, users as U1, users as U2 WHERE (f.fuserid = U1.id AND f.suserid = U2.id) AND (f.fuserid = ? OR f.suserid = ?)', [id,id])
    const [rows] = await pool.query('SELECT * FROM friends as f, users as U1, users as U2 WHERE (f.fuserid = U1.id AND f.suserid = U2.id) AND (f.fuserid = ? OR f.suserid = ?)', [id,id])
    return rows
}

export async function unlike(like, id) {
    const [result] = await pool.query('DELETE FROM likes WHERE postid = ? AND userid = ?', [like, id])
    return result
}

export async function addPost(userid, content) {
    const result = await pool.query('INSERT INTO posts (userid, content, created) VALUES (?,?,?)', [userid, content, new Date()])
    return result
}

/*' SELECT * FROM group_info WHERE id IN (SELECT groupid FROM group_members WHERE userid = ?)'
const notes = await getUsers()
console.log(notes) 

const note = await getUserSingular(3)
console.log(note) 

//const friends = await findFriends(1)
//console.log(friends)

//const groups = await getGroups(1)
//console.log(groups)

const posts1 = await getPostsByUser(1)
console.log(posts1)

const posts2 = await getHomeScreenPosts(1)
console.log(posts2)

const friends = await findFriends(1)
console.log(friends)*/

const result = await addPost(1, "Test")