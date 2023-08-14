



classdef ImportCompFromArxml_FileSelect<autosar.ui.app.base.OptionBase

    methods
        function obj=ImportCompFromArxml_FileSelect(env)





            id='ImportCompFromArxml_FileSelect';
            obj@autosar.ui.app.base.OptionBase(id,env);

            obj.OptionMessage=DAStudio.message('autosarstandard:ui:uiWizardArxmlFiles');

            obj.Type='file';
            obj.Value={};
            obj.Value.file=[];
            obj.Value.folder='';
            obj.Value.browse='arxmlSelect';
            obj.Answer=true;
        end

        function ret=onNext(obj)


            ret=0;
            if isempty(obj.Value.file)

                ret=-1;
                mException=MException('autosarstandard:ui:uiImporterNoFileSelected',...
                DAStudio.message('autosarstandard:ui:uiImporterNoFileSelected'));
                sldiagviewer.reportError(mException);
                return
            end
            files=fullfile(obj.Value.folder,obj.Value.file);
            if isempty(files)
                ret=-1;
                mException=MException('autosarstandard:ui:uiWizardArxmlEmptyError',...
                DAStudio.message('autosarstandard:ui:uiWizardArxmlEmptyError'));
                sldiagviewer.reportError(mException);
                return
            end
            try

                obj.Env.start_spin();
                importer=arxml.importer(files);
                if isa(obj.Env,'autosar.ui.app.import.ComponentImportWizard')
                    allComponents=importer.getComponentNames;


                    adaptiveComponentQNames=importer.getComponentNames('AdaptiveApplication');
                    classicComponentQNames=setdiff(allComponents,adaptiveComponentQNames);
                    if obj.Env.isParentAdaptiveArch()

                        compQNames=adaptiveComponentQNames;
                        componentType='adaptive';
                    else

                        compQNames=classicComponentQNames;
                        componentType='classic';
                    end
                else
                    assert(isa(obj.Env,'autosar.ui.app.import.CompositionImportWizard'),...
                    'Unexpected class type: %s.',class(obj.Env));
                    compQNames=importer.getComponentNames('Composition');
                end
                obj.Env.stop_spin();
            catch mException

                ret=-1;
                obj.Value.file=[];
                obj.Value.folder='';
                obj.Env.stop_spin();
                sldiagviewer.reportError(mException);
                return
            end


            if isempty(compQNames)
                ret=-1;
                if isa(obj.Env,'autosar.ui.app.import.ComponentImportWizard')
                    errorId='autosarstandard:ui:uiImporterARXMLHasNoComponents';
                    modelType=componentType;
                else
                    errorId='autosarstandard:ui:uiImporterARXMLHasNoCompositions';
                    if obj.Env.isParentAdaptiveArch()
                        modelType='adaptive';
                    else
                        modelType='classic';
                    end
                end
                mException=MException(errorId,DAStudio.message(errorId,modelType));
                sldiagviewer.reportError(mException);
                return
            end

            obj.Env.setArxmlImporter(importer);
            obj.Env.setCompNames(compQNames);
        end

    end
end


