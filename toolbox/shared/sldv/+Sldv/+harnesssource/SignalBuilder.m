classdef SignalBuilder<Sldv.harnesssource.Source




    methods
        function obj=SignalBuilder(blockH)
            obj@Sldv.harnesssource.Source(blockH);
        end

        function sourceType=getSourceType(~)
            sourceType='Signal Builder';
        end

        function numTestCases=getNumberOfTestcases(obj)
            [~,~,~,data]=signalbuilder(obj.blockH);
            if isempty(data)
                numTestCases=0;
            elseif~iscell(data)
                numTestCases=1;
            else
                numTestCases=size(data,2);
            end
        end

        function numSignals=getNumberOfSignals(obj)
            [~,~,signals,~]=signalbuilder(obj.blockH);
            numSignals=length(signals);
        end

        function[errstr,destStartGrpCnt,srcGrpCnt]=merge(obj,destObj)
            errstr='';
            srcH=obj.blockH;
            destH=destObj.blockH;
            [tsrc,dssrc,slsrc,grpsrc]=signalbuilder(srcH);
            [~,~,sldest,grpdest]=signalbuilder(destH);

            destStartGrpCnt=length(grpdest);
            srcGrpCnt=length(grpsrc);

            if length(slsrc)==length(sldest)
                mapInd=1:length(slsrc);
            else
                [mapInd,msgId]=check_names(obj,slsrc,sldest);

                if~isempty(msgId)
                    harnessmodelSrc=get_param(bdroot(srcH),'Name');
                    harnessmodelDest=get_param(bdroot(destH),'Name');
                    errstr=getString(message(msgId,harnessmodelSrc,harnessmodelDest,getfullname(srcH),getfullname(destH)));
                    return;
                end
            end

            isMissing=(mapInd==-1);










            srcName2SizeTypeName=getSignalMapBetweenSigSrcandSizeType(destObj);

            val=cell(1,nnz(isMissing));
            ctr=1;
            for idx=1:numel(isMissing)
                if isMissing(idx)
                    if isKey(srcName2SizeTypeName,sldest{idx})
                        missingSigName=srcName2SizeTypeName(sldest{idx});
                        missingVal=getConstantBlockVal(missingSigName,obj);
                    else
                        missingVal=0;
                    end

                    val{ctr}=[missingVal,missingVal];
                    ctr=ctr+1;
                end
            end

            if any(isMissing)
                destCnt=length(mapInd);
                expandSrcD=cell(destCnt,srcGrpCnt);
                expandSrcT=cell(destCnt,srcGrpCnt);

                for idx=1:srcGrpCnt
                    expandSrcD(isMissing,idx)=val;
                    expandSrcT(isMissing,idx)={[tsrc{1,idx}(1),tsrc{1,idx}(end)]};
                end

                expandSrcD(~isMissing,:)=dssrc(mapInd(~isMissing),:);
                expandSrcT(~isMissing,:)=tsrc(mapInd(~isMissing),:);

                signalbuilder(destH,'append',expandSrcT,expandSrcD,sldest,grpsrc);
            else
                signalbuilder(destH,'append',tsrc(mapInd,:),dssrc(mapInd,:),sldest,grpsrc);
            end


            for i=1:srcGrpCnt
                reqs=rmi.getReqs(srcH,i);
                if~isempty(reqs)
                    rmi.setReqs(destH,reqs,destStartGrpCnt+i);
                end
            end

            function nameMap=getSignalMapBetweenSigSrcandSizeType(sigBuilder)




















































                nameMap=containers.Map('keyType','char','valueType','char');
                [~,~,sigNames]=signalbuilder(sigBuilder.blockH);

                modelName=get_param(sigBuilder.blockH,'Parent');
                sizeTypeH=get_param([modelName,'/Size-Type'],'Handle');
                inportHs=find_system(sizeTypeH,'SearchDepth',1,'BlockType','Inport');
                inportNames=get_param(inportHs,'Name');








                if ischar(inportNames)
                    inportNames={inportNames};
                end

                for t=1:numel(inportNames)
                    nameMap(sigNames{t})=inportNames{t};
                end
            end

            function val=getConstantBlockVal(name,sigSrc)
                modelName=get_param(sigSrc.blockH,'Parent');
                try
                    blkPath=[modelName,'/Size-Type/',name];
                    val=str2double(get_param(blkPath,'Value'));
                catch
                    val=0;
                end
            end
        end

        function[mapInd,errId]=check_names(~,srcNames,destNames)
            errId='';



            [~,idxDst,idxSrc]=intersect(destNames,srcNames);



            if length(idxSrc)~=length(srcNames)
                mapInd=[];
                errId='Sldv:HarnessUtils:MakeSystemTestHarness:UnableMergeHarnessModels';
                return;
            else
                revIdx(idxSrc)=1:length(srcNames);
                origIdxDst=idxDst(revIdx);



                if any(diff(origIdxDst)<0)
                    mapInd=[];
                    errId='Sldv:HarnessUtils:MakeSystemTestHarness:UnableMergeHarnessModels';
                    return;
                end
            end



            destCnt=length(destNames);
            mapInd=-1*ones(1,destCnt);
            mapInd(origIdxDst)=1:length(srcNames);
        end

        function time=getTimeAsCellArray(obj)
            [time,~]=signalbuilder(obj.blockH);
            if~iscell(time)
                time={time};
            end
        end

        function out=getDataAsCellArray(obj)
            [~,data]=signalbuilder(obj.blockH);
            if~iscell(data)
                data={data};
            end


            out=cellfun(@(x)x',data,'UniformOutput',false);
        end

        function setActiveTestcase(obj,testCaseId)
            signalbuilder(obj.blockH,'ActiveGroup',testCaseId);
        end

        function actSigbIdx=getActiveTestcase(obj)
            actSigbIdx=signalbuilder(obj.blockH,'ActiveGroup');
        end

        function testcaseNames=getNamesOfTestcases(obj)
            [~,~,~,testcaseNames]=signalbuilder(obj.blockH);
        end

        function signalNames=getNamesOfSignals(obj)
            [~,~,signalNames]=signalbuilder(obj.blockH);
        end

        function addTestcases(~,~,~,~)






            error('Function not implemented for Signal Builder');
        end
    end
end
