import express from 'express'
import {getUsers, getUserSingular, addUser, getRequests,getUserByLogin, 
    getCommentsByPost,findFriends, getRelationship, getWorks,getPostsByUser, getLikes, 
    getHomeScreenPosts, getGroups, getLastGroupPost, getCommentsByGroupPosts,
    getGroupPostsByUser, getSuggestedGroups, getGroupMembers, getAmountofPosts, 
    addLike, getLiked, addComment, isFriend, addFriendship, addRequest,
    cancelRequest, unlike, getGroupInfo} from './database.js'

import {determineTime} from './helper.js'

const app = express()
app.set("view engine", "ejs")

app.use(express.json()) // for parsing application/json
app.use(express.urlencoded({ extended: true })) // for parsing application/x-www-form-urlencoded

const loggedIn = 1

app.get("/facebook/:id", async (req,res) => {
    const id = req.params.id
    const users = await findFriends(id)
    const requests = await getRequests(id)
    const user = await getUserSingular(id)
    const posts = await getHomeScreenPosts(id)
    for (let post of posts) {
        let user = await getUserSingular(post.userid)
        post.username = user.fname + ' ' + user.lname
        post.comments = await getCommentsByPost(post.id)
        for (let comment of post.comments) {
            let user = await getUserSingular(comment.userid)
            comment.username = user.fname + ' ' + user.lname
        }
        let likes = await getLikes(post.id)
        if (likes) {
            post.likes = likes.likes
        } else {
            post.likes = 0
        }
        post.liked = await getLiked(post.id, id)
    }
    res.render("Dashboard.ejs", {'persons': users, 'requests':requests, 'person': user, 'posts': posts})
})

app.post("/facebook/:id", async (req,res) => {
    const userid = req.params.id
    const button = req.body.person
    const comment = req.body.comment
    const create = req.body.create
    const like = req.body.like
    const confirm = req.body.confirm
    const deny = req.body.delete
    if (button) {
        switch (button) {
            case 'profile':
                res.redirect("/facebook/profile/" + userid)
            case 'groups':
                res.redirect("/facebook/" + userid + "/groups")
            case 'events':
                res.redirect("/facebook/" + userid + "/events")
            default:
                res.redirect("/facebook/profile/" + button)
        }
    } else if (comment) {
        res.redirect("/facebook/profile/" + userid)
    } else if (like) {
        if (await getLiked(like, userid) === false) {
            await addLike(like, userid)
        } else {
            await unlike(like, userid)
        }
        res.redirect("/facebook/" + userid)
    } else if (create) {
        const new_comment = req.body.create_comment[0]
        console.log(new_comment)
        if (new_comment) {
            await addComment(create, userid,new_comment)
        }
        res.redirect("/facebook/" + userid)
    } else if (confirm) {
        await addFriendship(confirm, userid)
        await cancelRequest(confirm, userid)
        res.redirect("/facebook/" + userid) 
    } else if (deny) {
        await cancelRequest(deny, userid)
        res.redirect("/facebook/" + userid) 
    } else if (person) {
        res.redirect("/facebook/profile/" + person)
    }
})

app.get("/facebook/:id/groups", async (req,res) => {
    const id = req.params.id
    const groups = await getGroups(id)
    const user = await getUserSingular(id)
    const posts = await getGroupPostsByUser(id)
    for (let post of posts) {
        let user = await getUserSingular(post.userid)
        const date = post.created
        post.created = await determineTime(date)
        post.username = user.fname + ' ' + user.lname
        post.group_name = (await getGroupInfo(post.groupid))[0].name
        post.comments = await getCommentsByGroupPosts(post.id)
        for (let comment of post.comments) {
            let user = await getUserSingular(comment.userid)
            comment.username = user.fname + ' ' + user.lname
        }
        // change this to group likes
        let likes = await getLikes(post.id)
        if (likes) {
            post.likes = likes.likes
        } else {
            post.likes = 0
        }
    }
    res.render("groups.ejs", {'groups': groups, 'person': user, 'posts': posts})
})

app.post("/facebook/:id/groups", async (req,res) => {
    const id = req.params.id
    const button = req.body.button
    switch (button) {
        case 'discover':
            res.redirect("/facebook/" + id + "/groups/discover")
            break;
        case 'groups':
            res.redirect("/facebook/" + id + "/groups/your-groups")
            break;
        case 'feed':
            res.redirect("/facebook/" + id + "/groups")
            break;
        default:
            throw new Error("Something went wrong")
    }
})

