


classdef CodeViewDialog<handle
    properties(Constant)
        id='SLCICodeView';
        title='Code'
        comp='GLUE2:DDG Component'
        tag='Tag_CodeView'
    end

    properties(Access=private)
fStudio

fChannel
fUrl
fDebugUrl

fClickEventData

        fListeners={};
    end

    methods

        function obj=CodeViewDialog(st)
            obj.fStudio=st;
            obj.init();




        end


        onCodeViewerClick(~,varargin)
    end

    methods

        function ct=getCodeTrace(obj)
            ct=slci.view.data.CodeTrace();
            fileName=obj.fClickEventData.file;
            lineNo=num2str(obj.fClickEventData.line);
            ct.addTrace(fileName,lineNo);
        end


        function tf=hasEventData(obj)
            tf=~isempty(obj.fClickEventData);
        end


        function clearEventData(obj)
            obj.fClickEventData=[];
        end


        function col=getTokenColumn(obj)
            col=obj.fClickEventData.col;
        end


        function sids=getTracedBlockSIDs(obj)
            sids=obj.fClickEventData.sids;
        end


        function setClickEventData(obj,aEventData)
            obj.fClickEventData=aEventData;
        end
    end

end