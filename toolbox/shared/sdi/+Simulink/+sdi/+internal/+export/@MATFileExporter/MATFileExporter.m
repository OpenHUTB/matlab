classdef MATFileExporter<Simulink.sdi.internal.export.FileExporter





    methods

        function success=export(this,runIDs,signalIDs,activeApp,eng,...
            ~,~,bCmdLine)
            try
                eng.exportToMatFile(runIDs,signalIDs,activeApp,...
                this.VarName,this.FileName);
                success=true;
            catch me
                success=false;
                switch me.identifier
                case 'MATLAB:save:permissionDenied'
                    errorStr=getString(message('SDI:sdi:UnableToWriteErr'));
                otherwise
                    errorStr=me.message;
                end
                if~bCmdLine
                    locShowMATExportErrorDlg(errorStr);
                end
                throwAsCaller(me);
            end
        end


        function fileType=getFileType(this)
            fileType=this.FileType;
        end


        function this=setFileName(this,fileName)
            this.FileName=fileName;
        end
    end


    properties(Access=private)
        VarName='data';
        FileType='.mat';
    end
end


function locShowMATExportErrorDlg(msgStr)
    titleStr=getString(message('SDI:sdi:ExportError'));
    okStr=getString(message('SDI:sdi:OKShortcut'));
    Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
    'default',...
    titleStr,...
    msgStr,...
    {okStr},...
    0,...
    -1,...
    []);
end