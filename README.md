# Project - Kcal Logger

*Sample project for the TopTal Interview Process*

The project was developed in Swift, for iOS (iPhone), and makes use of Firebase for the backend (authentication and database).

Swift 4.2 / iOS 12 / XCode 10.1

External libraries used:
*  Firebase
*  KRProgressHUD
*  Quick and Nimble (testing suite)

**To install the pods run** `pod install` on the project source folder.

The project is built and ran through XCode.

**Pagination implementation**:

Has the pagination implementation, altough functional, didn't show a 100% aceptable performance it's now available on the `development` branch.
It can be found on the `feature/pagination` branch [here](https://git.toptal.com/Peter-Hussami/project---luis-machado/tree/feature/pagination)

**Test user**:
Username: toptal@email.com
PWD: qwerty1234

Possible improvements to the code base:
*  Reachability and offline functionality
*  Improved test coverage (currently 83.1%)
*  Improved multi filter (both date and time) through data denormalization on the database
*  [DONE] Calorie counting, per day, done server-side (by exposing a firebase function as a api endpoint) 
*  Improved performance with pagination, by managing the table data source more efficiently.
