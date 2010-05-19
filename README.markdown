# Wap Profiler

Wap Profiler is a simple web service to detect the features of a mobile handset.

## Awesome. So how does it work?

The majority of recent handsets pass a [UAProf](http://www.developershome.com/wap/detection/detection.asp?page=uaprof) header with all HTTP requests (assuming it isn't blocked by the operator). This can be used to identify a handset and its specific features. The header that is passed links to a RDF document detailing the features of the ahndset.

This is a much better way than using just a User-Agent string, as (for the majority of phones) the User-Agent changes even between software versions. You also cannot retrive information given just a User-Agent string, however with a UAProf string you can.

## So what do I do?

Extract the x-wap-profiler header from your request. It is most likely in one of these formats:

    x-wap-profile:  "http://nds1.nds.nokia.com/uaprof/N5800XpressMusicr100-2G.xml"
    x-wap-profile:  http://www.htcmms.com.tw/Android/Common/HTC_TATTOO_A3288/ua-profile.xml

It may also be like this though:

    x-wap-profile: "http://motorola.handango.com/phoneconfig/v3r/Profile/v3r.rdf", "1-UGzHaoF+GBG1GnN8r0MxBw==", "2-XnrTOLDzBJdZHN2vSasoNA==", "3-HC5l5j+eQ9tPRpdhsseJIQ=="

We only need the first parameter, so the following regex can be used to match the correct part:

    /x-wap-profile: "?([^\s"]+)"?/i

Once you've got this you can make a HTTP request to the application:

    GET /uaprof?uri=http://nds1.nds.nokia.com/uaprof/N5800XpressMusicr100-2G.xml

Do not URL encode it!

You will then get a response back near enough instantly. If everything is well you will get a JSON encoded object containing details of the handset (only JSON is supported for now):

    HTTP/1.1 200 OK

    {"uri":"http://nds1.nds.nokia.com/uaprof/N5800XpressMusicr100-2G.xml","status":"processed","width":"360","height":"640","created_at":"2010-05-05 21:08:33 UTC","updated_at":"2010-05-05 21:20:56 UTC"}

If the server doesn't yet have details of the UAProf you have sent you will get a HTTP 202 header back. This means it has accepted your request, but hasn't retrived the data yet. After the daemon processes the pending UAProf, when you make the next request you will get a proper response back. If you recieve this response you should assume some sensible defaults.

  HTTP/1.1 202 Accepted

  {"uri":"http://nds1.nds.nokia.com/uaprof/N5800XpressMusicr100-2G.xml","status":"pending","width":null,"height":null,"created_at":"2010-05-05 21:08:33 UTC","updated_at":"2010-05-05 21:08:33 UTC"}

## What else?

It uses Redis as a backend so it super fast. Due to the design of the application (and return 202 responses when the data is not available) requests made should be very fast. As such it should be fine to use in your production application with 100 requests / second.

The daemon is designed to be as simple as possible, and forks so that multiple requests can be made simultaneously (there are plans to use Event Machine in the future). It can process approximately 1500 pending UAProfs in 10 mins, however this is dependant on your internet connection.

Once again, due to the design of the application, if the data stored in Redis is lost it isn't the end of the world. New UAProfs will be populated as requested.

## Running it

In development mode:

    redis-server config/redis/development.conf
    ruby lib/daemons/processor_daemon.rb
    thin start

## Authors

* Luca Spiller

## License

See LICENSE.markdown.
