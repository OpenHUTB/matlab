function discretizeEquations(obj)





    simscapeModel=obj.SimscapeModel;
    try

        solverConfiguration=obj.SolverConfiguration;
        sampleTimes=ones(1,numel(solverConfiguration));


        for i=1:numel(solverConfiguration)
            solverBlk=solverConfiguration{i};
            sampleTime=slResolve(get_param(solverBlk,'LocalSolverSampleTime'),solverBlk);
            sampleTimes(i)=sampleTime;
            solverBlks{i}=solverBlk;
        end


        if obj.SolverTypes(1)

            for i=1:numel(obj.PartSolvers)

                obj.PartSolvers{i}=obj.PartSolvers{i}.setSampleTime(sampleTimes(i));

                obj.PartSolvers{i}=obj.PartSolvers{i}.discretizeEqns;
            end

        else
            obj.StateSpaceParameters=processInfo(obj.StateSpaceParametersDeamon,simscapeModel,solverBlks,obj);


            modeArray=ones(1,numel(obj.StateSpaceParameters));

            for i=1:numel(obj.StateSpaceParameters)
                modeArray(i)=obj.StateSpaceParameters(i).NumberOfSwitchingModes;
            end



            if all(modeArray==1)
                obj.NumberOfSolverIterations=1;
            end

        end


    catch me
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

