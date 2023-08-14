classdef CreateAndLink<handle




    methods(Static,Access=public)


        function createModelForComp(blkH)
            try
                if~iscell(blkH)

                    autosar.composition.studio.CompBlockCreateModel.launchDialog(blkH);
                elseif length(blkH)>1


                    for blkIdx=1:length(blkH)
                        converter=autosar.composition.studio.CompBlockCreateModel(blkH{blkIdx});
                        modelNameToCreate=...
                        autosar.composition.studio.CompBlockCreateModel.getDefaultMdlName(blkH{blkIdx});
                        [isValid,msgId,msg]=converter.convert(modelNameToCreate);
                        if~isValid


                            mexcept=MException(msgId,...
                            msg);
                            mexcept.throw();
                        end
                    end
                else
                    assert(false,'Expected at least one block handle');
                end
            catch mException

                sldiagviewer.reportError(mException);
                return;
            end
        end


        function importCompFromARXML(slSourceH)
            try
                autosar.composition.studio.CompImport.importFromArxml(slSourceH);
            catch mException

                sldiagviewer.reportError(mException);
                return;
            end
        end



        function linkCompToModel(blkH)
            try
                autosar.composition.studio.CompBlockReferenceModel.launchDialog(blkH);
            catch mException

                sldiagviewer.reportError(mException);
                return;
            end
        end



        function exportComponentBlock(blkH)
            try
                isLinked=autosar.composition.Utils.isCompBlockLinked(blkH);
                assert(isLinked,'export component is only supported for linked component blocks');
                isCompositionExport=false;
                autosar.composition.studio.ExportDialog.launchDialog(blkH,isCompositionExport);
            catch mException

                sldiagviewer.reportError(mException);
                return;
            end
        end


        function exportCompositionBlock(blkH)
            try
                isCompositionExport=true;
                autosar.composition.studio.ExportDialog.launchDialog(blkH,isCompositionExport);
            catch mException

                sldiagviewer.reportError(mException);
                return;
            end
        end


        function exportRootModel(bdHandle)
            try
                isCompositionExport=true;
                autosar.composition.studio.ExportDialog.launchDialog(bdHandle,isCompositionExport);
            catch mException

                sldiagviewer.reportError(mException);
                return;
            end
        end
    end
end


