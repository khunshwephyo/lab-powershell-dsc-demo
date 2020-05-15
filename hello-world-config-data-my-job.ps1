function MyJob {
    
  return @{
    TaskPath          = '\TP'
    TaskName          = 'my-task'
    Description       = 'dummy scheduled task for demo purpose with pull client'
    ActionExecutable  = 'c:\projects\my-project\my-test.exe'
    ActionWorkingPath = 'c:\projects\my-project'
    ActionArguments   = $null
    Enable            = $false
    ExecuteAsGMSA     = $null
    ScheduleType      = 'Daily'
    DaysOfWeek        = $null
    StartTime         = '2019-12-12T07:00:00'
  }
}

$project = @{
  Dev = MyJob
}

return $project