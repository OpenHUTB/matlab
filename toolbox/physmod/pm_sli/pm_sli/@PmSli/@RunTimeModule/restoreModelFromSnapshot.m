function success=restoreModelFromSnapshot(this,hModel,ignoreMissingBlocks)















    success=true;

    blockList=this.getModelBlockSnapshots(hModel);
    numSnapshots=length(blockList);

    for j=1:numSnapshots

        success==success&&restoreParams(blockList(j),ignoreMissingBlocks);

    end

    success=success&&this.clearModelSnapshot(hModel);


    function success=restoreParams(blockData,ignoreMissing)


        aBlock=blockData.block;
        snapshot=blockData.data;

        if isprop(aBlock,'Handle')


            if~isempty(snapshot)&&(numel(aBlock.MaskEnables)==numel(snapshot.enables))
                aBlock.MaskEnables=snapshot.enables;
            end

        else
            if~ignoreMissing

                configData=RunTimeModule_config;
                pm_error(configData.Error.CannotRestoreParams_templ_msgid,...
                sanitizeName(aBlock.Name),...
                pm_message([configData.EditingMode.ValueLabel_msgidprfx,EDITMODE_USING]));

            end
        end

        success=true;