app.get("/facebook/:id/groups/your-groups", async (req,res) => {
    const id = req.params.id
    const groups = await getGroups(id)
    res.render('your-groups.ejs', {'id': id,'groups': groups})
})

app.get("/facebook/:id/groups/discover", async (req,res) => {
    const id = req.params.id
    const groups = await getGroups(id)
    const person = await getUserSingular(id)
    const sgroups = await getSuggestedGroups(id)
    for (let group of sgroups) {
        group.numofmembers = await getGroupMembers(group.id)
        let average = await getAmountofPosts(group.id)
        if (average < 12) {
            group.average_posts = average + ' number of posts a year'
        } else if (average < 52) {
            group.average_posts = Math.round(average / 12) + 'number of posts a months'
        } else if (average < 365) {
            group.average_posts = Math.round(average / 52) + 'number of posts a week'
        } else {
            group.average_posts = Math.round(average / 365) + 'number of posts a day'
        }
    }
    const fgroups = []
    res.render("discover.ejs", {'person': person, 'groups': groups, 'fgroups': fgroups, 'sgroups': sgroups})
})

app.post("/facebook/:id/groups/discover", async (req,res) => {
    const id = req.params.id
    const button = req.body.button
    const group = req.body.group
    if (button) {
        switch (button) {
            case 'discover':
                res.redirect("/facebook/" + id + "/groups/discover")
                break;
            case 'groups':
                res.redirect("/facebook/" + id + "/groups/your-groups")
                break;
            case 'feed':
                res.redirect("/facebook/" + id + "/groups")
                break;
            default:
                throw new Error("Something went wrong")
        }
    } else if (group) {

    } else {
        throw new Error("Something went wrong")
    }
})

app.get("/facebook/:id/events", async (req,res) => {
    const categories = [
        { name: 'Arts & Entertainment', icon: 'fa fa-paint-brush' },
        { name: 'Business', icon: 'fa fa-briefcase' },
        { name: 'Education', icon: 'fa fa-graduation-cap' },
        { name: 'Family & Friends', icon: 'fa fa-users' },
        { name: 'Food & Drink', icon: 'fa fa-glass-martini' },
        { name: 'Health & Wellness', icon: 'fa fa-heartbeat' },
        { name: 'Hobbies', icon: 'fa fa-cogs' },
        { name: 'Music', icon: 'fa fa-music' },
        { name: 'Outdoors', icon: 'fa fa-tree' },
        { name: 'Science & Tech', icon: 'fa fa-flask' },
        { name: 'Sports & Fitness', icon: 'fa fa-dumbbell' },
        { name: 'Travel & Adventure', icon: 'fa fa-plane' },
    ];
    const id = req.params.id
    const user = await getUserSingular(id)
    res.render("events.ejs", {'person':user, 'categories': categories, 'user_events': []})
})

app.get("/", async (req,res) => {
    res.redirect("/facebook/login")
})

app.get("/facebook/login", async (req,res) => {
    res.render("Login.ejs")
})

app.post("/facebook/login", async (req,res) => {
    const email = req.body.email
    const password = req.body.password
    const id = getUserByLogin(email, password)[0].id
    if (id) {
        res.redirect("/facebook/:" + req.body.id)
    } else {
        console.log("Wrong Password")
    }
})

