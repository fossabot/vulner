## EventDetection Starter Application for Bluemix Streaming Analytics
This sample demonstrates how to use the Streaming Analytics service in conjunction with a Bluemix application.
The project contains both a Bluemix application and a Streams application.

#### Bluemix Application
The Bluemix application is written in Node.js using the SDK for Node.js runtime in Bluemix.  It uses the Streaming Analytics REST API to submit an analytic application to Streams and displays results on a web page.

#### Streams Application
The Streams application performs event detection against a feed of weather data and sends its results to the Node.js application.  A pre-compiled copy of the Streams application is provided in the root folder of this project as `EventDetection.sab`.  The source code for the Streams application is contained in the `spl` folder.

#### Getting ready to run the sample

To run the EventDetection, you will need to perform the following actions if you have not already done so:
1. Sign up for [Bluemix](https://ace.ng.bluemix.net/) and log in.

2. [Install the Bluemix command-line tool](https://console.bluemix.net/docs/cli/index.html#cli).

3. Create an application in the Bluemix web portal using the **SDK for Node.js** runtime. Remember the name you give your application, you will need it later on. 

4. Create a Streaming Analytics service in the Bluemix web portal

5. Connect your application to your Streaming Analytics instance using the "Connect existing" button on your application's Overview page.



#### Pushing the EventDetection starter application to Bluemix

After you perform the steps above, you are ready to download and push the starter application to Bluemix:

1. Download the [EventDetection.zip](https://streams-github-samples.mybluemix.net/?get=QuickStart/EventDetection) file.

2. After the download completes, extract the .zip file.

3. **Important:** Rename the root directory of the extracted zip to match the name you gave your application in Bluemix.
		
4. On the command line, `cd` to the renamed directory. For example:

		cd myapp
		
5. Connect to Bluemix:

		cf api https://api.ng.bluemix.net

6. Log into Bluemix and set your target org when prompted:

		cf login

7. Deploy your app.  For example:

		cf push myapp

8. Access your Node.js application by clicking on `Visit App URL` near the top of your application's detail page in Bluemix.


