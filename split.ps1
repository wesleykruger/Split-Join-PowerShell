param ([string]$path,
[int]$chunkSize)

function split($path, $chunkSize)
{
    if (-not (Test-Path -path $path)) {
        throw [System.IO.FileNotFoundException] "$path not found."
    }

    Write-Output $path
    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($path)
    $directory = [System.IO.Path]::GetDirectoryName($path)
    $extension = [System.IO.Path]::GetExtension($path)

    $digitCount = 0

    $reader = [System.IO.File]::OpenRead($path)
    $count = 0
    $buffer = New-Object Byte[] $chunkSize
    $hasMore = $true
    while($hasMore)
    {
        $countString = $digitCount.ToString()
        $bytesRead = $reader.Read($buffer, 0, $buffer.Length)
        $chunkFileName = "$directory\$fileName$extension.$countString.part"
        $chunkFileName = $chunkFileName -f $count
        $output = $buffer
        if ($bytesRead -ne $buffer.Length)
        {
            $hasMore = $false
            $output = New-Object Byte[] $bytesRead
            [System.Array]::Copy($buffer, $output, $bytesRead)
        }
        [System.IO.File]::WriteAllBytes($chunkFileName, $output)
        ++$count
        $digitCount++
    }

    $reader.Close()
}

split $path $chunkSize