function saveFile(fileName,data,modelName)




    assert(isfield(data,'designChecksum')==0);
    data.designChecksum=incrementalcodegen.IncrementalCodeGenDriver.hashEntireDesign(modelName,...
    @qoroptimizations.getModelGenStatusDataForOptimization);
    save(fileName,'-struct','data');
end