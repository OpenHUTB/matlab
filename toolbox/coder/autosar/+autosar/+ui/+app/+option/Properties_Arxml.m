



classdef Properties_Arxml<autosar.ui.app.base.OptionBase
    methods
        function obj=Properties_Arxml(env)





            id='Properties_Arxml';
            obj@autosar.ui.app.base.OptionBase(id,env);

            obj.OptionMessage=DAStudio.message('autosarstandard:ui:uiWizardArxmlFiles');

            obj.DepInfo=struct('Option','Properties_Import','Value',true);
            obj.Indent=1;

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

                return
            end
            files=fullfile(obj.Value.folder,obj.Value.file);
            if isempty(files)
                ret=-1;
                errordlg(DAStudio.message('autosarstandard:ui:uiWizardArxmlEmptyError'),...
                autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                return
            end
            try
                importer=arxml.importer(files);
                compList=importer.getComponentNames;
            catch mException

                ret=-1;
                obj.Value.file=[];
                obj.Value.folder='';
                obj.Env.ImportProperties=false;
                sldiagviewer.reportError(mException);
            end
            if~isempty(compList)&&~obj.Env.IsSubComponent

                errordlg(DAStudio.message('autosarstandard:ui:uiWizardArxmlComponentsError'),...
                autosar.ui.metamodel.PackageString.ErrorTitle,'replace');
                return;
            end
            obj.Env.ArxmlImporter=importer;
            obj.Env.ImportProperties=true;
        end

    end
end


