classdef DataUtils





    methods(Static)

        function undecObjIndices=getUndecObjectives(objectives)
            undecObjIndices=[];
            if~isempty(objectives)
                objStatuses={objectives.status};
                possibleUndecStatuses={'Undecided','Undecided with testcase',...
                'Undecided due to runtime error'};
                undecObjFlags=cellfun(@(str)ismember(str,possibleUndecStatuses),objStatuses);
                undecObjIndices=find(undecObjFlags);
            end
        end

        function[satObjectives,satObjIndices]=getSatisfiedObjs(objectives)
            satObjectives=[];
            if~isempty(objectives)
                satObjFlags=arrayfun(@(objective)~isempty(objective.testCaseIdx),objectives);
                satObjIndices=find(satObjFlags);
                satObjectives=objectives(satObjFlags);
            end
        end


        function testPrefixes=getTCPrefixes(sldvData,objIndices,usePredecessorPrefix)
            if nargin~=3
                usePredecessorPrefix=false;
            end
            if isfield(sldvData,'TestCases')
                utils=Sldv.Analysis.DataUtils;
                if nargin<2
                    [~,objIndices]=utils.getSatisfiedObjs(sldvData.Objectives);
                end
                objTCMapping=utils.getObjTCInfo(objIndices,sldvData.Objectives);
                sampleTimes=sldvData.AnalysisInformation.SampleTimes;
                testPrefixes=utils.trimTestCases(objTCMapping,sldvData.TestCases,sampleTimes,usePredecessorPrefix);
            else
                testPrefixes=[];
            end
        end



        function trimmedTCs=trimTestCases(objectives,testCases,sampleTimes,usePredecessorPrefix)

            if isempty(objectives)
                trimmedTCs=[];
                return;
            end
            sampleTime=sampleTimes(1);

            newTestCases=struct([]);
            try
                for i=1:length(objectives)


                    timeValues=testCases(objectives(i).tcIdx).timeValues;
                    stepValues=testCases(objectives(i).tcIdx).stepValues;




                    objX=testCases(objectives(i).tcIdx).objectives;
                    tStep=0;
                    for j=1:length(objX)
                        if(objX(j).objectiveIdx==objectives(i).idx)
                            tStep=objX(j).atStep;
                            if usePredecessorPrefix&&tStep~=1
                                tStep=tStep-1;
                            end
                            break;
                        end
                    end



                    idx=-1;
                    for k=1:length(stepValues)-1
                        if(tStep>=stepValues(k)&&tStep<stepValues(k+1))
                            idx=k;
                            break;
                        end
                    end

                    status=false;








                    if(idx==-1&&stepValues(end)==tStep)
                        idx=length(stepValues);
                    end


                    stepValuesX=stepValues(1:idx);
                    timeValuesX=timeValues(1:idx);



                    if(stepValuesX(end)~=tStep)
                        steps=tStep-stepValuesX(end);
                        stepValuesX(end+1)=tStep;%#ok<AGROW> % put this step value at the end
                        timeValuesX(end+1)=timeValuesX(end)+sampleTime*steps;%#ok<AGROW> % calculate the corresponding time value (you can get this value from objX also, no need to calculate explicitly)
                        status=true;
                    end


                    dataValues=testCases(objectives(i).tcIdx).dataValues;
                    dataValuesX=Sldv.Analysis.DataUtils.trimDataValues(dataValues,idx,status);



                    newTestCases(end+1).timeValues=timeValuesX;%#ok<AGROW>
                    newTestCases(end).stepValues=stepValuesX;
                    newTestCases(end).dataValues=dataValuesX;


                    newTestCases(end).paramValues=testCases(objectives(i).tcIdx).paramValues;
                    newTestCases(end).objectives=testCases(objectives(i).tcIdx).objectives;
                    newTestCases(end).testCaseId=testCases(objectives(i).tcIdx).testCaseId;

                    dataNoEffectValues=testCases(objectives(i).tcIdx).dataNoEffect;
                    dataNoEffectValuesX=Sldv.Analysis.DataUtils.trimDataValues(dataNoEffectValues,idx,status);
                    newTestCases(end).dataNoEffect=dataNoEffectValuesX;

                    if isfield(testCases,'expectedOutput')
                        expOutputValues=testCases(objectives(i).tcIdx).expectedOutput;
                        expOutputValuesX=Sldv.Analysis.DataUtils.trimDataValues(expOutputValues,tStep,status);
                        newTestCases(end).expectedOutput=expOutputValuesX;
                    end

                end
            catch MEx

                newTestCases=struct([]);
                LoggerId='sldv::task_manager';
                sldvprivate('SLDV_LOG_DEBUG',LoggerId,'Analysis::TestPrefixes - ERROR');
                sldvprivate('SLDV_LOG_DEBUG',LoggerId,MEx.message);

            end
            trimmedTCs=newTestCases;



        end



        function resValues=trimDataValues(dataValues,idx,status)


















            if(iscell(dataValues))

                utils=Sldv.Analysis.DataUtils;

                d=dataValues(1:end);
                for i=1:length(d)

                    trimmedValues{i}=utils.trimDataValues(d{i},idx,status);%#ok<AGROW>
                end



                resValues=reshape(trimmedValues,size(dataValues));
            else

                dim=size(dataValues);
                l=length(dim);

                arr=eval(['dataValues(',repmat(':,',1,l-1),'1:idx);']);
                if(status)
                    eval(['arr(',repmat(':,',1,l-1),'end + 1) = arr(',repmat(':,',1,l-1),'end);']);
                end
                resValues=arr;
            end
        end





        function objStruct=getObjTCInfo(candObjIndices,objectives)
            objStruct=[];
            for candObjIdx=candObjIndices

                candObjective=objectives(candObjIdx);
                if isfield(candObjective,'testCaseIdx')&&...
                    ~isempty(candObjective.testCaseIdx)
                    objStruct(end+1).idx=candObjIdx;%#ok<AGROW>
                    objStruct(end).tcIdx=candObjective.testCaseIdx;
                end
            end
        end

        function completeData=updateSldvObjectivesData(existingData,incrementalResults)
            completeData=existingData;
            if~isfield(incrementalResults,'TestCases')||...
                isempty(incrementalResults.TestCases)
                return;
            end

            if(~isfield(existingData,'TestCases')||isempty(existingData.TestCases))
                completeData.TestCases=[];
            end
            oldTestCaseLength=length(completeData.TestCases);
            completeData.TestCases=[completeData.TestCases,incrementalResults.TestCases];



            testCaseObjectives=[incrementalResults.TestCases.objectives];
            objectiveIndices=[testCaseObjectives.objectiveIdx];

            for index=objectiveIndices
                if strcmp(existingData.Objectives(index).status,'Undecided')
                    completeData.Objectives(index).testCaseIdx=[];
                    newObj=incrementalResults.Objectives(index);
                    newObj.status='Satisfied-needs simulation';
                    newObj.testCaseIdx=newObj.testCaseIdx+oldTestCaseLength;
                    completeData.Objectives(index)=newObj;
                end
            end
        end
    end
end

