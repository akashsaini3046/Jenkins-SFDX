#!groovy

node {

    def SF_CONSUMER_KEY=env.SF_CONSUMER_KEY
    def SF_USERNAME=env.SF_USERNAME
    def SERVER_KEY_CREDENTIALS_ID=env.SERVER_KEY_CREDENTIALS_ID
    def TEST_LEVEL='%TestLevel%'
    def SF_INSTANCE_URL = env.SF_INSTANCE_URL ?: "https://login.salesforce.com"


    def toolbelt = tool 'toolbelt'

    stage('Clean Workspace') {
        try {
            deleteDir()
        }
        catch (Exception e) {
            println('Unable to Clean WorkSpace.')
        }
    }
    // -------------------------------------------------------------------------
    // Check out code from source control.
    // -------------------------------------------------------------------------

    stage('checkout source') {
        checkout scm
    }


    // -------------------------------------------------------------------------
    // Run all the enclosed stages with access to the Salesforce
    // JWT key credentials.
    // -------------------------------------------------------------------------

 	withEnv(["HOME=${env.WORKSPACE}"]) {	
	
	    withCredentials([file(credentialsId: SERVER_KEY_CREDENTIALS_ID, variable: 'server_key_file')]) {
		// -------------------------------------------------------------------------
		// Authenticate to Salesforce using the server key.
		// -------------------------------------------------------------------------

		stage('Authorize to Salesforce') {
			rc = command "${toolbelt}/sfdx auth:jwt:grant --instanceurl ${SF_INSTANCE_URL} --clientid ${SF_CONSUMER_KEY} --jwtkeyfile ${server_key_file} --username ${SF_USERNAME} --setalias SFDX"
		    if (rc != 0) {
			error 'Salesforce org authorization failed.'
		    }
		}


		// -------------------------------------------------------------------------
		// Deploy metadata and execute unit tests.
		// -------------------------------------------------------------------------
		
		stage('Delta changes'){
		   bat 'sfdx sfpowerkit:project:diff --revisionfrom %PreviousCommitId% --revisionto %LatestCommitId% --output DeltaChanges'
	    }
		

     		// -------------------------------------------------------------------------
	    		// Example shows how to run a check-only deploy.
	   			// -------------------------------------------------------------------------

		stage('Deploy and Run Tests') {
		    rc = command "${toolbelt}/sfdx force:source:deploy -p DeltaChanges/force-app --wait 10 --targetusername SFDX"
		}
	}		    
	  
	}
}

def command(script) {
    if (isUnix()) {
        return sh(returnStatus: true, script: script);
    } else {
		return bat(returnStatus: true, script: script);
    }
}
