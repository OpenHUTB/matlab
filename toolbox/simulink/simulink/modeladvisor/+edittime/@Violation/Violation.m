classdef(Abstract)Violation<handle
    properties(SetAccess=private)
blkHandle
system
checkID

        type=ModelAdvisor.CheckStatus.Warning;
    end

    properties(SetAccess=protected)
        diagnostic;
    end

    methods(Access=public)
        function this=Violation(blkH,sys,checkID)
            this.blkHandle=blkH;
            this.system=sys;
            this.checkID=checkID;
        end



        createDiagnostic(obj);

        function help(obj)
            [map_path,topic_id]=obj.getCSH();
            if(~isempty(map_path)&&~isempty(topic_id))
                helpview(map_path,topic_id,'CSHelpWindow');
            elseif~(ModelAdvisor.internal.launchCustomHelp(obj.CheckID))
                error('sledittimecheck:nohelpdefined','%s',getString(message('sledittimecheck:edittimecheck:HelpError',obj.checkID)));
            end
        end

        function blkhandle=getBlockHandle(obj)
            blkhandle=obj.blkHandle;
        end

        function checkID=getCheckID(obj)
            checkID=obj.checkID;
        end

        function[map_path,topic_id]=getCSH(~)
            map_path='';topic_id='';
        end

        function o=getJSON(obj)
            o=[];
            violationjson={};
            for i=1:length(obj.diagnostic)
                violationjson{i}=obj.diagnostic(i).json();%#ok<AGROW>
            end
            o.json=violationjson;
            o.type=obj.type.char;
        end

        function summary=getIssueSummary(obj)
            summary=obj.diagnostic(1).message();
        end


        function setType(obj,type)
            if isa(type,'ModelAdvisor.CheckStatus')
                obj.type=type;
            else
                DAStudio.error('sledittimecheck:edittimecheck:IncorrectViolationType');
            end
        end





        function size=addToPopupSize(~)
            size=[10,40];
        end









    end
end
