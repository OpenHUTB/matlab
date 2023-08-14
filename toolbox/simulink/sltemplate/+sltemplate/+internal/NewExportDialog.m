classdef NewExportDialog<handle





    properties(Access=private)
        DialogTitle;
        DialogDimensions;
        Browser;
        Channel;
        Subscriptions;
    end

    events
        DialogClosed;
    end

    properties(GetAccess=public,SetAccess=private)
        ModelName;
        ModelHandle;
        ModelType;
        DialogType;
        ExportToTemplateURL;
        DebugPort;
    end

    methods(Access=public)
        function obj=NewExportDialog(modelName,varargin)
            connector.ensureServiceOn;
            sltemplate.internal.utils.logDDUX("ExportToTemplate");

            p=inputParser;
            p.addParameter('Debug',false,@islogical);
            p.addParameter('DebugPort',[]);
            p.addParameter('DialogType',"Export",@(x)isstring(validatestring(x,["Edit","Export","SaveAs"])));
            p.addParameter('ExternalBrowser',[],@(b)isa(b,'sltemplate.internal.Browser'));
            p.parse(varargin{:});

            obj.ModelName=get_param(modelName,'Name');
            obj.ModelHandle=get_param(modelName,'Handle');
            obj.ModelType=get_param(modelName,'BlockDiagramType');
            obj.ModelType(1)=upper(obj.ModelType(1));
            obj.DialogType=p.Results.DialogType;

            obj.DialogTitle=obj.makeDialogTitle();
            obj.DialogDimensions.Width=650;
            obj.DialogDimensions.Height=400;
            obj.DialogDimensions.MinWidth=obj.DialogDimensions.Width;
            obj.DialogDimensions.MinHeight=obj.DialogDimensions.Height;

            if~isempty(p.Results.ExternalBrowser)
                obj.Browser=p.Results.ExternalBrowser;
                obj.Browser.URL=obj.makeExportURL(p.Results.Debug);
            else
                obj.Browser=sltemplate.internal.DialogWebBrowser(...
                obj.DialogTitle,...
                obj.makeExportURL(p.Results.Debug),...
                'Dimensions',obj.DialogDimensions,...
                'AllowResize',true,...
                'CloseFunction',@obj.close,...
                'DebugPort',p.Results.DebugPort);

                obj.DebugPort=obj.Browser.DebugPort;
            end

            obj.ExportToTemplateURL=obj.Browser.getAbsoluteURL;
            obj.Browser.show();


            Simulink.addBlockDiagramCallback(obj.ModelName,'PreDestroy',...
            'ExportTemplate',@()obj.close());
        end

        function show(obj)
            obj.Browser.show();
        end

        function validFlag=isOpen(obj)
            validFlag=obj.Browser.validateBrowser();
        end

        function obj=close(varargin)
            obj=varargin{1};
            obj.Browser.close();

            if is_simulink_handle(obj.ModelHandle)
                Simulink.removeBlockDiagramCallback(obj.ModelHandle,'PreDestroy','ExportTemplate');
            end

            obj.notify('DialogClosed');
        end
    end

    methods(Access=public,Static=true)
        function initialValues=getInputs(modelName)
            initialValues=overrideDefaults(getDefaultValues(modelName));

            function defaultValues=getDefaultValues(modelName)
                import sltemplate.internal.utils.getUserTemplateFolder;
                import sltemplate.internal.Constants.getTemplateFileExtension;

                defaultValues.FilePath=slfullfile(...
                getUserTemplateFolder,...
                [modelName,getTemplateFileExtension]);

                defaultValues.Title=modelName;
                defaultValues.Author=sltemplate.internal.utils.getCurrentUser();
                defaultValues.Group=sltemplate.internal.Constants.getDefaultTemplateGroup();
                defaultValues.Description=get_param(modelName,'Description');
                defaultValues.ThumbnailFile='';
            end

            function defaultValues=overrideDefaults(defaultValues)
                templateFile=get_param(defaultValues.Title,"TemplateFilePath");
                if isempty(templateFile)
                    unpackedLocation=tempname;
                    mkdir(unpackedLocation);
                    defaultValues.ThumbnailFile=fullfile(unpackedLocation,'thumbnail.png');


                    sltemplate.internal.utils.createThumbnailFromModel(...
                    defaultValues.ThumbnailFile,...
                    defaultValues.Title);
                    return;
                end

                [mfModel,metadata]=sltemplate.internal.NewExportDialog.getMetadata(defaultValues.Title);
                if metadata.template.isBuiltin
                    return;
                end

                defaultValues.FilePath=metadata.template.fullFilePath;
                defaultValues.Title=metadata.core.title;
                defaultValues.Author=metadata.core.author;
                defaultValues.Group=metadata.core.group;
                defaultValues.Description=metadata.core.description;

                if~isempty(metadata.template.thumbnail)
                    if strcmp(metadata.template.thumbnail,metadata.template.fullFilePath)
                        unpackedLocation=tempname;
                        mkdir(unpackedLocation);
                        defaultValues.ThumbnailFile=fullfile(unpackedLocation,'thumbnail.png');
                        originalTemplate=matlab.internal.project.packaging.PackageReader(templateFile);
                        originalTemplate.extract('Thumbnail',defaultValues.ThumbnailFile);
                    else
                        defaultValues.ThumbnailFile=metadata.template.thumbnail;
                    end
                end
            end
        end

        function[mfModel,templateMetadata]=getMetadata(bd)
            if strcmpi(get_param(bd,"ModelTemplatePlugin"),'off')
                [mfModel,templateMetadata]=sltemplate.internal.extractTemplateMetadata(bd);
            else
                mfModel=get_param(bd,"TemplateModel");
                templateMetadata=get_param(bd,"TemplateMetadata");
            end
        end

        function onSubmitUpdateRequest(modelName,values)
            metadata=get_param(modelName,'TemplateMetadata');
            metadata.core.title=values.Title;
            metadata.core.author=values.Author;
            metadata.core.group=values.Group;
            metadata.core.description=values.Description;
            metadata.template.thumbnail=values.ThumbnailFile;
            metadata.template.fullFilePath=values.FilePath;
            metadata.template.isBuiltin=false;
            set_param(modelName,'TemplateMetadata',metadata);
            set_param(modelName,'Dirty','on');
        end

        function[templateNotOnPath,message]=onSubmitExportRequest(modelName,values)
            templateNotOnPath=false;
            message='';

            try
                sltemplate.internal.exportModelToTemplate(...
                modelName,...
                values.FilePath,...
                'Title',values.Title,...
                'Author',values.Author,...
                'Description',values.Description,...
                'Group',values.Group,...
                'ThumbnailFile',values.ThumbnailFile,...
                'WarningHandler',@error);
            catch ME
                if(strcmp(ME.identifier,'sltemplate:Registry:TemplateNotOnPath'))
                    templateNotOnPath=true;
                    message=ME.message;
                else
                    rethrow(ME);
                end
            end
        end

        function[templateNotOnPath,message]=onSubmitSaveAsRequest(modelName,values)
            templateNotOnPath=false;
            message='';

            sltemplate.internal.NewExportDialog.onSubmitUpdateRequest(modelName,values);

            try
                Simulink.saveTemplate(modelName,values.FilePath);
            catch ME
                if(strcmp(ME.identifier,'sltemplate:Registry:TemplateNotOnPath'))
                    templateNotOnPath=true;
                    message=ME.message;
                else
                    rethrow(ME);
                end
            end
        end
    end

    methods(Access=private)
        function dialogTitle=makeDialogTitle(obj)
            switch obj.DialogType
            case "Export"
                dialogTitle=message('sltemplate:Export:NewDialogTitle',...
                obj.ModelName,obj.ModelType);
            case "Edit"
                dialogTitle=message('sltemplate:Export:TemplatePropertiesDialogTitle',...
                obj.ModelName,obj.ModelType);
            case "SaveAs"
                dialogTitle=message('sltemplate:Export:SaveAsDialogTitle',...
                obj.ModelName,obj.ModelType);
            end
        end

        function exportURL=makeExportURL(obj,useDebugHTML)
            root='/toolbox/simulink/startpage/web/ExportDialog/export';
            if useDebugHTML
                root=[root,'_debug'];
            end
            root=[root,'.html'];

            channelParam=['?channel=',obj.Channel];
            titleParam=['&modelName=',obj.ModelName];
            modelTypeParam=['&modelType=',obj.ModelType];
            templatePropertiesDialogParam=['&dialogType=',char(obj.DialogType)];
            exportURL=[root,channelParam,titleParam,modelTypeParam,templatePropertiesDialogParam];
        end
    end
end
