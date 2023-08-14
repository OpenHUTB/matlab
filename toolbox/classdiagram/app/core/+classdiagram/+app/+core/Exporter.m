classdef Exporter<handle

    properties
        App;
        FileDialog classdiagram.app.core.utils.FileDialog;
    end

    properties(Constant,Access=private)
        DefaultExtension='png';
    end

    methods

        function obj=Exporter(app,fileDialog)
            obj.App=app;
            obj.FileDialog=fileDialog;
        end

        function fullFilename=openPutFileBrowserWidget(obj,actionArgs)
            fullFilename=[];
            switch actionArgs.format
            case 'pdf'
                fileTypeName=getString(message('classdiagram_editor:messages:PdfFileName'));
            case 'png'
                fileTypeName=getString(message('classdiagram_editor:messages:PngFileName'));
            end

            uiPath=obj.FileDialog.pwd();
            activeFilePath=obj.App.getFilePath();
            if~isempty(activeFilePath)
                [folder,~,~]=fileparts(activeFilePath);
                uiPath=folder;
            end

            [filename,pathname]=obj.FileDialog.uiputfile(...
            {['*.',actionArgs.format],fileTypeName},...
            getString(message('classdiagram_editor:messages:ExportDiagramPicker')),...
            uiPath);
            obj.App.cdWindow.raise();
            if~isequal(filename,0)&&~isequal(pathname,0)
                fullFilename=fullfile(pathname,filename);
                obj.App.publishResponse(struct('key','export:putFileBrowserWidgetResponse','filename',fullFilename),'Success');
            end
        end

        function exportToPdf(obj)
            fullFilename=obj.openPutFileBrowserWidget(struct('format','pdf'));
            if~isempty(fullFilename)
                obj.export(struct('filename',fullFilename,'format','pdf'));
            end
        end

        function export(obj,actionArgs)
            exporter=diagram.editor.print.Exporter(obj.App.syntax,...
            'AppIndex','/toolbox/classdiagram/editor/index.html','IndexParams',"export=1");
            if~isfield(actionArgs,"format")
                [~,~,ext]=fileparts(actionArgs.filename);
                ext=string(strrep(lower(ext),'.',''));
                if~strlength(ext)
                    ext=obj.DefaultExtension;
                end
                actionArgs.format=char(ext);
            end

            function tryExport()
                if isfield(actionArgs,'size')
                    exporter.export(actionArgs.filename,Format=actionArgs.format,Size=actionArgs.size.');
                else
                    exporter.export(actionArgs.filename,Format=actionArgs.format);
                end

            end

            try
                tryExport();
                if obj.App.notifier.isInUIMode
                    obj.App.publishResponse(struct('key','export:success'),'Success');
                end
            catch ME
                if~obj.App.notifier.isInUIMode
                    obj.App.notifier.processNotification(...
                    classdiagram.app.core.notifications.notifications.MExceptionNotification(...
                    ME));
                else
                    switch ME.identifier
                    case 'mustBeValidPath:filenameIsFolder'
                        key='export:mustBeValidPath';
                        msg=getString(message('diagram_editor_registry:General:FilenameIsFolder'));
                    case 'mustBeValidPath:filenameDoesNotExist'
                        key='export:mustBeValidPath';
                        msg=getString(message('diagram_editor_registry:General:FilenameDoesNotExist'));
                    otherwise
                        key='export';
                        msg=ME.message;
                    end
                    obj.App.publishResponse(struct('key',key,'msg',msg),'Fail');
                end
            end
        end
    end
end
