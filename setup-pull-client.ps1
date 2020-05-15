# for pull client, you need [DscLocalConfigurationManager()]
# change CertificateID with your target Pull Server's certificate thumbprint value
# change pull server URL with your target Pull Server host name and port
[DscLocalConfigurationManager()]
Configuration MyExample
{
  Node 'localhost'
  {
    Settings {
      RefreshMode          = 'Pull'
      ConfigurationMode    = 'ApplyAndAutoCorrect'
      CertificateID        = '662083F811541A37E3BF5D769EC707D414AE40CB'
      RebootNodeIfNeeded   = $true
      AllowModuleOverwrite = $true
    }

    ConfigurationRepositoryWeb ConfigurationManager {
      ServerURL          = 'https://w16app:4431/PSDSCPullServer.svc'
      RegistrationKey    = '2d776741-33dd-4935-b90f-c3fa287b80cd'
      CertificateID      = '662083F811541A37E3BF5D769EC707D414AE40CB'
      ConfigurationNames = 'localhost'
    }

    ReportServerWeb ReportManager {
      ServerURL = 'https://w16app:4431/PSDSCPullServer.svc'
    }
  }
}

# compile above configuration into .mof file
MyExample
