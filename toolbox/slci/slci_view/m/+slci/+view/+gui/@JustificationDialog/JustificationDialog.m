



classdef JustificationDialog<slci.view.gui.Dialog
    properties(Constant)
        id='SLCIJustification'
        title='Justification'
        comp='GLUE2:DDG Component'
        tag='Tag_Justification'
    end

    properties(Access=private)
fRegisterCallbackId

fSendJsonData

fBlockSidforUrl

fCodeLinesforUrl

fDataFromUi

fSelectedBlockSID

fCacheDataManagerObj
    end

    methods

        function obj=JustificationDialog(st,id)
            obj@slci.view.gui.Dialog(st,id);
        end

        function delete(obj)
            if isvalid(obj.getStudio)
                c=obj.getStudio.getService('GLUE2:ActiveEditorChanged');
                c.unRegisterServiceCallback(obj.fRegisterCallbackId);
            end
        end
    end

    methods

        sendData(obj);

        receive(obj,msg);
        reloadData(obj);

        fetchSelectedBlockSID(obj);

        verifyInputCodeLines(obj,msgData);

        verifyInputBlockSID(obj,msgData)

    end

    methods


        function out=getJsonData(obj)
            out=obj.fSendJsonData;
        end


        function blockSidforUrl=getBlockSidforUrl(obj)
            blockSidforUrl=obj.fBlockSidforUrl;
        end


        function dataFromUi=getDataFromUi(obj)
            dataFromUi=obj.fDataFromUi;
        end


        function codeLinesforUrl=getCodeLinesforUrl(obj)
            codeLinesforUrl=obj.fCodeLinesforUrl;
        end


        function setJsonData(obj,jsonData)
            obj.fSendJsonData=jsonData;
        end


        function setBlockSidforUrl(obj,blockSidforUrlInput)
            obj.fBlockSidforUrl=blockSidforUrlInput;
        end


        function setCodeLinesforUrl(obj,codeLinesforUrlInput)
            obj.fCodeLinesforUrl=codeLinesforUrlInput;
        end


        function setDataFromUi(obj,dataFromUiInput)
            obj.fDataFromUi=dataFromUiInput;
        end

        function out=getSelectedBlockSID(obj)
            out=obj.fSelectedBlockSID;
        end

        function setSelectedBlockSID(obj,sid)
            obj.fSelectedBlockSID=sid;
        end


        function out=getCacheDataManagerObj(obj)
            out=obj.fCacheDataManagerObj;
        end

        function cacheDataManagerObj(obj,dataManagerObj)
            obj.fCacheDataManagerObj=dataManagerObj;
        end

    end

    methods(Static)
        user=getUsername();

        function dispStatus=getDispStatus(status)
            switch(upper(status))
            case 'TRACED'
                dispStatus='Passed';
            case 'FAILED_TO_TRACE'
                dispStatus='NeedsManual';
            case 'JUSTIFIED'
                dispStatus='Justified';
            case ''
            otherwise
                dispStatus='Unknown';
                disp('Unexpected status.');
            end
        end
    end

    methods(Access=protected)
        init(obj,varagin)
    end

    methods(Access=private)

        function dm=getDataManager(obj)

            conf=slci.toolstrip.util.getConfiguration(obj.getStudio);


            dm=conf.getDataManager();
        end
    end
end