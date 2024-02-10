export async function determineTime(d) {
    const today = new Date()
    const date = new Date(d)
    console.log(date)
    if (today.getFullYear() === date.getFullYear()) {
        if (today.getDay() - 7 >= date.getDay()) {
            if (today.getDay() == date.getDay() || (today.getDay() + 1 == date.getDay() && today.getHours() <= date.getHours()) || (today.getDay() - 1 == date.getDay() && today.getHours() >= date.getHours())) {
                if (today.getHours() == date.getHours()) {
                    return today.getMinutes() - date.getMinutes() + " minutes ago"
                } else {
                    return today.getHours() - date.getHours() + " hours ago"
                }
            } else {
                return today.getDay() - date.getDay() + " days ago"
            }
        } else {
            return date.getDate() + " " + date.getMonth() + " " + date.getMinutes() + ":" + date.getSeconds()
        }
    } else {
        return date.getDate() + " " + date.getMonth() + " " + date.getFullYear()
    }
}

console.log(determineTime('2023-02-0811:36:00Z'))