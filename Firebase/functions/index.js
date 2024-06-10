const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

// This will run when a row is changed that matches this pattern
exports.onUserToDelete = functions.database.ref('//users_to_delete/{rowId}/{userId}')
  .onCreate((snapshot, context) => {  
  	
  	const userId =  snapshot._data
  	const pathToDelete = "/meal_list/"+userId
  	const pathDeleteUserInfo =  "/users/"+userId
  	const pathToDeleteTrigger =  "/users_to_delete/"+context.params.rowId

  	// Delete user record from Authentication
    admin.auth().deleteUser(userId)
        .then(() => {
            console.log('User Authentication record deleted');
            return;
        })
        .catch(() => console.error('Error while trying to delete the user', err));

    admin.database().ref(pathDeleteUserInfo).remove();
    admin.database().ref(pathToDeleteTrigger).remove();

  	return admin.database().ref(pathToDelete).remove();
});

  exports.onUserToCreate = functions.database.ref('//users_to_create/{rowId}')
  .onCreate((snapshot, context) => {  
  	
  	const userData = snapshot._data

  		//Create user
  	    admin.auth().createUser({
		  email: userData.email,
		  password: userData.password
		})
		  .then(function(userRecord) {
		    // See the UserRecord reference doc for the contents of userRecord.
		    console.log("Successfully created new user:", userRecord.uid);
		    
		    // Add user info
		    const pathCreateUserInfo =  "/users/"+userRecord.uid  
		    const userInfo = {"email" : userData.email, 
		    					"username" : userData.username, 
		    					"dailyCalories" : userData.dailyCalories, 
		    					"roles" : userData.roles}
		    admin.database().ref(pathCreateUserInfo).set(userInfo)

		    // Remove trigger
		    const pathToDeleteTrigger =  "/users_to_create/"+context.params.rowId
		    admin.database().ref(pathToDeleteTrigger).remove();
		    return 1;
		  })
		  .catch(function(error) {
		    console.log("Error creating new user:", error);
		  });

  	return 1;
});

   Date.prototype.yyyymmdd = function() {
  var mm = this.getMonth() + 1; // getMonth() is zero-based
  var dd = this.getDate();

  return [this.getFullYear(),
          (mm>9 ? '' : '0') + mm,
          (dd>9 ? '' : '0') + dd
         ].join('');
};


exports.getCaloriesUser = functions.https.onCall((data, context) => {

  const userId = data.userId;

    // Checking attribute.
  if (!(typeof userId === 'string') || userId.length === 0) {
    // Throwing an HttpsError so that the client gets the error details.
    throw new functions.https.HttpsError('invalid-argument', 'The function must be called with ' +
        'one arguments "userId"');
  }

  const sanitizedMessage = sanitizer.sanitize(userId); // Sanitize the message.
  const pathMeals =  "/meal_list/"+userId
  const pathMealsRef = admin.database().ref(pathMeals);
  var caloriesPerDay = {};
  var total = 0;

  return pathMealsRef.once('value').then(snapshot => {
    console.log(snapshot)
    snapshot.forEach(function(meal) {

      const mealKcal = meal.child("kcalAmount").val();
      const mealDateTimestamp = meal.child("date").val();
      const mealDate = new Date(mealDateTimestamp*1000);
      const mealDateString = mealDate.yyyymmdd();

      if (caloriesPerDay.hasOwnProperty(mealDateString)) {
        caloriesPerDay[mealDateString] = caloriesPerDay[mealDateString] + mealKcal;       
      } else {
        caloriesPerDay[mealDateString] = mealKcal
      }
    });

    return null;
  })
  .then(() => {
    console.log('Calories Fetched');
    return caloriesPerDay;
  })
  .catch((error) => {
    // Re-throwing the error as an HttpsError so that the client gets the error details.
    throw new functions.https.HttpsError('unknown', error.message, error);
  });
});
