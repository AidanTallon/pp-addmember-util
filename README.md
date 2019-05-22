# Installation

## ChromeDriver

To run the scripts, you will need a chromedriver.exe on your PATH
http://chromedriver.chromium.org/downloads

## Install ruby via chocolatey

If you do not have chocolatey, please see this page on getting started
https://chocolatey.org/docs/installation#installing-chocolatey

Now run this:
`choco install ruby --version 2.4.2.2`

## Installing required rubygems

We need the ruby gem bundler (this will handle installing all the other gems for us)
`gem install bundler`

For some reason, we also need the `qtbindings` gem for the GUI library
`gem install qtbindings`

We now use the bundler gem to install the remaining gems:
navigate to the directory of the project `pp-addmember-util`
then run
`bundle install`

# Running

navigate to the directory of the project `pp-addmember-util`
`ruby ./app.rb`

If you encounter any errors, please try the command
`bundle install`
and then `ruby ./app.rb` again

# Useage

Set the URL and username / login for Backoffice in the Settings - Config menu
Select a preset on the left, or select each value for your member from the corresponding box
You can save the values you have entered as a new preset
The consumers last name is always generated randomly
Clicking Add Member will launch ChromeDriver and add the member via the backoffice UI, then the member will be listed in the listbox on the right.
You can mouseover the member to get a quick look at some more of the members details (web pin, membership number, etc)
Click 'Copy to Clipboard' to copy the members details in a list format

You can click Add Member multiple times to launch ChromeDriver in parallel and add the members simultaneously -- but please be gentle!


TODO -

- extract widgets into separate classes
- class for accessing yaml
- central place to store constants like path to yaml file
- layout
- cross platform kill chromedriver support
- remember configs? - envs, users etc
- kill specific chrome process from window
- better way of viewing details of added member
- prevent interaction with main widget when dialogs open
- error handling when adding member with empty fields
