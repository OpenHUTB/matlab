



classdef VerificationImpl<handle

    properties(Access=private)



        fSliceStatusMap;


        fSliceSubstatusMap;


        fEngineStatus='';

        fEngineSubstatus='';

        fEnginePrimVerSubstatus={};

    end

    properties(Constant=true,GetAccess=protected)
        fReportConfig=slci.internal.ReportConfig;
    end

    methods(Access=public,Hidden=true)


        function obj=VerificationImpl()
            obj.fSliceStatusMap=containers.Map;
            obj.fSliceSubstatusMap=containers.Map;
        end


        function addSubstatusForSlice(obj,aSliceName,aStatus)
            obj.addToSliceSubstatusMap(aSliceName,aStatus);
        end


        function addStatusForSlice(obj,aSliceName,aStatus)
            obj.addToSliceStatusMap(aSliceName,aStatus);
        end


        function addEngineSubstatus(obj,aSubstatus)
            obj.fEnginePrimVerSubstatus=slci.results.union(obj.fEnginePrimVerSubstatus,...
            aSubstatus);
        end


        function slNames=getSliceNames(obj)
            slNames=keys(obj.fSliceStatusMap);
        end


        function slStatuses=getSliceStatuses(obj)
            slStatuses=values(obj.fSliceStatusMap);
        end


        function slSubstatuses=getSliceSubstatuses(obj)
            slSubstatuses=values(obj.fSliceSubstatusMap);
        end


        function status=getStatusForSlice(obj,sliceName)
            if isKey(obj.fSliceStatusMap,sliceName)
                status=obj.fSliceStatusMap(sliceName);
            else
                DAStudio.error('Slci:results:ErrorSliceStatus',sliceName);
            end
        end


        function status=getSubstatusForSlice(obj,sliceName)
            if isKey(obj.fSliceSubstatusMap,sliceName)
                status=obj.fSliceSubstatusMap(sliceName);
            else
                DAStudio.error('Slci:results:ErrorSliceSubstatus',sliceName);
            end
        end


        function engineStatus=getComputedEngineStatus(obj)
            obj.computeStatus();
            engineStatus=obj.fEngineStatus;
        end


        function engineStatus=getComputedEngineSubstatus(obj)
            obj.computeSubstatus();
            engineStatus=obj.fEngineSubstatus;
        end


        function Isempty=IsEmpty(obj)
            Isempty=isempty(obj.fEnginePrimVerSubstatus);
            if Isempty&&~isempty(obj.fSliceStatusMap)
                DAStudio.error('Slci:results:InvalidStatus',' ');
            end
        end


        function append(obj,aVerInfo)

            if~isempty(aVerInfo.fSliceSubstatusMap)
                aSlices=aVerInfo.getSliceNames();
                aSubstatuses=aVerInfo.getSliceSubstatuses();
                aSliceSubstatuses=containers.Map(aSlices,aSubstatuses);
                substatusMap=obj.fSliceSubstatusMap;
                obj.fSliceSubstatusMap=[substatusMap;aSliceSubstatuses];
            end

            if~isempty(aVerInfo.fSliceStatusMap)
                aSlices=aVerInfo.getSliceNames();
                aStatuses=aVerInfo.getSliceStatuses();
                aSliceStatuses=containers.Map(aSlices,aStatuses);
                statusMap=obj.fSliceStatusMap;
                obj.fSliceStatusMap=[statusMap;aSliceStatuses];
            end

            if~isempty(aVerInfo.fEnginePrimVerSubstatus)
                obj.addEngineSubstatus(aVerInfo.fEnginePrimVerSubstatus);
            end
        end
    end

    methods(Access=private,Hidden=true)


        function addToSliceSubstatusMap(obj,aSliceName,aStatus)
            if isKey(obj.fSliceSubstatusMap,aSliceName)
                if strcmpi(obj.fSliceSubstatusMap(aSliceName),'FAILED_TO_VERIFY')
                    return;
                elseif~strcmpi(aStatus,'FAILED_TO_VERIFY')
                    DAStudio.error('Slci:results:ErrorMultipleVerSubstatuses',...
                    'VerificationImpl',aSliceName);
                end
            end
            obj.fSliceSubstatusMap(aSliceName)=aStatus;
        end

        function addToSliceStatusMap(obj,aSliceName,aStatus)
            if isKey(obj.fSliceStatusMap,aSliceName)
                if strcmpi(obj.fSliceStatusMap(aSliceName),'FAILED_TO_VERIFY')
                    return;
                elseif~strcmpi(aStatus,'FAILED_TO_VERIFY')
                    DAStudio.error('Slci:results:ErrorMultipleVerSubstatuses',...
                    'VerificationImpl',aSliceName);
                end
            end
            obj.fSliceStatusMap(aSliceName)=aStatus;
        end

        function computeSubstatus(obj)
            reportConfig=obj.fReportConfig;
            if~isempty(obj.fEnginePrimVerSubstatus)
                obj.setEngineSubstatus(...
                reportConfig.getHeaviest(obj.fEnginePrimVerSubstatus));
            else
                obj.setEngineSubstatus('UNABLE_TO_PROCESS');
            end
        end


        function computeStatus(obj,varargin)
            if~isempty(obj.fEnginePrimVerSubstatus)
                obj.setEngineStatus(...
                slci.internal.ReportUtil.aggregateSubstatus(...
                obj.fEnginePrimVerSubstatus));
            else



                if~isempty(obj.fSliceStatusMap)
                    DAStudio.error('Slci:results:InvalidStatus',' ');
                else
                    reportConfig=obj.fReportConfig;
                    obj.setEngineStatus(reportConfig.getStatus('UNABLE_TO_PROCESS'));
                end
            end
        end


        function setEngineStatus(obj,aStatus)
            reportConfig=obj.fReportConfig;
            if isKey(reportConfig.TopVerStatusTable,aStatus)
                obj.fEngineStatus=aStatus;
            else
                DAStudio.error('Slci:results:InvalidStatus',aStatus);
            end
        end


        function setEngineSubstatus(obj,aStatus)
            reportConfig=obj.fReportConfig;
            if isKey(reportConfig.VStatusTable,aStatus)
                obj.fEngineSubstatus=aStatus;
            else
                DAStudio.error('Slci:results:InvalidStatus',aStatus);
            end
        end

    end

end
