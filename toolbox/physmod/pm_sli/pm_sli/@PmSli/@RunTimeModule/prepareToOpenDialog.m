function prepareToOpenDialog(this,hBlock)





    if~this.isDiagramLocked(hBlock)

        if this.isLibraryBlock(hBlock)

            this.getLicenseOrFail(hBlock,'NoLicenseToModifyLibraryBlock_templ_msgid');

        else

            if strcmp(this.getModelEditingMode(hBlock),EDITMODE_USING)

                paramModeData=this.blockGetParameterModes(hBlock);


                if isempty(paramModeData)
                    whichSelected=[];
                else
                    whichParamModeData=strcmp(PARAM_AUTHORING,{paramModeData.editingMode});
                    authoringParamModeData=paramModeData(whichParamModeData);

                    whichSelected={authoringParamModeData.maskName};
                end

                maskNames=hBlock.MaskNames;
                maskEnables=hBlock.MaskEnables;

                [newMaskEnables,authoringParam]=turnOffSelectedEnables(maskNames,maskEnables,whichSelected);
                changedParams=getIllegallyChangedParams(this,hBlock,authoringParam);
                if~isempty(changedParams)
                    config=RunTimeModule_config;
                    pm_error(config.Error.IllegallyChangedDlgParams_templ_msgid,changedParams);
                end

                hBlock.MaskEnables=newMaskEnables;

            else


                this.getLicenseOrFail(hBlock,'NoLicenseToModifyBlock_templ_msgid');

            end

        end

    end


    function changedParams=getIllegallyChangedParams(this,hBlock,entriesToMatch)

        snapshot=this.getBlockSnapshot(hBlock);
        if isempty(snapshot)


            changedParams={};
            return;
        end
        snapValues=snapshot.values;
        snapValues={snapValues{entriesToMatch}};

        blockValues=hBlock.MaskValues;
        blockValues={blockValues{entriesToMatch}};

        cmp=strcmp(snapValues,blockValues);
        agree=all(cmp);


        if agree
            changedParams='';
        else

            maskPrompts=hBlock.MaskPrompts;
            maskPrompts={maskPrompts{entriesToMatch}};
            maskPrompts=maskPrompts(~cmp);
            changedParams=sprintf('''%s''\n',maskPrompts{:});

        end




