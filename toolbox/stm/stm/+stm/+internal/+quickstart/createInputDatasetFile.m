function returnList=createInputDatasetFile(modelName,harnessName,filePath,sheetName)





    if(nargin<4)
        sheetName='';
    end


    [modelToUse,deactivateHarness,currHarness,oldHarness,~,wasHarnessOpen]=stm.internal.util.resolveHarness(modelName,harnessName);

    returnList=saveModelInputsHelper(modelToUse,filePath,sheetName);


    if~isempty(currHarness)
        close_system(currHarness.name,0);

        if(deactivateHarness)
            stm.internal.util.loadHarness(oldHarness.ownerFullPath,oldHarness.name,wasHarnessOpen);
        end
    end

end


function inpList=saveModelInputsHelper(modelToUse,filePath,sheetName)

    ds=createInputDataset(modelToUse);

    varStruct=struct('VarName','ds','VarValue',ds);
    sigMetadata=stm.internal.util.getSigMetadata(varStruct);


    [~,~,ext]=fileparts(filePath);
    if(strcmpi(ext,'.mat'))
        save(filePath,'ds');
    else
        xls.internal.util.writeDatasetToSheet(ds,filePath,sheetName,'',...
        xls.internal.SourceTypes.Input);
    end

    sigNames={sigMetadata.SignalLabel};

    inpList=struct(...
    'Name',sigNames,...
    'BlockPath',''...
    );

    for idx=1:length(sigNames)
        blkName=inpList(idx).Name;
        if~isempty(sigMetadata(idx).LeafBusPath)
            tmp=strsplit(sigMetadata(idx).LeafBusPath,'.');
            blkName=tmp{1};
        end



        blkName=strrep(blkName,'/','//');

        inpList(idx).BlockPath=[modelToUse,'/',blkName];
    end

end