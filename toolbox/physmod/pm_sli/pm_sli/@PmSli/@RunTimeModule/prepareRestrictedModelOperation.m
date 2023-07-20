function prepareRestrictedModelOperation(this,block,operation_id)









    trace;

    if~this.isLibraryBlock(block)












        if this.blockIsTriggeringModelOperation(block)

            mdl=getBlockModel(block);
            editingMode=this.getModelEditingMode(mdl);






            this.setBlockCheckedModelOperation(block,operation_id);





            if~this.validatePlatformLicense
                cannotPerformOperation(operation_id,'NoPlatformProductLicense_msgid');
            end




            this.validateLibraryLinks(mdl);






            if strcmp(operation_id,'compile')&&strcmp(editingMode,EDITMODE_AUTHORING)
                this.setBlockCheckedModelOperation(block,operation_id);
                return;
            end




            [products,pmBlocks,flags]=this.determineModelProducts(mdl);
            blocksToSnapshot=pmBlocks(flags);



            actualTopologyChecksum=this.computeModelTopologyChecksum(pmBlocks);
            actualParameterChecksum=this.computeModelParameterChecksum(blocksToSnapshot);

            switch editingMode
            case EDITMODE_USING


                [cachedTopologyChecksum,cachedParameterChecksum]=this.getCachedModelChecksum(mdl);
                if cachedTopologyChecksum~=actualTopologyChecksum
                    cannotPerformOperation(operation_id,'IllegallyChangedTopology_msgid');
                end







                if actualParameterChecksum~=cachedParameterChecksum
                    blockNames='';
                    blockObjects=get_param(blocksToSnapshot,'Object');
                    if~iscell(blockObjects)
                        blockObjects={blockObjects};
                    end
                    for idx=1:numel(blocksToSnapshot)
                        aBlock=blockObjects{idx};
                        hasSnapshotComparisonFailed=~this.compareBlockToSnapshot(aBlock);
                        if hasSnapshotComparisonFailed
                            blockNames=sprintf([blockNames,'''%s''\n'],sanitizeName(aBlock.Name));
                        end
                    end
                    if isempty(blockNames)
                        cannotPerformOperation(operation_id,'InconsistentLibraryBlock_templ_msgid');
                    else


                        cannotPerformOperation(operation_id,'IllegallyChangedBlockParameters_templ_msgid',blockNames);
                    end
                end

            case EDITMODE_AUTHORING


                this.getProductLicenses(products);

            end

            this.storeModelProducts(mdl,products);
            this.storeCachedModelChecksum(mdl,actualTopologyChecksum,actualParameterChecksum);
            this.writeCachedDataToModel(mdl);

        end

    else

        this.getLicenseOrFail(block,'NoLicenseToSaveLibraryBlock_templ_msgid');

    end

    function cannotPerformOperation(operation_id,explanation_id,varargin)
        configData=RunTimeModule_config;
        errorData=configData.Error;
        restrictedOperation=configData.ModelOp.Label;

        explanation_msgid=errorData.(explanation_id);
        operation_msgid=restrictedOperation.(operation_id);
        pm_error(errorData.IllegalUsingModeOperation_templ_msgid,...
        pm_message(operation_msgid),...
        pm_message(explanation_msgid,varargin{:}));



