
classdef EdittimeCheck<handle
    properties









        traversalType=edittimecheck.TraversalTypes.BLKITER;

        checkId='';
    end

    methods

        function obj=EdittimeCheck(input)
            obj.checkId=input;
        end

        function traversalValue=getTraversalType(obj)
            traversalValue=uint8(obj.traversalType);
        end

        function violation=blockDiscovered(obj,blk)%#ok<INUSD>
            violation=[];
        end


        function violation=blockFinishedVisitingChildren(obj,blk)%#ok<INUSD>
            violation=[];
        end

        function violation=finishedTraversal(obj)%#ok<MANU>
            violation=[];
        end

        function id=getCheckId(obj)
            id=obj.checkId;
        end

        function success=fix(obj,violation)
            success=true;
        end
        function jsonString=getDiagnosticJson(obj,ResultDetailObj)

            mc=metaclass(obj);
            for i=1:length(mc.MethodList)
                if strcmpi(mc.MethodList(i).Name,'fix')
                    j=i;
                    break;
                end
            end
            if~strcmpi(mc.MethodList(j).DefiningClass.Name,class(obj))
                diag=MSLDiagnostic(['edittime:',strrep(ResultDetailObj.CheckID,'.','')],ResultDetailObj.Title);
                cause=MSLDiagnostic(['edittime:',strrep(ResultDetailObj.CheckID,'.',''),'Desc'],ResultDetailObj.Description);
                diag=diag.addCause(cause);
            else


                hash=ResultDetailObj.getHash();
                checkID=ResultDetailObj.CheckID;
                checkID=['''',checkID,''''];



                diag=MSLDiagnostic(['edittime:',strrep(ResultDetailObj.CheckID,'.','')],ResultDetailObj.Title);
                cause=MSLDiagnostic(['edittime:',strrep(ResultDetailObj.CheckID,'.',''),'Desc'],ResultDetailObj.Description);
                m=message('sledittimecheck:edittimecheck:edittimecheckauthoring_fixmsg');
                cause.addFixit(m.getString,['edittime.util.customEdittimeFix( ''',ResultDetailObj.CheckID,''',''',num2str(hash),''')'],'FixID');
                diag=diag.addCause(cause);
            end
            jsonString=diag.json;
        end
    end
end
