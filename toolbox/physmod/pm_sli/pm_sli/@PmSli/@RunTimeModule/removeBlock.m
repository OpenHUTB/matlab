function removeBlock(this,hBlock)



    ;


    [editingMode,isLibrary]=this.getModelEditingMode(hBlock);

    if isLibrary

        pm_assert(this.isLibraryBlock(hBlock));
        this.getLicenseOrFail(hBlock,'NoLicenseToRemoveLibraryBlock_templ_msgid');

    else

        switch editingMode

        case EDITMODE_USING

            configData=RunTimeModule_config;
            pm_error(configData.Error.CannotRemoveInUsingMode_msgid);

        case EDITMODE_AUTHORING

            this.getLicenseOrFail(hBlock,'NoLicenseToRemoveBlock_templ_msgid');

        end


        mdl=getBlockModel(hBlock);
        [opData,mdlIdx]=this.modelRegistry.getModelOperationData(mdl);
        if opData.blocksPerformingOperation==hBlock
            opData.blocksPerformingOperation=[];
            this.modelRegistry.modelInfo(mdlIdx).modelOperation=opData;
        end

    end