app.get("/facebook/profile/:id", async (req,res) => {
    const id = req.params.id
    const isfriend = await isFriend(loggedIn, id)
    const user = await getUserSingular(id)
    let friends = await findFriends(id).length
    const relationship = await getRelationship(id)
    const activities = await getWorks(id)
    let university = []
    let highschool = []
    let works = []
    for (let activity of activities) {
        if (activity.type === "University") {
            university.push(activity)
        } else if (activity.type === "High School") {
            highschool.push(activity)
        } else {
            works.push(activity)
        }
    }

    let curwork = ''
    let pstwork = ''
    if (works.length >= 2) {
        curwork = works[university.length - 1].position + ' at ' + works[university.length - 1].name
        pstwork = 'Worked at ' + works[university.length - 1].name
    } else if (works.length == 1) {
        curwork = works[0].position + ' at ' + works[0].name
    }

    let currentedu = ''
    if (university.length) {
        if (university[university.length - 1].enddate) {
            currentedu = 'Studies ' + university[university.length - 1].position + ' at ' + university[university.length - 1].name
        } else {
            currentedu = 'Studied ' + university[university.length - 1].position + ' at ' + university[university.length - 1].name
        }
    }
    let school = ''
    if (highschool.length) {
        if (highschool[highschool.length - 1].enddate) {
            school = 'Went to ' + highschool[highschool.length - 1].name
        } else {
            school = 'Goes to ' + highschool[highschool.length - 1].name
        }
    }
    const born = 'Brisbane, Australia'
    const curlive = 'Brisbane, Australia'
    const bio = "Ummm Hello"
    const posts = await getPostsByUser(id)
    for (let post of posts) {
        let user = await getUserSingular(post.userid)
        const date = post.created
        post.created = await determineTime(date)
        post.username = user.fname + ' ' + user.lname
        post.comments = await getCommentsByPost(post.id)
        for (let comment of post.comments) {
            let user = await getUserSingular(comment.userid)
            comment.username = user.fname + ' ' + user.lname
        }
        let likes = await getLikes(post.id)
        if (likes) {
            post.likes = likes.likes
        } else {
            post.likes = 0
        }
    }
    res.render("Profile.ejs", {'person': user, 'posts': posts, 'friends': friends, 'relationship': relationship, 
    'curwork': curwork, 'pstwork': pstwork, 'currentedu': currentedu, 'school': school, 'born': born, 'curlive': curlive, 
    'bio': bio, 'isFriend': isfriend})
})

app.post("/facebook/profile/:id", async (req,res) => {
    const id = req.params.id
    const button = req.body.button
    const comment = req.body.comment
    const like = req.body.like
    if (button) {
        switch (button) {
            case 'posts':
                res.redirect("/facebook/profile/" + id)
                break;
            case 'about':
                res.redirect("/facebook/profile/" + id + "/about")
                break;
            case 'friends':
                res.redirect("/facebook/profile/" + id + "/friends")
                break;
            case 'photos':
                res.redirect("/facebook/profile/" + id + "/photos")
                break;
            case 'videos':
                res.redirect("/facebook/profile/" + id + "/videos")
                break;
            case 'add_friends':
                await addRequest(loggedIn, id)
                console.log("Added friend")
                res.redirect("/facebook/profile/" + id)
                break;
            case 'cancel_request':
                await cancelRequest(loggedIn, id)
                res.redirect("/facebook/profile/" + id)
                break;
        }
    } else if (comment) {
        res.redirect("/facebook/profile/" + id)
    } else if (like) {
        console.log('HERE')
        await addLike(like, userid)
        res.redirect("/facebook/profile/" + id)
    }
    
})

app.get("/facebook/profile/:id/about", async (req,res) => {
    const id = req.params.id
    let friends = await findFriends(id).length
    const user = await getUserSingular(id)
    console.log(user)
    res.render("about.ejs", {'person': user, 'friends': friends})
})

app.post("/facebook/profile/:id/about", async (req,res) => {
    const button = req.body.button2
    const id = req.params.id
    switch (button) {
        case 'Overview':
            res.redirect("/facebook/profile/" + id + "/about")
            break;
        case 'WorkEdu':
            res.redirect("/facebook/profile/" + id + "/about/work-education")
            break;
        case 'Places':
            res.redirect("/facebook/profile/" + id + "/about/places")
            break;
        case 'Contact':
            res.redirect("/facebook/profile/" + id + "/about/contact_and_basic_info")
            break;
        case 'FamRel':
            res.redirect("/facebook/profile/" + id + "/about/Family-Relationship")
            break;
    }
})

app.get("/facebook/friends", async (req,res) => {
    res.render("friends.ejs")
})

app.get("/facebook/profile/:id/friends", async (req,res) => {
    res.render("friends.ejs")
})

app.get("/facebook/profile/:id/photos", async (req,res) => {
    res.render("photos.ejs")
})

app.get("/facebook/profile/:id/videos", async (req,res) => {
    res.render("videos.ejs")
})

app.get("/facebook/profile/:id/about", async (req,res) => {
    const id = req.params.id
    const user = await getUserSingular(id)
    res.render("About.ejs", {'person': user})
})

app.use((err,req,res,next) => {
    console.error(err.stack)
    res.status(500).send('Something broke!')
})

app.listen(8080, () => console.log('Example app listening on port 8080!'))

app.use(express.static("public"))