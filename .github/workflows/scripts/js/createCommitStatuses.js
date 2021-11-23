module.exports = async ({ solutionNamesString }) => {
    console.log(solutionNamesString)

    let solutionNamesArray = solutionNamesString.split(",")

    await solutionNamesArray.forEach(createCommitStatus)

    async function createCommitStatus(solutionName) {
        let contextToUse = "build-deploy-" + solutionName

        await github.rest.repos.createCommitStatus({
            owner: context.repo.owner,
            repo: context.repo.repo,
            sha: context.payload.pull_request.head.sha,
            context: contextToUse,
            state: "pending"
        })
    }
}