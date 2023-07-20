



classdef Wizard<dds.internal.ui.app.base.GuiBase

    properties
ImportProperties
DDConn
ComponentName
VendorName
VendorKey
DictionaryPath
        BrowseButtonPressed=false
        VendorSupportsIDLAndXML=false
    end

    properties(Constant,Access=private)
        GuiTag='Tag_DDS_Wizard';
    end

    methods
        function obj=Wizard(manager,model)









            obj.Manager=manager;

            if ischar(model)


                [~,model]=fileparts(model);
            end


            [obj.ComponentName,obj.VendorName,obj.VendorKey,obj.DDConn]=...
            dds.internal.simulink.Util.getCurrentMapSetting(model);


            obj.ModelHandle=get_param(model,'Handle');





            obj.ImportProperties=false;


            ID=['/dds-quickstart/',get_param(obj.ModelHandle,'Name')];
            title=DAStudio.message('dds:toolstrip:uiQuickStartTitle');
            obj.Gui=dds.internal.ui.app.base.Gui(obj,ID,obj.GuiTag,title);



            schemaVersionHandler=dds.internal.SchemaVersionHandler.instance();
            schemaVersionHandler.setSchemaVersion(get_param(obj.ModelHandle,'Version'));
            obj.CloseListener=Simulink.listener(obj.ModelHandle,'CloseEvent',@obj.CloseForGuiCB);
        end

        function xmlSelect(obj)
            q=obj.CurrentQuestion;
            if~strcmp(q.Id,'Properties')
                return
            end
            if obj.BrowseButtonPressed
                return
            else
                obj.BrowseButtonPressed=true;
                clnUp=onCleanup(@()dds.internal.ui.app.quickstart.Wizard.resetBrowseButton(obj));
            end
            if obj.VendorSupportsIDLAndXML
                [xmlFiles,folder]=uigetfile({'*.idl;*.xml','IDL and XML Files (*.idl, *.xml)';'*.idl','IDL Files (*.idl)';'*.xml','XML Files (*.xml)'},'MultiSelect','on');
            else
                [xmlFiles,folder]=uigetfile({'*.xml','XML Files (*.xml)'},'MultiSelect','on');
            end
            if~iscell(xmlFiles)&&~ischar(xmlFiles)

                return
            end
            o=q.Options{4};
            if~endsWith(folder,filesep)
                folder=[folder,filesep];
            end
            o.resetValue();
            if iscell(xmlFiles)&&numel(xmlFiles)>1
                o.Value.file=xmlFiles;
                o.Value.folder={};
                for i=1:numel(xmlFiles)
                    o.Value.folder{i}=folder;
                end
            else
                o.Value.file{1}=xmlFiles;
                o.Value.folder={};
                o.Value.folder{1}=folder;
            end
            q.IsNextEnabled=true;
            obj.Gui.sendQuestion(q);
        end

        function dataDictionarySelect(obj)
            q=obj.CurrentQuestion;
            if~strcmp(q.Id,'Properties')
                return
            end
            if obj.BrowseButtonPressed
                return
            else
                obj.BrowseButtonPressed=true;
                clnUp=onCleanup(@()dds.internal.ui.app.quickstart.Wizard.resetBrowseButton(obj));
            end
            [slddFile,folder]=uigetfile({'*.sldd','SLDD Files (*.sldd)'},'MultiSelect','off');
            if~iscell(slddFile)&&~ischar(slddFile)

                return
            end
            o=q.Options{2};
            o.Value.file=slddFile;
            o.Value.folder=folder;
            q.IsNextEnabled=true;
            obj.Gui.sendQuestion(q);
        end

        function closeWizard=finish(obj)
            closeWizard=true;
            finishQuickStart(obj);
        end

        function finishQuickStart(obj)
            modelName=get_param(obj.ModelHandle,'Name');

            Simulink.output.Stage(...
            message('dds:toolstrip:uiWizardFinishMessage',obj.VendorName).getString(),...
            'ModelName',modelName,'UIMode',true);

            obj.start_spin();
            c=onCleanup(@()obj.stop_spin());
            try
                dds.internal.simulink.Util.setupModelForDDS(modelName,...
                obj.DDConn.filepath,obj.ComponentName,obj.VendorKey);
            catch ex
                errordlg(ex.message,...
                obj.Gui.Title,'replace');
            end
            obj.DDConn=[];
        end

        function start(obj)

            obj.init();
            obj.CurrentQuestion=obj.getQuestion('Component');
        end

        function toggleApp(~,cbinfo,appName)
            studio=cbinfo.studio;
            ed=cbinfo.EventData;

            if isempty(ed)
                st=true;
            elseif isnumeric(ed)||islogical(ed)
                st=ed;
            elseif ischar(ed)
                st=true;
            end

            c=dig.Configuration.get();
            app=c.getApp(appName);

            if~isempty(app)
                contextManager=studio.App.getAppContextManager;
                customContext=contextManager.getCustomContext(app.name);
                if st
                    if isempty(customContext)
                        contextProvider=app.contextProvider;
                        customContext=feval(contextProvider,app,cbinfo);
                    end
                    customContext.openApp(cbinfo,app,contextManager,customContext);
                else
                    contextManager.deactivateApp(app.name);
                    cp=simulinkcoder.internal.CodePerspective.getInstance;
                    cp.close(studio);
                end
            end
        end
    end

    methods(Access=protected)
        function init(obj)



            obj.QuestionMap=containers.Map;
            obj.OptionMap=containers.Map;


            dds.internal.ui.app.question.Component(obj);
            dds.internal.ui.app.question.Properties(obj);
            dds.internal.ui.app.question.Finish(obj);
        end
    end

    methods(Static)





        function resetBrowseButton(varargin)
            if nargin>0
                obj=varargin{1};
                if isvalid(obj)
                    obj.BrowseButtonPressed=false;
                end
            end
        end
    end
end


