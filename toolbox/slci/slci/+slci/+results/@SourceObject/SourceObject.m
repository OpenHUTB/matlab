













classdef SourceObject<matlab.mixin.Copyable

    properties(Access=protected)

        Key;


        fTraceArray={};
        fTraceSubstatus='';

        fTraceStatus='';


        Status='UNKNOWN';

    end

    methods(Access=protected)

        function obj=SourceObject(akey)
            if nargin==0
                error('Default constructor is not allowed');
            end
            slci.results.SourceObject.validateKey(akey);
            obj.Key=akey;
        end
    end

    properties(Constant=true,GetAccess=protected)
        fReportConfig=slci.internal.ReportConfig;
    end

    methods(Access=protected)

        function setTraceSubstatus(obj,aTraceSubstatus)
            if isKey(obj.fReportConfig.TraceTable,aTraceSubstatus)
                obj.fTraceSubstatus=aTraceSubstatus;
            else
                error(['Invalid traceability substatus value '...
                ,aTraceSubstatus]);
            end
        end

    end

    methods(Access=protected,Abstract=true)

        checkTraceObj(obj,aTraceObj);
    end

    methods(Access=public,Hidden=true)

        function addTraceObject(obj,traceObj)
            obj.checkTraceObj(traceObj);
            obj.addTraceKey({traceObj.Key});
        end


        function addTraceKey(obj,traceKey)
            obj.fTraceArray=union(obj.fTraceArray,traceKey,'legacy');
        end




        function setTraceKey(obj,traceKey)
            if~iscell(traceKey)
                DAStudio.error('Slci:results:InvalidInputArg');
            end
            obj.fTraceArray=traceKey;
        end


        function addTraceObjects(obj,traceObjs)
            num=numel(traceObjs);
            tempKeys=cell(1,num);
            for k=1:num
                traceObj=traceObjs{k};
                obj.checkTraceObj(traceObj);
                tempKeys{k}=traceObj.Key;
            end
            obj.addTraceKey(tempKeys);
        end

        function computeTraceStatus(obj)



            if isempty(obj.getTraceSubstatus())
                DAStudio.error('Slci:results:ErrorComputingTraceStatus',obj.getKey());
            else
                obj.setTraceStatus(obj.fReportConfig.getTraceabilityStatus(...
                obj.fTraceSubstatus));
            end
        end


        function setStatus(obj,aStatus)
            if isKey(obj.fReportConfig.TopVerStatusTable,aStatus)
                obj.Status=aStatus;
            else
                DAStudio.error('Slci:results:InvalidStatus',aStatus);
            end
        end

        function setTraceStatus(obj,aStatus)
            if isKey(obj.fReportConfig.TopTraceTable,aStatus)
                obj.fTraceStatus=aStatus;
            else
                DAStudio.error('Slci:results:InvalidStatus',aStatus);
            end
        end

    end


    methods(Access=public,Hidden=true)

        function ky=getKey(obj)
            ky=obj.Key;
        end

        function astatus=getStatus(obj)
            astatus=obj.Status;
        end


        function aTraceArray=getTraceArray(obj)
            aTraceArray=obj.fTraceArray;
        end

        function aTraceStatus=getTraceStatus(obj)
            aTraceStatus=obj.fTraceStatus;
        end

        function aTraceSubstatus=getTraceSubstatus(obj)
            aTraceSubstatus=obj.fTraceSubstatus;
        end

        function dispName=getDispName(obj,datamgr)%#ok
            dispName=obj.Key;
        end

        function linkStr=getLink(obj,datamgr)%#ok
            linkStr='-';
        end

    end

    methods(Static=true,Hidden=true,Access=protected)

        function validateKey(aKey)
            if(isempty(aKey)||~ischar(aKey))
                DAStudio.error('Slci:results:InvalidKey','SOURCEOBJECT');
            end
        end

    end


end
