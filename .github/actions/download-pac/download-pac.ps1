# TODO: Make PowerShell Function
#NOTE: Add new versions of canvas unpack and the associated pac CLI version to the versionDictionary to ensure unpacked versions are packed correctly.
# $versionDictionary = @{ "0.24" = "1.9.4"}
# $nugetPackage = "Microsoft.PowerApps.CLI"
# $nugetPackageVersion = '${{ pac_version }}'
# if('${{ parameters.canvasUnpackVersion }}' -ne '') {
#     $nugetPackageVersion = $versionDictionary['${{ parameters.canvasUnpackVersion }}']
# }
# elseif($nugetPackageVersion.Contains("pacVersion")) {
#   $nugetPackageVersion =  ""
# }
# $outFolder = "${{ runner.temp }}/pac"
# if($nugetPackageVersion -ne '') {
#     nuget install $nugetPackage -Version $nugetPackageVersion -OutputDirectory $outFolder
# }
# else {
#     nuget install $nugetPackage -OutputDirectory $outFolder
# }
# $pacNugetFolder = Get-ChildItem $outFolder | Where-Object {$_.Name -match $nugetPackage + "."}
# $pacPath = $pacNugetFolder.FullName + "\tools"
# echo "::set-output name=path::$pacPath"
echo "hi there"