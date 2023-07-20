


classdef CovData<matlab.mixin.Copyable






    properties(GetAccess=public,SetAccess=private,Hidden=true)

        data=[]



        covStreamMap=[]


        covIdDfsMap=[]










        startTime=0
        stopTime=0



        covConstraintStruct=[];

        constraintTimeIntervals=[];





        streamStartTime=0;
        streamStopTime=0;





        tout=[];


        simData=[];

        allMdls={};
    end

    methods
        function obj=CovData(data,cStreamMap,idMap,simData)


            if isempty(data)||~(isa(data,'cv.cvdatagroup')||isa(data,'cvdata'))
                Mex=MException('ModelSlicer:BadCvdData',...
                getString(message('Sldv:ModelSlicer:Coverage:BadCvdData')));
                throw(Mex);
            end

            obj.data=data;
            obj.allMdls=Coverage.CovData.getAllMdls(data);

            if isa(obj.data,'cv.cvdatagroup')
                allCvds=obj.data.getAll();
                rawCvd=allCvds{1};
            else
                rawCvd=obj.data;
            end

            obj.startTime=rawCvd.simulationStartTime;
            obj.stopTime=rawCvd.simulationStopTime;

            if exist('simData','var')&&~isempty(simData)
                obj.simData=simData;
                analyzedModel=simData.SimulationMetadata.ModelInfo.ModelName;
                tout=simData.get(get_param(analyzedModel,'TimeSaveName'));
                obj.tout=tout;
                if~isempty(tout)&&...
                    (tout(1)<0||obj.stopTime==obj.startTime||obj.stopTime<tout(end))


                    obj.startTime=tout(1);
                    obj.stopTime=tout(end);
                end
            end

            obj.streamStartTime=obj.startTime;
            obj.streamStopTime=obj.stopTime;

            if exist('cStreamMap','var')&&exist('idMap','var')
                obj.covStreamMap=cStreamMap;
                obj.covIdDfsMap=idMap;
            end
        end

        function[d,detail]=getDecisionInfo(obj,bh,varargin)



            [d,detail]=getCoverageInfo(obj,bh,'decision');
            [d,detail]=sliceCoverageData(obj,bh,'decision',d,detail,varargin{:});
        end

        function[d,detail]=getConditionInfo(obj,bh,varargin)



            [d,detail]=getCoverageInfo(obj,bh,'condition');
            [d,detail]=sliceCoverageData(obj,bh,'condition',d,detail.condition,varargin{:});
        end

        function[d,detail]=getCoverageInfo(obj,bh,metric,varargin)

            [d,detail]=Coverage.CovData.getCovInfo(obj.data,bh,metric);
        end

        function[d,detail]=sliceCoverageData(obj,bh,metric,d,detail,varargin)


            if isempty(d)||isempty(detail)
                return;
            end

            if~isempty(obj.covStreamMap)...
                &&~isempty(obj.covIdDfsMap)...
                &&slavteng('feature','EnhancedCoverageSlicer')

                covidx=obj.getCovIdx(bh,metric);
                if isempty(obj.constraintTimeIntervals)&&isempty(obj.covConstraintStruct)
                    if(obj.startTime==obj.streamStartTime&&obj.stopTime==obj.streamStopTime)
                        return;
                    end
                    [d,detail]=obj.sliceCovWindow(covidx,[obj.startTime;obj.stopTime],d,detail,varargin{:});
                else
                    [dAggreg,detailAggreg]=Coverage.CovData.aggregateCoverage...
                    ([],[],d,detail);

                    for j=1:size(obj.constraintTimeIntervals,1)
                        tw(1)=obj.constraintTimeIntervals(j,1);
                        tw(2)=obj.constraintTimeIntervals(j,2);
                        if tw(1)<=tw(2)
                            [dTemp,detailTemp]=obj.sliceCovWindow(covidx,tw,d,detail,varargin{:});
                            [dAggreg,detailAggreg]=Coverage.CovData.aggregateCoverage...
                            (dAggreg,detailAggreg,dTemp,detailTemp);
                        end

                        if~isempty(dAggreg)&&dAggreg(1)==dAggreg(2)&&dAggreg(1)>0

                            d=dAggreg;
                            detail=detailAggreg;
                            return;
                        end
                    end

                    d=dAggreg;
                    detail=detailAggreg;
                end
            end
        end

        function covidx=getCovIdx(obj,bh,metric)


            covidx=[];
            if isempty(obj.covIdDfsMap)
                return;
            end
            [~,blockCvId]=SlCov.CoverageAPI.getCvdata(obj.data,bh);
            if~ischar(blockCvId)
                try
                    covid=cv('MetricGet',blockCvId,...
                    cvi.MetricRegistry.getEnum(metric),'.baseObjs');
                    covidx=arrayfun(@(id)obj.covIdDfsMap(id),covid);
                catch ex
                    Mex=MException('ModelSlicer:InvalidCovId',...
                    getString(message('Sldv:ModelSlicer:Coverage:InvalidCovId')));
                    Mex=Mex.addCause(ex);
                    throw(Mex);
                end
            end
        end

        function activestates=getActiveStatesFromDec(cvd,bh,idx)

            [~,detail]=getDecisionInfo(cvd,bh,idx);
            detail=detail.decision(idx);

            if isempty(detail)||~isfield(detail,'outcome')
                activestates=[];
                return;
            end
            outcome=detail.outcome;
            idx=arrayfun(@(o)o.executionCount>0,outcome);
            activestates=arrayfun(@(o){strrep(o.text,'"','')},outcome(idx));
        end

        function streamData=getStreamData(obj,covIdx)

            streamData=[];
            if isempty(obj.covStreamMap)
                return;
            end

            pos=obj.covStreamMap.Idx(covIdx,:);
            if isequal(pos,[0,0])
                return;
            end
            streamData=obj.covStreamMap.Data(pos(1):pos(2),:);
        end

        function yesno=hasValidCoverageData(obj,mdlHs)

            yesno=true;
            try
                for i=1:length(mdlHs)
                    if strcmp(get_param(mdlHs(i),'SimulationStatus'),'stopped')
                        error('ModelSlicer:ModelMustCompiledFirst',...
                        getString(message('Sldv:ModelSlicer:ModelSlicer:ModelMustCompiledFirst')));
                    end
                    modelCheckSum=SlCov.CoverageAPI.getChecksum(get(mdlHs(i),'Name'));
                    if isa(obj.data,'cv.cvdatagroup')
                        cvd=obj.data.get(get(mdlHs(i),'Name'));
                        if cv('get',cv('get',cvd.id,'.modelcov'),'.isCopyRefMdl')
                            continue;
                        end
                        covCheckSum=cvd.checksum;
                    else
                        covCheckSum=obj.data.checksum;
                    end
                    if~locIsChecksumMatching(modelCheckSum,covCheckSum)


                        if strcmp(get_param(mdlHs(i),'isHarness'),'on')
                            harnessInfo=Simulink.harness.internal.getHarnessInfoForHarnessBD(mdlHs(i));
                            if strcmp(harnessInfo.ownerType,'Simulink.BlockDiagram')
                                checksumOwner=harnessInfo.ownerFullPath;
                            elseif strcmp(harnessInfo.ownerType,'Simulink.ModelReference')
                                checksumOwner=get_param(harnessInfo.ownerFullPath,'modelName');
                            else
                                checksumOwner=getfullname([getfullname(mdlHs(i)),':1']);
                            end

                            modelCheckSum=SlCov.CoverageAPI.getChecksum(checksumOwner);


                            if~locIsChecksumMatching(modelCheckSum,covCheckSum)
                                yesno=false;
                                return;
                            end
                        else
                            yesno=false;
                            return;
                        end
                    end
                end
            catch
                yesno=false;
            end

            function yesno=locIsChecksumMatching(modelCheckSum,covCheckSum)
                yesno=isequal(modelCheckSum,...
                [covCheckSum.u1,covCheckSum.u2,covCheckSum.u3,covCheckSum.u4]);
            end
        end


        function yesno=hasCoverage(obj,bh)
            yesno=true;
            if~iscell(bh)
                sid=Simulink.ID.getSID(bh);
            else


                sid=Simulink.ID.getSID(bh{1});
            end
            try
                if isa(obj.data,'cv.cvdatagroup')
                    parts=strsplit(sid,':');
                    cvd=obj.data.get(parts{1});%#ok<NASGU>
                    errStr=evalc('d = decisioninfo(cvd, bh);');%#ok<NASGU>
                else
                    errStr=evalc('d = decisioninfo(obj.data, bh);');%#ok<NASGU>
                end
                if isempty(d)
                    yesno=false;
                end
            catch
                yesno=false;
            end
        end

        function[startTime,stopTime]=getStartStopTime(obj,~)
            startTime=obj.startTime;
            stopTime=obj.stopTime;
        end

        function constrTimeintervals=getConstraintTimeIntervals(obj)
            constrTimeintervals=unique(obj.constraintTimeIntervals,'rows');
        end
        function valid=setStartStopTime(obj,startTime,stopTime)
            valid=true;
            if~isempty(obj.tout)
                if startTime~=0
                    idx=Coverage.CovData.binarySearch(obj.tout,startTime,0);
                    startTime=obj.tout(idx);
                end
                idx=Coverage.CovData.binarySearch(obj.tout,stopTime,0);
                stopTime=obj.tout(idx);
            end

            obj.startTime=startTime;
            obj.stopTime=stopTime;
            obj.constraintTimeIntervals=[];
            deriveConstraintTimeIntervals(obj,obj.covConstraintStruct);
            if~isempty(obj.covConstraintStruct)&&...
                isempty(obj.constraintTimeIntervals)
                valid=false;
            end
        end

        function yesno=windowOutOfBounds(obj,startTime,stopTime)
            yesno=startTime<obj.streamStartTime||stopTime>obj.streamStopTime;
        end

        function emptyInterval=addConstraint(obj,newConstraintStruct)
            deriveConstraintTimeIntervals(obj,newConstraintStruct);
            obj.covConstraintStruct=[obj.covConstraintStruct;newConstraintStruct];
            emptyInterval=isempty(obj.constraintTimeIntervals);
        end

        function removeConstraint(obj,constraint)
            if isempty(obj.covConstraintStruct)
                return;
            end
            idx=[obj.covConstraintStruct.decId]==constraint.decId&...
            [obj.covConstraintStruct.outcomeNum]==constraint.outcomeNum;
            obj.covConstraintStruct(idx)=[];
            obj.constraintTimeIntervals=[];
            deriveConstraintTimeIntervals(obj,obj.covConstraintStruct);
        end

        function deriveConstraintTimeIntervals(obj,constraints)


            obj.constraintTimeIntervals=locDeriveIntervalsInLimits(obj.constraintTimeIntervals,...
            [obj.startTime,obj.stopTime]);

            function intervals=locDeriveIntervalsInLimits(intervals,tLimits)
                for i=1:length(constraints)
                    decIdx=constraints(i).decId;
                    outcome=constraints(i).outcomeNum;
                    newDerivedInterval=[];
                    streamData=getStreamData(obj,decIdx);
                    if~isempty(streamData)

                        activeIdx=streamData(:,3)==outcome;
                        timewindow=streamData(activeIdx,1:2);
                        if isempty(intervals)


                            intervals=[tLimits(1),tLimits(2)];
                        end
                        for j=1:size(timewindow,1)


                            for k=1:size(intervals,1)
                                tw(1)=max(timewindow(j,1),intervals(k,1));
                                tw(2)=min(timewindow(j,2),intervals(k,2));

                                tw(1)=max(tLimits(1),tw(1));
                                tw(2)=min(tLimits(2),tw(2));
                                if tw(1)<=tw(2)
                                    newDerivedInterval=[newDerivedInterval;tw];%#ok<AGROW>
                                end
                            end
                        end

                        intervals=unique(newDerivedInterval,'rows');
                    else
                        intervals=[];
                        return;
                    end
                end
            end
        end

        function clearAllConstraints(obj)
            obj.covConstraintStruct=[];
            obj.constraintTimeIntervals=[];
        end

        function refreshCvData(obj,cvFileName,model)
            cvdTemp=Coverage.loadCoverage(cvFileName,model);
            obj.data=cvdTemp.data;
        end

        [d,detail]=sliceCovWindow(obj,covObj,timeInterval,d,detail,varargin)

    end
    methods(Static,Hidden=true)
        function idx=binarySearch(data,tval,lu)

            if nargin<3
                lu=0;
            end
            s=1;
            e=length(data);
            while e-s>1
                mid=s+floor((e-s)/2);
                if data(mid)==tval
                    if(lu==0)
                        e=mid;
                    else
                        s=mid;
                    end
                elseif data(mid)>tval
                    e=mid-1;
                else
                    s=mid;
                end
            end

            if data(e)==tval&&data(s)==data(e)
                if lu
                    idx=e;
                else
                    idx=s;
                end
            else
                if data(e)<=tval
                    idx=e;
                else
                    idx=s;
                end
            end
        end
        function idx=getDecStructIdx(detail,metric)




            idx=[];
            if isempty(detail)||~isfield(detail,'decision')
                return;
            end
            idx=find(arrayfun(@(d)strcmpi(d.text,metric),detail.decision));
        end

        function[dAggreg,detailAggreg]=aggregateCoverage(dAggreg,detailAggreg,d,detail)



            init=false;
            if isempty(dAggreg)||isempty(detailAggreg)
                dAggreg=d;
                detailAggreg=detail;
                init=true;
            end

            dAggreg(1)=0;
            if isfield(detail,'decision')
                for i=1:length(detail.decision)
                    if isfield(detail.decision(i),'outcome')
                        for j=1:length(detail.decision(i).outcome)
                            if~init
                                execCount=...
                                detailAggreg.decision(i).outcome(j).executionCount+...
                                detail.decision(i).outcome(j).executionCount;
                            else
                                execCount=0;
                            end

                            detailAggreg.decision(i).outcome(j).executionCount=execCount;
                            dAggreg(1)=dAggreg(1)+(execCount>0);
                        end
                    end
                end
            else
                for i=1:length(detail)
                    if isfield(detail(i),'trueCnts')
                        if~init
                            detailAggreg(i).trueCnts=...
                            detailAggreg(i).trueCnts+detail(i).trueCnts;

                            detailAggreg(i).falseCnts=...
                            detailAggreg(i).falseCnts+detail(i).falseCnts;
                        else
                            detailAggreg(i).trueCnts=0;
                            detailAggreg(i).falseCnts=0;
                        end

                        dAggreg(1)=dAggreg(1)+...
                        (detailAggreg(i).trueCnts>0)+...
                        (detailAggreg(i).falseCnts>0);
                    end
                end
            end
        end

        function[d,detail]=getCovInfo(covdata,bh,metric,varargin)%#ok<INUSL,STOUT>
            metric=[upper(metric(1)),metric(2:end)];
            errStr=evalc(sprintf('[d, detail] = SlCov.CoverageAPI.get%sInfo(covdata, bh, [varargin{:}])',metric));%#ok<NASGU>
        end

        function allMdls=getAllMdls(cvd)
            allMdls={};
            if isa(cvd,'cv.cvdatagroup')
                allCvds=cvd.getAll();
                allMdls=cellfun(@(d){d.modelinfo.analyzedModel},allCvds);
            elseif isa(cvd,'cvdata')
                allMdls{1}=cvd.modelinfo.analyzedModel;
            end
        end
    end
end