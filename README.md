# Sermon Publisher

The Covid-19 pandemic is forcing churches to find new ways to engage with their members. Sermon publisher allows pastors to publish sermons to the Internet from their mobile phones. It has two components: A mobile app for the pastor to publish sermons. And a public website for people to listen to the sermons.

## Pastor App

The pastor app has a login screen, a list of sermons and a form for uploading new sermons. Pastors notify their audience that a new sermon is available by sharing the link via WhatsApp, SMS, Email etc.

## Public Website
The public website allows visitors to browse through the list of sermons and listen to a sermon. It is a website build using NodeJS and Express.

## Technical Details

I love light weight, simple and efficient tools.

I built the pastor app using Flutter. I used Google authentication which makes things easier for developer and user. This was easy to implement thanks to google_sign_in. The first step in the sermon publish process is to select an audio file from the device filesystem. This took a bit of time to get right. When the pastor presses the upload button the sermon metadata (title, author, date etc) is uploaded to Firebase Firestore and the sermon audio file is uploaded to Firebase Storage. I also added a screen to allow pastors to keep an eye on hosting costs.

The public website is built using NodeJS, Express, Pug templates and Bootstrap and hosted using Heroku.
