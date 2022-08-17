& 'GLOBAL VARIABLE STATEMENT'
$chartPath = "PATH TO CHARTS"

#grabs files in folder, converts filename to variable and splits that string into date pieces, adds increment to avoid non-unique file names. 
$files = Get-ChildItem -path $chartPath

#hashtable to check for duplicates
$hashes = @{}
$key    = 0

foreach($file in $files){
    $docType = ""
    $orignalName = ""
    if($hashes.ContainsValue((Get-FileHash $file).Hash)){
        Remove-Item -Path $file.PSPath
    }

    else{
        $hashes.Add($key,(Get-FileHash $file).Hash)
        $originalName = [System.IO.Path]::GetFileName($file)
        #read file line by line, break after matching doc type. 
        foreach($line in [System.IO.File]::ReadLines($file)){
           if($line -match "Nurse's Notes"){
                $docType = "nurse_note"
                break
           }
           if($line -match "Physician Documentation"){
                $docType = "physician_note"
                break
           }
        }

        #split and reconstruct name.
        $nameComponents    = $originalName.Split("_")
        $nameComponents[0] = "ER"
        $nameComponents[1] = "Claxton_Chart"
        $nameComponents[3] = $nameComponents[3] -replace '[.TXT]' 
        $newName = [system.String]::Join("_",$nameComponents)+"_"+$docType+".TXT"

        if(Test-Path "$chartPath/$newName"){
            Remove-Item -Path $file.PSPath
        }

        else{
            Rename-Item -Path $file.PSPath -NewName $newName
        }                
    }
    $key++
}

Move-Item   -Path $chartPath -Destination {DESTINATION}
