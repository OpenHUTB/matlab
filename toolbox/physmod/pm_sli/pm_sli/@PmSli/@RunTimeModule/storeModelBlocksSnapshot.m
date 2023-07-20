function success=storeModelBlocksSnapshot(this,hModel)







    success=true;




    blockList=this.getBlocksToSnapshot(hModel);
    numBlocks=numel(blockList);
    blockObjects=get_param(blockList,'Object');
    if~iscell(blockObjects)
        blockObjects={blockObjects};
    end
    errorBlocks='';
    for idx=1:numBlocks
        aBlock=blockObjects{idx};
        if~this.snapshotBlock(aBlock)

            success=false;
            errorBlocks=[errorBlocks,sprintf('%s\n',sanitizeName(aBlock.Name))];

            break

        end

    end

    if~success

        configData=RunTimeModule_config;
        pm_error(configData.Error.CannotSnapshotBlocks_templ_msgid,errorBlocks);

    end


