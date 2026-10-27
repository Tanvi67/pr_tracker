const mongoose = require('mongoose');

async function run() {
  await mongoose.connect('mongodb+srv://satyampr56_db_user:7cs2q2Xvvp4cmDRg@cluster0.ulgcsaw.mongodb.net/?appName=Cluster0');
  console.log('connected');
  try {
    const db = mongoose.connection.db;
    await db.collection('users').dropIndex('email_1');
    console.log('index dropped');
  } catch (e) {
    console.log('error dropping index', e.message);
  }
  process.exit(0);
}
run();
