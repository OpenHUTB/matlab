function addBlock(this,hBlock,isLoading)




    ;

    if nargin<2
        isLoading=false;
    end



    if this.isExaminingModel(this.getBlockDiagram(hBlock))

        return;
    end

    [editingMode,isLibrary]=this.getModelEditingMode(hBlock);

    if isLibrary

        pm_assert(this.isLibraryBlock(hBlock));
        this.getLicenseOrFail(hBlock,'NoLicenseToAddLibraryBlock_templ_msgid');

    else

        if isLoading

            switch editingMode

            case EDITMODE_USING





                if~this.isModelPreRtm(this.getBlockDiagram(hBlock));
                    if~this.snapshotBlock(hBlock)

                        configData=RunTimeModule_config;
                        pm_error(configData.Error.CannotSnapshotBlocks_templ_msgid,sanitizeName(hBlock.Name));

                    end
                end

            case EDITMODE_AUTHORING

                product=this.determineBlockProduct(hBlock);

            end

        else

            switch editingMode

            case EDITMODE_USING

                configData=RunTimeModule_config;
                pm_error(configData.Error.CannotAddInUsingMode_msgid);

            case EDITMODE_AUTHORING

                this.getLicenseOrFail(hBlock,'NoLicenseToAddBlock_templ_msgid');


                this.registerModel(this.getBlockDiagram(hBlock));

            end

        end

    end



