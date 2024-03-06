# Butterfly Technical Challenge

## Developer Notes

### Running Instructions
No specific action is required to run the project.
- The dependencies are managed via Swift Package Manager, which will install them upon project opening;
- To check code coverage, run all tests (cmmd + U) on the main target (ButterflyChallenge);

### About the Project
- This project was built following the IMBD app as a reference, a simpler and similar UI was built following it;
- The two screens (MoviesList and MovieDetails) are split by folders, but if necessary they could be moved into separate targets, by extracting what is common between them;
- Modular: the project was built keeping on mind the modules decoupling, and using POP to make it easier to inject/modify behavior, while empowering tests;
- URL Requests caching: done by using the default cache behavior from the shared URLSession (useProtocolCachePolicy), where is uses the caching logic defined by the protocol implementation (HTTP and HTTPS caching are built in the protocol so the server is able to determine when the client should cache and when it expire);

#### Movies List
- Developed using Storyboard for the UI;
- UI Architecure used is MVVM, using power of closures to bind the view and the viewmodel;
- A MVC pattern is used for managing the cells lifecycle;

#### Movie Details
- Developed using SwiftUI;
- UI Architecture used is MVVM, using power of observable objects to bind the view and viewmodel; 

#### Tests
The test strategy adopted was to focus more on Integration Tests, which cover most of the desirable behaviors and interaction between the multiple objects. 
This way its possible to test how the components involved in rendering screens interact with each other, by mocking url requests responses to mimic real life behavior, with Protocols making sure the signature expected is respected.
For testing the Movies List, the library ViewInspector was used to be able to access the views properties, since Apple still does not provide support.

### Whats Next?
This is a small project that has unlimited potential for building new features, like the following that could be built:
- Movies List Pagination: to build this one we could extract the MovieCellController signature into a protocol, and create a new concrete type which would render the loading cell at the bottom of the view, and let the view model decide when this cell controller should be inserted in the tablemodels, in the last position.
- Favorites List: could be done by creating a new object to conform with the protocol MoviesDataLoader, but which would load from a local persistence, and also create a new protocol to define the storing mechanism signature, while having the concrete type defined and injected in the new Favorites screen. The Movies List screen would be responsible for inserting/removing movies in the local storage and the Favorites screen would be reading those values and possibly editing them too.
- Offline mode: create a new protocol, or use the same for Favorites List, to store and retrieve the movies list. Create them a new object responsbile for deciding when to load/save movies locally and when to load from server, inject this new object in the Movies List screen via property moviesLoader on MoviesListViewModel.
- Localization: make all texts localizable and add tests to make sure all texts are localized in all supported languages.
- Improve UI/UX by adding a more complex, friendly and interactive UI.
- Enable certificate pinning and remove sensitve hard-coded data from project (api key and services url).

## Assignment Description

You have been tasked with creating a simple iOS app that allows users to search for movies and view their details. The app should make use of the Movie Database API (https://www.themoviedb.org/documentation/api) to retrieve movie information.

### Requirements

[] The app should have two screens: a search screen and a details screen.
[] The search screen should have a search bar that allows the user to search for movies by title. The search results should be displayed in a table view.
[] The table view should display the movie title, release date, and poster image.
[] The details screen should display additional information about the selected movie, including the movie title, release date, poster image, and overview.
[] The app should cache search results for offline use.
[] The app should handle error cases gracefully and provide feedback to the user when necessary.

### Bonus points:
[] Implement pagination in the search results table view.
[] Allow users to save movies to a favorites list.
[] Add unit tests and UI tests for your code.
[] Offline mode: the app can persist the data previously fetched and see them when the app is opened in offline mode. 

### Deliverables:
[] A working iOS app that meets the above requirements.
[] A README file with instructions for building and running the app.
[] A brief write-up describing the decisions you made while building the app, any challenges you faced, and how you overcame them.
[] Your source code, preferably hosted on a public repository such as GitHub.

### Evaluation:
[] Your submission will be evaluated based on the following criteria:
[] Functionality: Does the app meet the specified requirements?
[] Code quality: Is the code clean, readable, and maintainable?
[] Design: Is the app well-designed and easy to use?
[] Performance: Does the app perform well and handle large datasets efficiently?
[] Bonus points: Did you implement any of the bonus requirements?
