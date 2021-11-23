function Start-Build-Deploy-Solution ($files, $githubRef, $prHeadRef, $githubSha, $prHeadSha, $solutionVersionMajorMinor, $environment) {
    echo "files: $files"
    $filesArray = $files -split ','

    $solutionDirectoriesArray = [System.Collections.ArrayList]::new()

    foreach ($file in $filesArray) {         
        if ($file.StartsWith("src/") -And $file.Contains("SolutionPackage")) {
            $solutionDirectory = "{0}/{1}/{2}" -f $file.Split('/')
            $solutionDirectoriesArray.Add($solutionDirectory)
        }        
    }

    $uniqueSolutionDirectories = $solutionDirectoriesArray | Sort-Object | Get-Unique

    $solutionNameArray = @()

    foreach ($dir in $uniqueSolutionDirectories) {            
        $solutionName = $dir.Replace("src/", "").Replace("/SolutionPackage", "")
        $solutionNameArray = $solutionNameArray + $solutionName

        if ($githubRef.Contains("pull")) {
            $ref = $prHeadRef
        }
        else {
            $ref = $githubRef
        }

        echo "github_ref: $githubRef"
        echo "ref: $ref"
        echo "sha: $githubSha"
        echo "github.event.pull_request.head.sha: $prHeadSha"

        gh workflow run build-deploy-solution --ref $ref -f ref=$githubRef -f solution_name=$solutionName -f solution_version_major_minor=$solutionVersionMajorMinor -f environment=$environment -f sha=$prHeadSha
            
        echo "pipeline queued for $solutionName"           
    }

    $csv = $solutionNameArray -join ","
    echo "::set-output name=solution_names::$csv"
}