function stateSpaceParameters=processInfo(info,simscapeModel,solverBlks,obj)


    stateSpaceParameters=struct;

    configSet=getActiveConfigSet(simscapeModel);

    simulationTime=get_param(configSet,'StopTime');
    simulationTime=slResolve(simulationTime,simscapeModel);

    stateSpaceParameters.SimulationTime=simulationTime;

    for i=1:numel(info)

        solverBlk=solverBlks{i};

        sampleTime=slResolve(get_param(solverBlk,'LocalSolverSampleTime'),solverBlk);

        stateSpaceParameters(i).DiscreteSampleTime=sampleTime;



        if~(strcmpi(get_param(solverBlk,'LocalSolverChoice'),'NE_PARTITIONING_ADVANCER')...
            &&strcmpi(hdlfeature('SSCHDLNonLinear'),'on'))
            if isempty(info)



                me=MException('getStateSpaceParameters:GetStateSpaceParametersFailed',...
                message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:GetStateSpaceParametersFailed',simscapeModel).getString);
                throwAsCaller(me);
            else

                numModes=numel(info(i).data);
            end
        else
            numModes=1;
        end
        stateSpaceParameters(i).NumberOfSwitchingModes=numModes;
        if numModes==0

            me=MException('getStateSpaceParameters:ZeroSwitchingModes',...
            message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:ZeroSwitchingModes',simscapeModel).getString);
            throwAsCaller(me);
        else


            stateSpaceParameters(i).Solver='NE_BACKWARD_EULER_ADVANCER';

            if strcmpi(hdlfeature('SSCHDLNonLinear'),'on')


                stateSpaceParameters(i).Md=zeros(size(info(i).data(1).M,1),size(info(i).data(1).M,2),numModes);
            end



            if~isempty(obj.linearModel)

                newStateStart=size(info(i).data(1).A,1);
                X0addition=[];
                if~isempty(obj.linearizationInfo(i).switchValues)
                    X0addition=[X0addition,obj.linearizationInfo(i).switchValues.initV.value,...
                    obj.linearizationInfo(i).switchValues.initI.value];%#ok<AGROW>
                end
                if~isempty(obj.linearizationInfo(i).diodeValues)
                    X0addition=[X0addition,obj.linearizationInfo(i).diodeValues.initV.value,...
                    obj.linearizationInfo(i).diodeValues.initI.value];%#ok<AGROW>
                end
                if~isempty(obj.linearizationInfo(i).IGBTValues)
                    X0addition=[X0addition,obj.linearizationInfo(i).IGBTValues.initV.value,...
                    obj.linearizationInfo(i).IGBTValues.initI.value];%#ok<AGROW>
                end
                if~isempty(obj.linearizationInfo(i).nlInductorValues)
                    X0addition=[X0addition,obj.linearizationInfo(i).nlInductorValues.initV.value,...
                    obj.linearizationInfo(i).nlInductorValues.initI.value];%#ok<AGROW>
                end
                X0addition=X0addition';

                preprocessedInfo=processLinearizedDAE(info(i),...
                [obj.linearizationInfo(i).switchMap;obj.linearizationInfo(i).diodeMap;obj.linearizationInfo(i).IGBTMap;obj.linearizationInfo(i).nlInductorMap],...
                size(obj.linearizationInfo(i).switchMap,1)+size(obj.linearizationInfo(i).IGBTMap,1),X0addition);

                obj.linearizationInfo(i).newSwitchMap=[newStateStart-1+(1:size(obj.linearizationInfo(i).switchMap,1))'*2,...
                newStateStart+(1:size(obj.linearizationInfo(i).switchMap,1))'*2];

                newStateStart=newStateStart+size(obj.linearizationInfo(i).switchMap,1)*2;

                obj.linearizationInfo(i).newDiodeMap=[newStateStart-1+(1:size(obj.linearizationInfo(i).diodeMap,1))'*2,...
                newStateStart+(1:size(obj.linearizationInfo(i).diodeMap,1))'*2];

                newStateStart=newStateStart+size(obj.linearizationInfo(i).diodeMap,1)*2;


                obj.linearizationInfo(i).newIGBTMap=[newStateStart-1+(1:size(obj.linearizationInfo(i).IGBTMap,1))'*2,...
                newStateStart+(1:size(obj.linearizationInfo(i).IGBTMap,1))'*2];

                newStateStart=newStateStart+size(obj.linearizationInfo(i).IGBTMap,1)*2;

                obj.linearizationInfo(i).newInductorMap=[newStateStart-1+(1:size(obj.linearizationInfo(i).nlInductorMap,1))'*2,...
                newStateStart+(1:size(obj.linearizationInfo(i).nlInductorMap,1))'*2];

                obj.linearizationInfo(i).NumInputs=size(preprocessedInfo.data(1).B,2);
            else
                preprocessedInfo=info(i);

            end







            numStateModes=numel(info(i).StateCoeffIndex);
            stateSpaceParameters(i).ModeVec2StateConfig=info(i).ModeVec2StateConfig;
            numOutputModes=numel(info(i).OutputCoeffIndex);
            stateSpaceParameters(i).ModeVec2OutputConfig=info(i).ModeVec2OutputConfig;


            stateSpaceParameters(i).Ad=zeros(size(preprocessedInfo.data(1).A,1),size(preprocessedInfo.data(1).A,2),numStateModes);
            stateSpaceParameters(i).Bd=zeros(size(preprocessedInfo.data(1).B,1),size(preprocessedInfo.data(1).B,2),numStateModes);
            stateSpaceParameters(i).F0d=zeros(size(preprocessedInfo.data(1).F0,1),size(preprocessedInfo.data(1).F0,2),numStateModes);
            stateSpaceParameters(i).Cd=zeros(size(preprocessedInfo.data(1).C,1),size(preprocessedInfo.data(1).C,2),numOutputModes);
            stateSpaceParameters(i).Dd=zeros(size(preprocessedInfo.data(1).D,1),size(preprocessedInfo.data(1).D,2),numOutputModes);
            stateSpaceParameters(i).Y0d=zeros(size(preprocessedInfo.data(1).Y0,1),size(preprocessedInfo.data(1).Y0,2),numOutputModes);
            stateSpaceParameters(i).mode=zeros(size(preprocessedInfo.data(1).MODE,1),size(preprocessedInfo.data(1).MODE,2),numModes);


            if isfield(preprocessedInfo.data(1),'Kx')
                stateSpaceParameters(i).Kxd=zeros(size(preprocessedInfo.data(1).Kx,1),size(preprocessedInfo.data(1).Kx,2),numStateModes);
                stateSpaceParameters(i).Kyd=zeros(size(preprocessedInfo.data(1).Ky,1),size(preprocessedInfo.data(1).Ky,2),numOutputModes);
            end


            numDiffVars=nnz(preprocessedInfo.data(1).M);









            for ii=1:numModes
                stateSpaceParameters(i).mode(:,:,ii)=preprocessedInfo.data(ii).MODE;
            end

            for ii=1:numStateModes
                uniqueConfigNum=info(i).StateCoeffIndex(ii);

                Q=preprocessedInfo.data(ii).M/sampleTime-preprocessedInfo.data(uniqueConfigNum).A;
                numDiffVarsForMode=nnz(preprocessedInfo.data(uniqueConfigNum).M);
                if(numDiffVars<numDiffVarsForMode)
                    numDiffVars=numDiffVarsForMode;
                end
                stateSpaceParameters(i).Ad(:,:,ii)=(Q\(preprocessedInfo.data(uniqueConfigNum).M/sampleTime));
                stateSpaceParameters(i).Bd(:,:,ii)=(Q\preprocessedInfo.data(uniqueConfigNum).B);
                stateSpaceParameters(i).F0d(:,:,ii)=(Q\preprocessedInfo.data(uniqueConfigNum).F0);
                if isfield(preprocessedInfo.data(1),'Kx')
                    stateSpaceParameters(i).Kxd(:,:,ii)=(Q\preprocessedInfo.data(uniqueConfigNum).Kx);
                end

            end

            for ii=1:numOutputModes
                uniqueConfigNum=info(i).OutputCoeffIndex(ii);
                stateSpaceParameters(i).Cd(:,:,ii)=(preprocessedInfo.data(uniqueConfigNum).C);
                stateSpaceParameters(i).Dd(:,:,ii)=(preprocessedInfo.data(uniqueConfigNum).D);
                stateSpaceParameters(i).Y0d(:,:,ii)=(preprocessedInfo.data(uniqueConfigNum).Y0);
                if isfield(preprocessedInfo.data(1),'Kx')
                    stateSpaceParameters(i).Kyd(:,:,ii)=preprocessedInfo.data(uniqueConfigNum).Ky;

                end

            end

        end

        numNonzeros=nnz(stateSpaceParameters(i).Ad)+nnz(stateSpaceParameters(i).Bd)+...
        nnz(stateSpaceParameters(i).F0d)+nnz(stateSpaceParameters(i).Cd)+...
        nnz(stateSpaceParameters(i).Dd)+nnz(stateSpaceParameters(i).Y0d);
        if numNonzeros==0

            me=MException('getStateSpaceParameters:GetStateSpaceParametersFailed',...
            message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:GetStateSpaceParametersFailed',simscapeModel).getString);
            throwAsCaller(me);
        end




        stateSpaceParameters(i).X0=preprocessedInfo.data(1).X;
        stateSpaceParameters(i).U0=preprocessedInfo.data(1).U;


        stateSpaceParameters(i).ComputeSwitchingMode=preprocessedInfo.code;

        if~isempty(stateSpaceParameters(i).Ad)

            numStates=numel(stateSpaceParameters(i).Ad(:,1,1));

            if(numDiffVars<numStates)&&(nnz(stateSpaceParameters(i).Ad(:,(numDiffVars+1):end,:))==0)
                stateSpaceParameters(i).NumberOfDiffVars=numDiffVars;
            end
        end

    end
end


function newinfo=processLinearizedDAE(info,converterMap,numVt,X0)
    newinfo=info;












    orderOutputIndices=reshape(converterMap(:,[2,3])',2*size(converterMap,1),1);
    for ii=1:numel(newinfo.data)


        newinfo.data(ii).A=[[newinfo.data(ii).A,zeros(size(newinfo.data(ii).A,1),2*size(converterMap,1))];...
        [newinfo.data(ii).C(orderOutputIndices,:),-eye(2*size(converterMap,1))]];


        newinfo.data(ii).M=[[newinfo.data(ii).M,zeros(size(newinfo.data(ii).M,1),2*size(converterMap,1))];...
        zeros(2*size(converterMap,1),size(newinfo.data(ii).M,1)+2*size(converterMap,1))];


        newinfo.data(ii).X=[newinfo.data(ii).X;X0];


        newinfo.data(ii).C(orderOutputIndices,:)=[];


        newinfo.data(ii).C=[newinfo.data(ii).C,zeros(size(newinfo.data(ii).C,1),2*size(converterMap,1))];


        newinfo.data(ii).B=[newinfo.data(ii).B;newinfo.data(ii).D(orderOutputIndices,:)];


        newinfo.data(ii).D(orderOutputIndices,:)=[];


        newinfo.data(ii).F0=[newinfo.data(ii).F0;newinfo.data(ii).Y0(orderOutputIndices,:)];
        newinfo.data(ii).Y0(orderOutputIndices,:)=[];




        newinfo.data(ii).Kx=newinfo.data(ii).B(:,converterMap(:,1));
        newinfo.data(ii).Ky=newinfo.data(ii).D(:,converterMap(:,1));


        newinfo.data(ii).B(:,converterMap(:,1))=[];
        newinfo.data(ii).D(:,converterMap(:,1))=[];


        newinfo.data(ii).B=[newinfo.data(ii).B,zeros(size(newinfo.data(ii).B,1),numVt)];
        newinfo.data(ii).D=[newinfo.data(ii).D,zeros(size(newinfo.data(ii).D,1),numVt)];
    end

    for ii=1:size(converterMap,1)

        expression='u\((\d+)\)';
        replace='u(${int2str(str2num($1)-1*(str2num($1)>=converterMap(ii,1)))})';
        newinfo.code=regexprep(newinfo.code,expression,replace);


    end

end




