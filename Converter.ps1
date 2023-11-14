param (
    # The path to search for files
    [string]$Path = '.',
)
function DeclareFuncRefactoring {
    param (
        $file
    )
    $fileContent = Get-Content -Path $file.FullName

    # Define the patterns for arrow function expressions
    $arrowFunctionPatterns = @(
        'const (\w+) = (\(.*?\)) => {',
        'const (\w+) = (\(.*?\)):(.+?) => {'
    )

    # Define a function to convert arrow function expression to function declaration
    function ConvertToFunctionDeclaration {
        param($match)

        $functionName = $match.Groups[1].Value
        $parameters = $match.Groups[2].Value
        $returnType = if ($match.Groups[3].Success) { ": $($match.Groups[3].Value)" } else { '' }

        # Build the function declaration
        $functionDeclaration = "function $functionName$parameters$returnType {"

        return $functionDeclaration
    }

    # Replace arrow function expressions with function declarations
    # foreach ($pattern in $arrowFunctionPatterns) {
		# $replacement = ConvertToFunctionDeclaration $pattern
        # $fileContent = $fileContent -replace $pattern, $replacement
    # }
	$searchExp1 = 'const (?<FunctionName>\w+) = (?<Parameters>\(.*?\)):(?<ReturnType>.+?) => {'
	$replaceExp1 = 'function ${FunctionName}${Parameters} : ${ReturnType} {'
	$searchExp2 = 'const (?<FunctionName>\w+) = (?<Parameters>\(.*?\)) => {'
	$replaceExp2 = 'function ${FunctionName}${Parameters} {'
	$fileContent = $fileContent -replace $searchExp1, $replaceExp1
	$fileContent = $fileContent -replace $searchExp2, $replaceExp2

    # Write the modified content back to the file
    $fileContent | Set-Content -Path $file.FullName
}
function ExecuteDeclareFuncRefactoring {
    foreach ($file in $files) {
        # Check if the file extension is .tsx
        if ($file.Extension -eq '.tsx') {
            DeclareFuncRefactoring $file
        }
    }
}
$Extension = '*.tsx'

# Get all files with the specified extension in the specified path
$files = Get-ChildItem -Path $Path -Filter $Extension -Recurse -File

ExecuteDeclareFuncRefactoring
Write-Host "Conversion complete."
