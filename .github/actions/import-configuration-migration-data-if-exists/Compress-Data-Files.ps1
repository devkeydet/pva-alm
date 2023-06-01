function Compress-Data-Files ($configPath, $tempConfigurationMigrationDataFolder, $environment) {
    $commonFolderName = "CommonConfigurationMigrationData"
    $commonPath = $configPath + $commonFolderName    

    New-Item -Path $tempConfigurationMigrationDataFolder -ItemType Directory

    if (Test-Path $commonPath) {
        $destinationPath = $tempConfigurationMigrationDataFolder + $commonFolderName + '.zip'
        $compress = @{
            Path             = $commonPath + '\*.*'
            CompressionLevel = 'Fastest'
            DestinationPath  = $destinationPath
        }
        Compress-Archive @compress

        #echo "::set-output name=common_zip_path::$destinationPath"
        echo "common_zip_path=$destinationPath" >>$GITHUB_OUTPUT 
    }
    else {
        echo "No $commonFolderName folder found."
    }

    if ($environment -notin "pr", "uat", "prod") {
        $environment = "dev"
    }

    $environmentFolderName = "EnvironmentConfigrationMigrationData"
    $environmentPath = $configPath + $environmentFolderName + "/$environment"

    if (Test-Path $environmentPath) {
        $destinationPath = $tempConfigurationMigrationDataFolder + $environmentFolderName + '.zip'
        $compress = @{
            Path             = $environmentPath + '\*.*'
            CompressionLevel = 'Fastest'
            DestinationPath  = $destinationPath
        }
        Compress-Archive @compress

        echo "::set-output name=environment_zip_path::$destinationPath"
    }
    else {
        echo "No $environmentFolderName folder found."
    }
}