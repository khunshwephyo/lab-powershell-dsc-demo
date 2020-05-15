function MyWebApp {
  
  return @{
    Name           = 'my-web-app' 
    CopyFrom       = 'c:\my-sources\my-web-app'
    CopyTo         = 'c:\projects\my-web-app' 
    WebSite        = 'Default Web Site' 
    Pool           = 'my-web-app-pool' 
    PoolState      = 'Started'
    Pipeline       = 'Integrated' 
    Allow32Bit     = $false 
    Runtime        = 'v4.0' 
  }
  
}

$project = @{
  Dev = MyWebApp
}

return $project