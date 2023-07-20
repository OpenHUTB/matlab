classdef CompImport<handle




    methods(Static)

        function importFromArxml(slSourceH)


            autosar.api.Utils.autosarlicensed(true);

            if strcmp(get_param(slSourceH,'Type'),'block_diagram')||...
                autosar.composition.Utils.isCompositionBlock(slSourceH)
                autosar.composition.studio.CompImport.importCompositionFromArxml(slSourceH);
            else
                autosar.composition.studio.CompImport.importComponentFromArxml(slSourceH);
            end
        end
    end

    methods(Static,Access=private)
        function importComponentFromArxml(slSourceH)





            compBlkH=get_param(slSourceH,'Handle');
            autosar.ui.app.import.CompImportWizardManager.importWizard(compBlkH);
        end

        function importCompositionFromArxml(slSourceH)




            slSourceH=get_param(slSourceH,'Handle');

            if strcmp(get_param(slSourceH,'Type'),'block')

                assert(autosar.composition.Utils.isEmptyCompositionBlock(slSourceH),...
                'Cannot import into a non-empty composition: %s',getfullname(slSourceH));
            else

                assert(strcmp(get_param(slSourceH,'Type'),'block_diagram'),...
                '%s is not a block diagram!',getfullname(slSourceH));
                assert(autosar.composition.Utils.isEmptyBlockDiagram(slSourceH),...
                '%s is not empty!',getfullname(slSourceH));
            end


            autosar.ui.app.import.CompImportWizardManager.importWizard(slSourceH);
        end
    end
end



