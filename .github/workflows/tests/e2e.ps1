function e2e ($branchToTest, $solutionName, $environmentUrl, $sourceBranch, $branchToCreate, $commitMessage) {
    $jsonTemplate = '
    {
        "solution_name":"$solutionName", 
        "environment_url":"$environmentUrl",
        "source_branch":"$sourceBranch",
        "branch_to_create":"$branchToCreate",
        "commit_message":"$commitMessage"
    }'
    $json = $ExecutionContext.InvokeCommand.ExpandString($jsonTemplate)
    $workflowFile = "export-unpack-commit-solution.yml"
    echo $json | gh workflow run $workflowFile --ref $branchToTest --json
    Start-Sleep -s 15
    $workflowRunsJson = gh run list --workflow=$workflowFile --json databaseId,headBranch,status
    $workflowRunsArray = ConvertFrom-Json $workflowRunsJson
    $testRun = $workflowRunsArray.Where({$_.headBranch -eq $branchToTest -and $_.status -in "in_progress","queued"})[0]
    gh run watch $testRun.databaseId
    $status = gh run view $testRun.databaseId --exit-status
    echo ($status -join '').Contains('exit code 1')
    if ($status.Contains('exit code 1')) {
        return false
    }
}