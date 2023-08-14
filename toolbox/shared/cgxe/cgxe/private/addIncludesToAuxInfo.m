function auxInfo=addIncludesToAuxInfo(auxInfo,headerFiles)

    numAux=numel(auxInfo.includeFiles);
    for hIdx=1:numel(headerFiles)
        auxInfo.includeFiles(numAux+hIdx).FileName=headerFiles{hIdx};
        auxInfo.includeFiles(numAux+hIdx).FilePath='';
        auxInfo.includeFiles(numAux+hIdx).Group='';
    end
end