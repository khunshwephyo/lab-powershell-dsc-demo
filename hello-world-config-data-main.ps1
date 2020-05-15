# config data is simply a hash table with some specific Keys

$configData = @{

  # AllNodes key must present
  # AllNodes value is an array of one or more hash tables
  # each hash table under AllNodes must have key called NodeName
  AllNodes = @(

    # config data for all target servers
    @{
      NodeName = '*'

      SoftwareInstallers = 'c:\installers'
      
      # you can add more nested hash tables, don't abuse this flexibility!
      WebApps = @{

        # load config data for my-web-app
        MyWebApp = $(&'.\hello-world-config-data-my-web-app.ps1').Dev
      }

      Jobs = @{
        # load config data for my-task
        MyJob = $(&'.\hello-world-config-data-my-job.ps1').Dev
      }
    },

    # config data specific to server 'localhost'
    @{
      NodeName = 'localhost'
    }

    # config data specific to 'server1'
    @{
      NodeName = 'server1'
    }

    # config data specific to 'server2'
    @{
      NodeName = 'server2'
    }
    
  )

}

return $configData