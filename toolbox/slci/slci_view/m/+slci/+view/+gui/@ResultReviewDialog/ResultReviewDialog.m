



classdef ResultReviewDialog<slci.view.gui.Dialog
    properties(Constant)
        id='SLCIResultReview'
        title=DAStudio.message('Slci:slcireview:ReviewTableTitle')
        comp='GLUE2:DDG Component'
        tag='Tag_ResultReview'
    end

    properties(Access=private)
fInspectionSummaryData

fResultReviewID
fBlockData
fCodeSliceData
fInterfaceData
fTempVarData
fUtilFuncData
fStatus
fCodeStatus
fBlockStatus
fInterfaceStatus
fTempVarStatus
fUtilFuncStatus
fRegisterCallbackId

fJsonDataAfterDelete

fDeleteStatusFlag

        fMsgForJustificationDialog='';

        fComponents={}
    end


    methods

        function obj=ResultReviewDialog(st)
            obj@slci.view.gui.Dialog(st);



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
        onBlockRowSelect(obj,msgData);
        onCodeSliceRowSelect(obj,msgData);
        onInterfaceRowSelect(obj,msgData);
        onTempVarRowSelect(obj,msgData);
        onUtilFuncRowSelect(obj,msgData);

        getJustificationForSid(obj,msgData);
        addNewJustificationInJson(obj,msgData)
        deleteJustificationCommentFromJson(obj,msgData);
        updateJustificationJson(obj,msgData);
        getJustificationForCodeLines(obj,msgData);
        deleteAllJustificationComments(obj,msgData);
        out=customJSONHelper(obj,uiJsonSid,uiJsonCodeLines,msg,...
        uiJsonCommentThread);
    end

    methods

        function data=getBlockData(obj,rtwName)
            data=obj.fBlockData(rtwName);
        end


        function out=getJsonDataAfterDelete(obj)
            out=obj.fJsonDataAfterDelete;
        end

        function out=getDeleteStatusFlag(obj)
            out=obj.fDeleteStatusFlag;
        end

        function out=getMsgForJustificationDialog(obj)
            out=obj.fMsgForJustificationDialog;
        end


        function setJsonDataAfterDeletes(obj,JsonAfterdelete)
            obj.fJsonDataAfterDelete=JsonAfterdelete;
        end

        function setDeleteStatusFlag(obj,JsonAfterdelete)
            obj.fDeleteStatusFlag=JsonAfterdelete;
        end

        function setMsgForJustificationDialog(obj,Status)
            obj.fMsgForJustificationDialog=Status;
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
        init(obj)
    end

    methods(Access=private)

        populateInspectionSummaryData(obj);
        populateBlockData(obj);
        populateCodeSliceData(obj);
        populateStatus(obj);
        populateInterfaceData(obj);
        populateTempVarData(obj);
        populateUtilFuncData(obj);


        onEditorChanged(obj,cbinfo)
    end

    methods(Access=private)

        function out=getResultReviewID(obj)
            out=obj.fResultReviewID;
        end

        function setResultReviewID(obj,id)
            obj.fResultReviewID=id;
        end



        function dm=getDataManager(obj)

            conf=slci.toolstrip.util.getConfiguration(obj.getStudio);


            dm=conf.getDataManager();
        end


        function codelines=getCodeLines(~,contributeSrc)
            codeTrace=slci.view.data.CodeTrace();
            for j=1:numel(contributeSrc)
                cj=contributeSrc{j};
                lineTrace=strsplit(cj,filesep);
                lineTrace=strsplit(lineTrace{end},':');
                codeTrace.addTrace(lineTrace{1},lineTrace{2});
            end
            codelines=codeTrace.toString;
        end


        function blockTrace=getBlockTrace(~,codeObjs)
            blockTrace='';
            for k=1:numel(codeObjs)
                traceArrays=codeObjs{k}.getTraceArray;
                for j=1:numel(traceArrays)
                    blockTrace=[blockTrace,';',traceArrays{j}];%#ok
                end
            end

            if~isempty(blockTrace)

                blockTrace=blockTrace(2:end);
            end
        end



        function data=prepareHiliteCodeData(~,codelines)
            data=containers.Map('KeyType','char','ValueType','any');

            codelines=strsplit(codelines,'; ');
            for i=1:numel(codelines)
                ret=strsplit(codelines{i},':');
                fileName=ret{1};
                numbers=strtrim(strsplit(ret{2},','));
                lineNos=[];
                for j=1:numel(numbers)
                    lineNos=[lineNos,str2double(numbers{j})];
                end
                data(fileName)=lineNos;
            end
        end

    end
end