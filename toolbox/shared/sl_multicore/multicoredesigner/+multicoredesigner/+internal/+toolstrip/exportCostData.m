function exportCostData(cbinfo)




    model=cbinfo.model.Name;

    [matFile,matFilePath]=uiputfile('*.mat','Select a MAT File');
    if matFile==0
        return
    end

    mfModel=get_param(model,'MulticoreDataModel');
    mc=slmulticore.MulticoreConfig.getMulticoreConfig(mfModel);
    blocks=mc.blocks.toArray;

    blockPath={};
    costVal=[];

    for b=blocks
        blockPath=[blockPath;b.path];
        if b.allowUserCost==1
            costVal=[costVal;b.userCost];
        else
            costVal=[costVal;b.cost];
        end
    end
    costData=table(blockPath,costVal);

    save(fullfile(matFilePath,matFile),'costData')


