# every DSC file must have one main Configuration function
Configuration MyExample
{

  # import necessary modules
  Import-DscResource -Module PSDesiredStateConfiguration

  # define the 'node' using the target machine's name
  # in this case, localhost
  Node localhost
  {

    # define configurations for target machine

    # create a text file at C:\temp\hello.txt
    File myFile {
      Ensure          = 'Present'
      Contents        = 'Hello World'
      DestinationPath = 'C:\temp\hello.txt'
      Type            = 'File'
    }

  }

}

# compile above configuration into .mof file
MyExample