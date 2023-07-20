function saveMetaData(this,inputIndex)




    metaSuffix='_meta.mat';
    outputSuffix='_output.mat';
    outputFilename=this.OutputData(inputIndex).filename;
    if strfind(outputFilename,outputSuffix)
        outputFilename=strrep(outputFilename,outputSuffix,metaSuffix);
    else
        outputFilename=strrep(outputFilename,'.mat',metaSuffix);
    end
    MetaFile=fullfile(this.OutputDir,outputFilename);
    this.MetaData(inputIndex).metaFileName=MetaFile;
    cs=getActiveConfigSet(this.ModelName);
    this.MetaData(inputIndex).configset=cs.copy();

    meta=this.MetaData(inputIndex);%#ok<NASGU>
    save(MetaFile,'meta');

