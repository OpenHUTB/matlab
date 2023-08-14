classdef MP4FileExporter<Simulink.sdi.internal.export.FileExporter





    methods


        function success=export(this,~,signalIDs,~,~,~,~,bCmdLine)

            if numel(signalIDs)~=1
                this.displayError(message('SDI:sdi:ExportRunObjUnsupported'),bCmdLine);
            end


            sig=Simulink.sdi.getSignal(signalIDs(1));


            if locIsVideoSignal(sig)
                success=exportVideoSignal(this,sig,bCmdLine);
            else
                success=exportMatrixSignal(this,sig,bCmdLine);
            end
        end


        function fileType=getFileType(this)
            fileType=this.FileType;
        end


        function this=setFileName(this,fileName)
            this.FileName=fileName;
        end


        function ret=supportsCancel(~)

            ret=true;
        end
    end


    properties(Access=private)
        FileType='.mp4';
    end
end


function vs=locIsVideoSignal(sig)

    path=sdi.PluggableStorage.getSignalStoragePath(sig.ID);
    if sig.Domain=="video"||~isempty(path)
        vs=true;
    else
        vs=false;
    end
end
