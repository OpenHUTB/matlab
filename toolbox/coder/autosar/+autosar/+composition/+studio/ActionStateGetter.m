classdef ActionStateGetter<handle





    methods(Static,Access=public)
        function enabled=getStateForAction(actionName,cbinfo)


            import autosar.composition.studio.ActionStateGetter;

            block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);

            switch actionName
            case 'autosarLinkToModelAction'
                enabled=ActionStateGetter.getStateForLinkToModel(block);
            case 'autosarCreateModelAction'
                enabled=ActionStateGetter.getStateForCreateModel(cbinfo);
            case 'autosarImportFromARXMLAction'
                enabled=ActionStateGetter.getStateForImportFromArxml(block,cbinfo);
            case 'autosarExportComponentAction'
                enabled=ActionStateGetter.getStateForExportComponent(block);
            case 'autosarExportCompositionAction'
                enabled=ActionStateGetter.getStateForExportComposition(block);
            case 'autosarSaveAsArchitectureModelAction'
                enabled=ActionStateGetter.getStateSaveAsArchitectureModel(cbinfo);
            otherwise
                assert(false,'Unexpected action');
            end
        end

        function validBlocks=getValidSelectedBlocksForAction(actionName,selection)


            import autosar.composition.studio.ActionStateGetter;

            switch actionName
            case 'autosarCreateModelAction'
                blockStateFcn=@ActionStateGetter.getStateForCreateModelForBlock;
            case 'autosarSaveAsArchitectureModelAction'
                blockStateFcn=@ActionStateGetter.getStateForSaveAsArchitectureModelForBlock;
            otherwise
                assert(false,'Unexpected action');
            end
            validBlocks={};
            for selectionIdx=1:selection.size()
                selectedElement=selection.at(selectionIdx);
                if blockStateFcn(selectedElement)
                    validBlocks{end+1}=selectedElement.handle;%#ok<AGROW>
                end
            end
        end
    end

    methods(Static,Access=private)
        function enabled=getStateForLinkToModel(block)


            enabled=...
            SLStudio.Utils.objectIsValidBlock(block)&&...
            ~autosar.bsw.ServiceComponent.isBswServiceComponent(block.handle)&&...
            (autosar.composition.Utils.isComponentBlock(block.handle)||...
            ((slfeature('SaveAUTOSARCompositionAsArchModel')~=0)&&...
            autosar.composition.Utils.isCompositionBlock(block.handle)));
        end

        function enabled=getStateForCreateModel(cbinfo)

            block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
            if~isempty(block)



                enabled=...
                autosar.composition.studio.ActionStateGetter.getStateForCreateModelForBlock(block);
            elseif~isempty(cbinfo.getSelection)



                selection=cbinfo.selection;
                validComponentBlocks=...
                autosar.composition.studio.ActionStateGetter.getValidSelectedBlocksForAction(...
                'autosarCreateModelAction',selection);
                enabled=~isempty(validComponentBlocks);
            else

                enabled=false;
            end
        end

        function enabled=getStateForCreateModelForBlock(block)
            enabled=SLStudio.Utils.objectIsValidBlock(block)&&...
            autosar.composition.Utils.isCompBlockNonLinked(block.handle)&&...
            ~autosar.bsw.ServiceComponent.isBswServiceComponent(block.handle)&&...
            autosar.composition.Utils.isComponentBlock(block.handle);
        end

        function enabled=getStateForSaveAsArchitectureModelForBlock(block)
            enabled=(slfeature('SaveAUTOSARCompositionAsArchModel')>0)&&...
            SLStudio.Utils.objectIsValidBlock(block)&&...
            autosar.composition.Utils.isCompBlockNonLinked(block.handle)&&...
            ~autosar.bsw.ServiceComponent.isBswServiceComponent(block.handle)&&...
            autosar.composition.Utils.isCompositionBlock(block.handle);
        end

        function enabled=getStateForImportFromArxml(block,cbinfo)
            import autosar.composition.studio.ActionStateGetter
            import Simulink.interface.dictionary.internal.DictionaryClosureUtils



            modelH=cbinfo.studio.App.getActiveEditor.blockDiagramHandle;



            if DictionaryClosureUtils.isModelLinkedToInterfaceDict(modelH)
                enabled=false;
                return;
            end

            importIntoEmptyDiagram=autosar.composition.Utils.isEmptyBlockDiagram(modelH);
            importIntoCompositionBlock=SLStudio.Utils.objectIsValidBlock(block)&&...
            ~autosar.bsw.ServiceComponent.isBswServiceComponent(block.handle)&&...
            autosar.composition.Utils.isCompBlockNonLinked(block.handle)&&...
            autosar.composition.Utils.isCompositionBlock(block.handle)&&...
            autosar.composition.studio.ActionStateGetter.getStateForSaveAsArchitectureModelForBlock(block);

            importIntoComponentBlock=SLStudio.Utils.objectIsValidBlock(block)&&...
            ~autosar.bsw.ServiceComponent.isBswServiceComponent(block.handle)&&...
            autosar.composition.Utils.isCompBlockNonLinked(block.handle)&&...
            autosar.composition.Utils.isComponentBlock(block.handle);

            enabled=importIntoEmptyDiagram||...
            importIntoCompositionBlock||...
            importIntoComponentBlock;
        end

        function enabled=getStateForExportComponent(block)

            enabled=(SLStudio.Utils.objectIsValidBlock(block)&&...
            autosar.composition.Utils.isCompBlockLinked(block.handle))&&...
            ~autosar.bsw.ServiceComponent.isBswServiceComponent(block.handle);
        end

        function enabled=getStateForExportComposition(block)

            enabled=(SLStudio.Utils.objectIsValidBlock(block)&&...
            autosar.composition.Utils.isCompositionBlock(block.handle));
        end

        function enabled=getStateSaveAsArchitectureModel(cbinfo)


            block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
            if~isempty(block)



                enabled=...
                autosar.composition.studio.ActionStateGetter.getStateForSaveAsArchitectureModelForBlock(block);
            elseif~isempty(cbinfo.getSelection)



                selection=cbinfo.selection;
                validCompositionBlocks=...
                autosar.composition.studio.ActionStateGetter.getValidSelectedBlocksForAction(...
                'autosarSaveAsArchitectureModelAction',selection);
                enabled=~isempty(validCompositionBlocks);
            else

                enabled=false;
            end
        end
    end
end


