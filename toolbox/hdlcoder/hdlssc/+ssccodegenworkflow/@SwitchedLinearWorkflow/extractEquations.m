function extractEquations(obj)




    if~isempty(obj.linearModel)
        simscapeModel=obj.linearModel;
    else
        simscapeModel=obj.SimscapeModel;
    end
    try

        simulationStopTime=slResolve(get_param(simscapeModel,'StopTime'),simscapeModel);

        if simulationStopTime==Inf
            me=MException('getStateSpaceParameters:InfStopTime',...
            message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:InfStopTime').getString);
            throwAsCaller(me);
        end


        solverConfiguration=obj.SolverConfiguration;
        sampleTimes=ones(1,numel(solverConfiguration));


        for i=1:numel(solverConfiguration)
            solverBlk=solverConfiguration{i};
            sampleTime=slResolve(get_param(solverBlk,'LocalSolverSampleTime'),solverBlk);
            sampleTimes(i)=sampleTime;
        end




        if(obj.SolverTypes(1))&&~(obj.linearize)
            maxSampleTime=max(sampleTimes);
            if maxSampleTime>simulationStopTime
                me=MException('extractEquations:ShortStopTime',...
                message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:ShortStopTime',...
                sprintf('%0.5g',simulationStopTime),...
                sprintf('%0.5g',maxSampleTime)).getString);
                throwAsCaller(me);
            end
        end

        simscapeModelObj=get_param(simscapeModel,'object');
        if~strcmpi(simscapeModelObj.SimulationStatus,'stopped')
            simscapeModelObj.term;
        end


        configSet=getActiveConfigSet(simscapeModel);
        if(isa(configSet,'Simulink.ConfigSetRef'))
            me=MException('extractEquations:UnsupportedRefConfigSet',...
            message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:UnsupportedRefConfigSet').getString);
            throwAsCaller(me);
        end
        singleRateFixedSolverIter=1;
        if obj.SolverTypes(1)

            simscape.engine.sli.sl.swldaemon('STOP')
            simscape.engine.sli.sl.swldaemon('START')
            sim(simscapeModel);
            simscapeInfo=simscape.engine.sli.sl.swldaemon('GET');
            simscape.engine.sli.sl.swldaemon('STOP')

            obj.StateSpaceParametersDeamon=simscapeInfo;
            networkNames=fields(simscapeInfo);
            obj.PartSolvers=cell(numel(networkNames),1);
            for i=1:numel(networkNames)
                obj.PartSolvers{i}=ssccodegenworkflow.PartitioningSolverImpl(simscapeInfo.(networkNames{i}),networkNames{i});

                emptyData=isempty(simscapeInfo.(networkNames{i}).IC.X)...
                &&isempty(simscapeInfo.(networkNames{i}).Y);

                if emptyData



                    me=MException('getStateSpaceParameters:GetStateSpaceParametersFailed',...
                    message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:GetStateSpaceParametersFailed',simscapeModel).getString);
                    throwAsCaller(me);
                end

                networksIteration(i)=double(simscapeInfo.(networkNames{i}).itersUsed);%#ok<AGROW>
                for j=1:numel(simscapeInfo.(networkNames{i}).ClumpInfo)
                    if~isempty(simscapeInfo.(networkNames{i}).ClumpInfo(j).ModeFcn)
                        psSingleMode{singleRateFixedSolverIter}=simscapeInfo.(networkNames{i}).ClumpInfo(j).ModeFcn;%#ok<AGROW,NASGU> 
                        singleRateFixedSolverIter=singleRateFixedSolverIter+1;
                    end
                end
            end
            fixedCost=get_param(solverBlk,'DoFixedCost');
            maxAllowedIters=obj.MaxAllowedIters;
            maxIters=max(networksIteration);
            if strcmp(fixedCost,'off')

                if maxIters==0
                    obj.NumberOfSolverIterations=1;
                elseif maxIters>0
                    obj.NumberOfSolverIterations=maxIters;
                else
                    obj.NumberOfSolverIterations=maxAllowedIters+1;
                end
            else
                if singleRateFixedSolverIter>1
                    obj.NumberOfSolverIterations=str2double(get_param(solverBlk,'MaxNonlinIter'));
                else
                    obj.NumberOfSolverIterations=1;
                    obj.NumFixedCostIters=1;
                end

            end


        else






            maxAllowedIters=obj.MaxAllowedIters;

            solverBlks=obj.SolverConfiguration;
            cleanupFcns=cell(2,numel(solverBlks));
            for i=1:numel(solverBlks)
                if~isempty(obj.linearModel)


                    nameParts=split(solverBlks{i},'/');
                    nameParts{1}=obj.linearModel;
                    solverBlk=join(nameParts,'/');
                    solverBlk=solverBlk{1};
                else
                    solverBlk=solverBlks{i};
                end

                fixedCost=get_param(solverBlk,'DoFixedCost');




                if strcmp(fixedCost,'off')

                    defaultNonlinIter=get_param(solverBlk,'MaxNonlinIter');
                    cleanupFcns{1,i}=onCleanup(@()set_param(solverBlk,'DoFixedCost',fixedCost));
                    cleanupFcns{2,i}=onCleanup(@()set_param(solverBlk,'MaxNonlinIter',defaultNonlinIter));


                    set_param(solverBlk,'DoFixedCost','on')
                    set_param(solverBlk,'MaxNonlinIter',num2str(maxAllowedIters))

                end


            end




            simscape.engine.sli.sl.daemon('STOP');

            consistent_only=false;

            simscape.engine.sli.sl.daemon('START','ConsistentOnly',consistent_only,'EnablePrediction',false);

            sim(simscapeModel);

            simscapeInfo=simscape.engine.sli.sl.daemon('GET');

            simscape.engine.sli.sl.daemon('STOP');




            if~strcmpi(hdlfeature('SSCHDLNonLinear'),'on')
                if isempty(simscapeInfo)



                    me=MException('getStateSpaceParameters:GetStateSpaceParametersFailed',...
                    message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:GetStateSpaceParametersFailed',simscapeModel).getString);
                    throwAsCaller(me);
                else

                    numModes=zeros(1:numel(simscapeInfo));
                    for i=1:numel(simscapeInfo)
                        numModes(i)=numel(simscapeInfo(i).data);
                    end
                end
            else



                numModes=1;
            end
            obj.StateSpaceParametersDeamon=removeDuplicateConfigs(simscapeInfo);


            if any(~numModes)

                me=MException('getStateSpaceParameters:ZeroSwitchingModes',...
                message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:ZeroSwitchingModes',simscapeModel).getString);
                throwAsCaller(me);
            end



            configSet=getActiveConfigSet(simscapeModel);

            simulationTime=get_param(configSet,'StopTime');
            stateSpaceParameters=obj.StateSpaceParameters;
            for i=1:numel(simscapeInfo)
                stateSpaceParameters(i).SimulationTime=slResolve(simulationTime,simscapeModel);
            end
            obj.StateSpaceParameters=stateSpaceParameters;



            if strcmp(fixedCost,'off')
                maxIters=max([simscapeInfo.itersUsed]);
                if maxIters==0
                    obj.NumberOfSolverIterations=1;
                elseif maxIters>0
                    obj.NumberOfSolverIterations=maxIters;
                else
                    obj.NumberOfSolverIterations=maxAllowedIters+1;
                end
            else
                obj.NumberOfSolverIterations=str2double(get_param(solverBlks{1},'MaxNonlinIter'));
            end
        end
    catch me

        if obj.SolverTypes(1)
            simscape.engine.sli.sl.swldaemon('STOP')
        else
            simscape.engine.sli.sl.daemon('STOP');
        end

        if~isempty(me.cause)&&...
            contains(me.cause{1}.identifier,'InternalError','IgnoreCase',true)


            me=MException('getStateSpaceParameters:GetStateSpaceParametersFailed',...
            message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:GetStateSpaceParametersFailed',simscapeModel).getString);
            throwAsCaller(me);
        else
            throwAsCaller(me);
        end
    end
end

function info=removeDuplicateConfigs(info)


    for i=1:numel(info)
        [numStates,numInputs,numOutputs]=getInfoSize(info(i));

        statennz=sum(arrayfun(@(data)nnz(data.M)+nnz(data.A)+nnz(data.B)+nnz(data.F0),info(i).data));
        outputnnz=sum(arrayfun(@(data)nnz(data.C)+nnz(data.D)+nnz(data.Y0),info(i).data));
        stateCoeefs=spalloc(numStates^2*2+numStates*(numInputs+1),numel(info(i).data),statennz);
        outputCoeefs=spalloc(numStates*numOutputs+numOutputs*(numInputs+1),numel(info(i).data),outputnnz);
        for j=1:numel(info(i).data)
            stateCoeefs(:,j)=[info(i).data(j).M(:);info(i).data(j).A(:);info(i).data(j).B(:);info(i).data(j).F0(:)];%#ok<SPRIX>
            outputCoeefs(:,j)=[info(i).data(j).C(:);info(i).data(j).D(:);info(i).data(j).Y0(:)];%#ok<SPRIX>
        end

        [~,indStateCoeff,modeVec2uniqueStateCoeff]=unique(stateCoeefs','rows','stable');
        info(i).StateCoeffIndex=indStateCoeff;
        info(i).ModeVec2StateConfig=modeVec2uniqueStateCoeff;

        [~,indStateCoeff,modeVec2uniqueStateCoeff]=unique(outputCoeefs','rows','stable');
        info(i).OutputCoeffIndex=indStateCoeff;
        info(i).ModeVec2OutputConfig=modeVec2uniqueStateCoeff;

    end
end

function[numStates,numInputs,numOutputs]=getInfoSize(info)

    assert(isfield(info,'data'),'Extract state space parameters returned unexpected values');
    assert(isfield(info.data(1),'M'),'Extract state space parameters returned unexpected values');
    assert(isfield(info.data(1),'B'),'Extract state space parameters returned unexpected values');
    assert(isfield(info.data(1),'C'),'Extract state space parameters returned unexpected values');

    numStates=size(info.data(1).M,1);
    numInputs=size(info.data(1).B,2);
    numOutputs=size(info.data(1).C,1);

    assert(numStates>=0,'Extract state space parameters returned unexpected values')
    assert(numInputs>=0,'Extract state space parameters returned unexpected values')
    assert(numOutputs>=0,'Extract state space parameters returned unexpected values')

end


