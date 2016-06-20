Youserve
================
Please read the Developer's Guidebook to understand how to make contributions on the YouServe codebase. This information is to be found on the YouServe wiki hosted on Github.
-----------
Developer's Guidebook: Roadmap YouServe Production Release Summer 2016
========================================================================
Tomahawk edited this page 27 days ago · 6 revisions
 Pages 2
Developer's Guidebook: Roadmap YouServe Production Release Summer 2016
YouServe Development Wiki
 Add a custom sidebar
Clone this wiki locally


https://github.com/YouServe/YouServe.wiki.git
 Clone in Desktop

https://github.com/YouServe/YouServe/wiki

Welcome to the YouServe release for Summer 2016!

There are four things you need to know.

Open Issues
The open issues to work on are found here:

Summer 2016 Release Milestone

Mockups
To work on the issue, you will need access to the mockups, which are hosted on Balsamiq. Sign up for a Balsamiq account then send Eric your username and email address, and we'll give you access to the mockups. The mockups live here: https://youserve.mybalsamiq.com/projects/youservenew/grid

Committing Code
You'll want to commit your code to the "testing" branch, from which, after the issue has been tested, the master branch admin will merge to master and release into production.

Here is the "testing" branch: YouServe Testing

Stack
We are going to be using Ruby on Rails, along with ReactJS and Foundation as the SCSS framework of choice. Here are some highly recommended tutorials to get you going: http://facebook.github.io/react/docs/tutorial.html http://tutorials.jumpstartlab.com/paths/advanced_rails_five_day.html http://foundation.zurb.com/sites/docs/v/5.5.3/

Feel free to reach out on email: tmutunhire@gmail.com and let me know your thoughts on the project or tasks, or anything related to code or design. Have fun coding!

=================================================

Technical Notes And Gotchas
===========================================
Integrating Foundation, CoffeeScript, Turbolinks and JQuery
---------------------------

-this can be a problematic combination to debug. In particular, components made with Foundation and utilizing Foundation's JS functions will simply fail to function.
-the problem seems to be that Turbolinks messes up with the normal chain of page loading events that jQuery expects, and this then messes up Foundation.
-also, when using CoffeeScript, the syntax gets a bit convoluted to work with jQuery events and Turbolinks correctly
-I have documented before a fix to these things, check this commit in particular: https://github.com/YouServe/YouServe/commit/51c525bb8344bd34d1ebd4b218d6fc52ad4546f3
-Here is the gist:
Place …
…event handlers and jquery initialization inside a jquery call and condition, not on page ready but rather on $(document).on(page:load, function(){}); where the function is what you want to occur, see the code
  => In application.js:
  // This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require foundation-datetimepicker
//= require chosen-jquery
//= require scaffold
//= require jquery-ui/datepicker
//= require tinymce-jquery
//= require social-share-button
//= require turbolinks
//= require foundation
//= require_tree .
// $(function() {
//   $(document).foundation();
// });
// http://stackoverflow.com/questions/25150922/trouble-using-foundation-and-turbolinks-with-rails-4
$(document).foundation();

$(document).off().on('page:load', function() {
    console.log( "ready!" );
    $(document).foundation();
});

=>in your code, with Coffeescript, and using a Foundation component, using JS:
jQuery ->
 $('#project_expires_at').datepicker()
 alert("yo we should activate foundation")
 $(document).foundation()

 #attach handlers to data attributes
 $("button[data-makes-editable]").off().on "click", (e)->
   e.preventDefault()
   projectId = $(this).data("makes-editable")
   makeEditable(projectId)

 $("button[data-accepts-edit]").off().on "click", (e)->
   e.preventDefault()
   projectEditId = $(this).data("accepts-edit")
   updateEdit(projectEditId, "accepted")

 $("button[data-rejects-edit]").off().on "click", (e)->
   e.preventDefault()
   projectEditId = $(this).data("rejects-edit")
   updateEdit(projectEditId, "rejected")

  $(document).on 'page:load', ->
       console.log( "readyp!" )
       #attach handlers to data attributes
       $("button[data-makes-editable]").off().on "click", (e)->
         e.preventDefault()
         projectId = $(this).data("makes-editable")
         makeEditable(projectId)

       $("button[data-accepts-edit]").off().on "click", (e)->
         e.preventDefault()
         projectEditId = $(this).data("accepts-edit")
         updateEdit(projectEditId, "accepted")

       $("button[data-rejects-edit]").off().on "click", (e)->
         e.preventDefault()
         projectEditId = $(this).data("rejects-edit")
         updateEdit(projectEditId, "rejected")



[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

This application was generated with the [rails_apps_composer](https://github.com/RailsApps/rails_apps_composer) gem
provided by the [RailsApps Project](http://railsapps.github.io/).

Rails Composer is supported by developers who purchase our RailsApps tutorials.
-------------------

Need help? Ask on Stack Overflow with the tag 'railsapps.'

Your application contains diagnostics in the README file. Please provide a copy of the README file when reporting any issues.

If the application doesn't work as expected, please [report an issue](https://github.com/RailsApps/rails_apps_composer/issues)
and include the diagnostics.

Ruby on Rails
-------------

This application requires:

- Ruby 2.2.1
- Rails 4.2.5.1

Learn more about [Installing Rails](http://railsapps.github.io/installing-rails.html).

Getting Started
---------------

Documentation and Support
-------------------------

Issues
-------------

Similar Projects
----------------

Contributing
------------

Credits
-------

License
-------
