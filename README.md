PagerDuty-Dashing
=================

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy?template=https://github.com/omareo/pagerduty_dashing)



A [Dashing][dashing] dashboard for PagerDuty Services!

* Show the number of triggered incidents using the [hotness widget][hotness].


Getting Started
===============

The easiest way to get started is to use Heroku button above to launch your dashboard. You will need to fill out the following environment variables in Heroku so your Dashing dashboard can communicate to the PagerDuty API.

| Environment Variable | Example |
| :----------------- |:-----------------|
| PAGERDUTY_URL | https://yoursubdomain.pagerduty.com |
| PAGERDUTY_APIKEY | Your api key (this can be a read only key) |
| PAGERDUTY_SERVICES | {"services": { "staging": "ABC1234","preprod": "QAZ4567","production": "EDC4321"}} |
| PAGERDUTY_SCHEDULES | {"schedules": { "oncall": "PVW1X30","firefighter": "PSY8CSC"}} | 

FAQ
====
### Where can I see what the IDs are for my services/schedules?
Clicking on a Service/Schedule in PagerDuty will show you the ID in the URL. On that note you will want to adjust the .erb files to match your environment.

### Why do I need to format my Services/Schedules like that?
The Services/Schedules need to be in JSON format.  In order for Heroku to accept them, they need to contain no line breaks.

[dashing]: http://shopify.github.io/dashing/
[hotness]: https://github.com/gottfrois/dashing-hotness