



















classdef LinearModel<handle
    properties(SetAccess=private,Dependent)
DependentFiles
    end

    properties(SetAccess=?SimBiology.function.SimFunction)

InputValueInfo
    end




    properties(Access=private,Transient)
Implementation
    end

    properties(Access=private)
ImplementationConstructorArguments
    end

    properties(Access=private)
CompileData
        UseParallel=false













odedata
SimDataMetadata
    end

    properties(SetAccess=private,GetAccess={?SimBiology.function.SimFunction,?SimBiology.function.SimFunctionSensitivity})







        wasLoadedFrom14bOrEarlierMatFile=false;

    end
    methods(Hidden,Access={?SimBiology.function.SimFunction,?SimBiology.function.SimFunctionSensitivity})



        function compileData=getCompileData(obj)
            compileData=obj.CompileData;
        end
    end


    methods(Static,Hidden,Access=public)

        function out=loadobj(objIn)

            if~isfield(objIn.CompileData.LinearModelInfo,'SensitivityAnalysis')




                objIn.CompileData.LinearModelInfo.SensitivityAnalysis=false;
                objIn.CompileData.LinearModelInfo.SensitivityOutputs=[];
                objIn.CompileData.LinearModelInfo.SensitivityInputs=[];
                objIn.CompileData.LinearModelInfo.SensitivityNormalization='';

                objIn.ImplementationConstructorArguments{1}.SensitivityAnalysis=false;
                objIn.ImplementationConstructorArguments{1}.SensitivityInputs=struct('Type',cell(0,0),'Idx',cell(0,0));
                objIn.ImplementationConstructorArguments{1}.SensitivityOutputs=struct('Type',cell(0,0),'Idx',cell(0,0));
                objIn.ImplementationConstructorArguments{1}.SensitivityNormalization='';

                objIn.ImplementationConstructorArguments{1}.dKf_dki={};
                objIn.ImplementationConstructorArguments{1}.dKz_dki={};

                nSpecies=size(objIn.CompileData.LinearModelInfo.S,1);
                objIn.ImplementationConstructorArguments{1}.Aaug=sparse(zeros(nSpecies));
                objIn.ImplementationConstructorArguments{1}.Baug=sparse(zeros(nSpecies,1));

                objIn.Implementation=[];

                objIn.wasLoadedFrom14bOrEarlierMatFile=true;

                objIn.odedata=struct();
                objIn.odedata.SensitivityAnalysis=false;
            end

            if isempty(objIn.InputValueInfo)&&isfield(objIn.odedata,'X0Objects')&&isfield(objIn.odedata,'PObjects')

                objIn.InputValueInfo=SimBiology.internal.LinearModel.constructInputValueInfo(objIn.CompileData,obj.odedata.X0Objects,obj.odedata.PObjects);
            end
            out=objIn;
        end

    end

    methods(Access=public,Static)


















        function[tfCanSolve,obj,info,compileData]=compile(model,configset,compiledModelMap,odedata,useParallel)
            [tfCanSolve,compileData,info]=pkcompile(model,configset,compiledModelMap,odedata);
            if tfCanSolve
                obj=SimBiology.internal.LinearModel(compileData,odedata,useParallel);
            else
                obj=[];
            end
        end
    end

    methods(Static,Access=private)

        function inputValueInfo=constructInputValueInfo(compileData,xObjects,pObjects)


            allValueInfo=[xObjects;pObjects];
            inputValueInfo=repmat(allValueInfo(1),size(compileData.iEstimated.tfY));
            pObjects=[pObjects;xObjects(compileData.tfYBelongsInP)];
            xObjects=xObjects(~compileData.tfYBelongsInP);
            inputValueInfo(compileData.iEstimated.tfY)=xObjects(compileData.iEstimated.idxY);
            inputValueInfo(compileData.iEstimated.tfP)=pObjects(compileData.iEstimated.idxP);
        end
    end

    methods(Access=public)



















        function[yOut,tOut,simdata]=regressionFcn(obj,phi,tOutput,doseTable,v,tStop,warnIfErrors,isDurationParameter,isLagParameter,doseErrorMessages)
            v=reshape(v,1,[]);

            if~exist('warnIfErrors','var')
                warnIfErrors=false;
            end

            if~exist('isDurationParameter','var')
                isDurationParameter=false(size(phi,2),1);
            end

            if~exist('isLagParameter','var')
                isLagParameter=false(size(phi,2),1);
            end

            if~exist('tStop','var')
                tStop=[];
            end












            doseTargetIdx=vertcat(obj.CompileData.DoseInfo.doseY.Idx);
            doseTargetType=vertcat(obj.CompileData.DoseInfo.doseY.Type);
            assert(all(doseTargetType=='y'));

            nGroups=numel(v);



            errorMessages=cell(nGroups,1);

            if~exist('doseErrorMessages','var')
                doseErrorMessages=cell(nGroups,1);
            end





            invalids1=obj.validatePhi(phi);
            if any(invalids1(:))
                errorMessages(invalids1)={'Parameter value was not finite or a negative value was passed for the initial estimate of a compartment volume or species'};
            end

            invalids2=any(isnan(phi),2);
            if any(invalids2(:))
                errorMessages(invalids2)=strcat(errorMessages(invalids2),sprintf('\n Parameter value was NaN'));
            end

            invalids3=any(phi(:,isDurationParameter)<=0,2);
            if any(invalids3(:))
                errorMessages(invalids3)=strcat(errorMessages(invalids3),sprintf('\n The value of duration parameter should be greater than zero'));
            end

            invalids4=any(phi(:,isLagParameter)<0,2);
            if any(invalids4(:))
                errorMessages(invalids4)=strcat(errorMessages(invalids4),sprintf('\n The value of lag parameter should be non-negative'));
            end

            invalids5=~cellfun(@isempty,doseErrorMessages);

            if any(invalids5(:))
                errorMessages(invalids5)=strcat(errorMessages(invalids5),doseErrorMessages(invalids5));
            end

            invalidGroups=invalids2|invalids1|invalids3|invalids4|invalids5;
            validGroups=~invalidGroups;

            yOut=cell(nGroups,1);


            tOut=cell(nGroups,1);





            if any(validGroups)
                if~isempty(tStop)
                    [yOut(validGroups),tOut(validGroups),errorMessages(validGroups)]=simulate(obj,phi(validGroups,:),tOutput,doseTable,doseTargetIdx,v(validGroups),tStop(validGroups));
                else
                    [yOut(validGroups),tOut(validGroups),errorMessages(validGroups)]=simulate(obj,phi(validGroups,:),tOutput,doseTable,doseTargetIdx,v(validGroups));
                end
            end


            simDataInfo=obj.CompileData.SimDataInfo;
            numObserved=numel(simDataInfo.StatesToLogStruct);
            for i=1:nGroups
                if all(isnan(yOut{i}(:)))||invalidGroups(i)
                    if~isempty(tOutput{i})
                        tOut{i}=tOutput{i};
                    else
                        tOut{i}=0;
                    end
                    yOut{i}=NaN(numel(tOut{i}),numObserved);
                end
                if~isempty(errorMessages{i})&&warnIfErrors
                    warning(message('SimBiology:SimFunction:SomeSimulationsFailed',mat2str(phi(i,:)),errorMessages{i}));
                end
            end


            if nargout==3
                if isempty(obj.SimDataMetadata)
                    obj.SimDataMetadata=SimBiology.SimDataMetadata.construct(simDataInfo.StatesToLogStruct);
                end
                simdata(nGroups)=SimData;
                updatedConfigset=simDataInfo.ConfigSet;

                for id=1:nGroups
                    YAndPObserved=yOut{id};
                    updatedConfigset.StopTime=tOut{id}(end);
                    updatedConfigset.SolverOptions.OutputTimes=tOut{id};
                    simdata(id)=SimData.constructUsingModelInfo({{tOut{id},YAndPObserved,[]}},...
                    simDataInfo.ModelInfo,updatedConfigset,[],obj.SimDataMetadata,datestr(now),'sbiosimulate');
                end
            end
        end

        function[collapsedDoseTable,doseErrorMessages]=createDoseTable(obj,nIndividuals,doseTable)










            compileData=obj.CompileData;
            doseErrorMessages=cell(nIndividuals,1);

            dosingInfo=compileData.DoseInfo;
            doseTargetIdx=vertcat(compileData.DoseInfo.doseY.Idx);

            sensitivityAnalysis=compileData.LinearModelInfo.SensitivityAnalysis;
            sensitivityInputs=compileData.LinearModelInfo.SensitivityInputs;


            if isempty(doseTable)
                collapsedDoseTable=repmat({zeros(0,6)},nIndividuals,1);
                return
            end
            nColumn=6;

            for target_j=1:size(doseTable,2)
                for group_i=1:size(doseTable,1)
                    if size(doseTable{group_i,target_j})>0
                        doseTable{group_i,target_j}(end,nColumn)=0;
                    else
                        doseTable{group_i,target_j}=zeros(0,6);
                    end
                end
            end

            zeroOrderCount=0;
            lagCount=0;
            for target_j=1:size(doseTable,2)
                switch lower(dosingInfo.dosetype{target_j})
                case{'bolus','firstorder'}

                    for group_i=1:size(doseTable,1)


                        doseTable{group_i,target_j}(:,3)=1;

                        doseTable{group_i,target_j}(:,5)=doseTargetIdx(target_j)-1;
                    end

                case 'infusion'




                    timeColumn=1;
                    amountColumn=2;
                    rateColumn=3;
                    numColumns=3;
                    for group_i=1:size(doseTable,1)

                        table_i=doseTable{group_i,target_j};
                        if isempty(table_i)
                            continue;
                        end
                        nonZeroRateRows=table_i(:,rateColumn)~=0;
                        endDoseTable=zeros(sum(nonZeroRateRows),numColumns);
                        endDoseTable(:,timeColumn)=table_i(nonZeroRateRows,timeColumn)+table_i(nonZeroRateRows,amountColumn)./table_i(nonZeroRateRows,rateColumn);
                        endDoseTable(:,[amountColumn,rateColumn])=-table_i(nonZeroRateRows,[amountColumn,rateColumn]);


                        zeroRateRowIndex=find(~nonZeroRateRows);


                        doseTable{group_i,target_j}(size(table_i,1)+size(endDoseTable,1),nColumn)=0;

                        doseTable{group_i,target_j}(:,1)=[table_i(:,timeColumn);endDoseTable(:,timeColumn)];

                        doseTable{group_i,target_j}(:,2)=[table_i(:,rateColumn);endDoseTable(:,rateColumn)];
                        doseTable{group_i,target_j}(zeroRateRowIndex,2)=table_i(zeroRateRowIndex,amountColumn);

                        doseTable{group_i,target_j}(:,3)=2;
                        doseTable{group_i,target_j}(zeroRateRowIndex,3)=1;

                        doseTable{group_i,target_j}(:,4)=0;
                        doseTable{group_i,target_j}(:,5)=doseTargetIdx(target_j)-1;

                    end

                case 'zeroorder'


                    zeroOrderCount=zeroOrderCount+1;


                    for group_i=1:size(doseTable,1)

                        if any(doseTable{group_i,target_j}(:,3)~=0)
                            doseErrorMessages=strcat(doseErrorMessages(group_i),sprintf('\n Invalid dose table for group = %d. If DurationParameterName is configured to a parameter name then Rate must be 0',group_i));
                        end

                        originalNumRows=size(doseTable{group_i,target_j},1);


                        doseTable{group_i,target_j}(:,3)=2;

                        doseTable{group_i,target_j}(:,4)=dosingInfo.doseTk0(zeroOrderCount).Idx;

                        doseTable{group_i,target_j}(:,5)=doseTargetIdx(target_j)-1;







                        endDoseTable=doseTable{group_i,target_j};


                        endDoseTable(:,2)=-endDoseTable(:,2);

                        doseTable{group_i,target_j}(end+1:end+size(endDoseTable,1),:)=endDoseTable;





                        if(sensitivityAnalysis)


                            temp=find([sensitivityInputs.Idx]==dosingInfo.doseTk0(zeroOrderCount).Idx);


                            assert(numel(temp)<=1)

                            if~isempty(temp)







                                nStates=numel(compileData.iObserved.tfP)-length(compileData.LinearModelInfo.SensitivityOutputs);

                                sensDose=doseTable{group_i,target_j}(1:originalNumRows,:);
                                sensDose(:,3)=3;



                                sensDose(:,5)=sensDose(:,5)+temp*nStates;
                                doseTable{group_i,target_j}(end+1:end+size(sensDose,1),:)=sensDose;


                                sensDose(:,2)=-sensDose(:,2);
                                doseTable{group_i,target_j}(end+1:end+size(sensDose,1),:)=sensDose;
                            end
                        end
                    end

                otherwise
                    error(message('SimBiology:Internal:InternalError'));
                end


                if dosingInfo.hasLag(target_j)
                    lagCount=lagCount+1;
                    for group_i=1:size(doseTable,1)
                        doseTable{group_i,target_j}(:,6)=dosingInfo.doseLag(lagCount).Idx;
                    end
                end
            end


            collapsedDoseTable=cell(size(doseTable,1),1);
            for i=1:numel(collapsedDoseTable)
                collapsedDoseTable{i}=sortrows(vertcat(doseTable{i,:}));
            end
        end

    end

    methods(Access=private)




        function obj=LinearModel(compileData,odedata,useParallel)
            obj.CompileData=compileData;
            obj.UseParallel=useParallel;
            obj.odedata=odedata;
            obj.InputValueInfo=SimBiology.internal.LinearModel.constructInputValueInfo(compileData,odedata.X0Objects,odedata.PObjects);



            linearModelInfo=compileData.LinearModelInfo;
            obj.ImplementationConstructorArguments={linearModelInfo};
            obj.Implementation=SimBiology.internal.Code.LinearModel(obj.ImplementationConstructorArguments{:});
        end



        function[Y0AllGroups,PAllGroups]=getInitialValues(obj,nGroups)
            Y0=obj.CompileData.Y0;


            if obj.ImplementationConstructorArguments{1}.SensitivityAnalysis
                nInputs=numel(obj.ImplementationConstructorArguments{1}.SensitivityInputs);
                nStates=numel(Y0);





                sensInitial=zeros(nStates*nInputs,1);
                for kter=1:nInputs



                    if strcmp(obj.ImplementationConstructorArguments{1}.SensitivityInputs(kter).Type,'y')
                        sensInitial(nStates*(kter-1)+obj.ImplementationConstructorArguments{1}.SensitivityInputs(kter).Idx)=1;
                    end
                end

                Y0=[Y0;sensInitial];
            end
            Y0AllGroups=repmat(Y0,1,nGroups);
            PAllGroups=repmat(obj.CompileData.P,1,nGroups);
        end


        function[Y0AllGroups,PAllGroups]=applyPhi(obj,Y0AllGroups,PAllGroups,phi)
            iEstimated=obj.CompileData.iEstimated;
            units=obj.CompileData.Units;
            if units.tf

                phi(:,iEstimated.tfY)=phi(:,iEstimated.tfY).*units.YUCM(iEstimated.idxY,:)';
                phi(:,iEstimated.tfP)=phi(:,iEstimated.tfP).*units.PUCM(iEstimated.idxP,:)';
            end


            Y0AllGroups(iEstimated.idxY,:)=phi(:,iEstimated.tfY)';
            PAllGroups(iEstimated.idxP,:)=phi(:,iEstimated.tfP)';
        end


        function[Y0AllGroups,PAllGroups]=applyInitialAssignments(obj,Y0AllGroups,PAllGroups)
            n=size(Y0AllGroups,2);
            compileData=obj.CompileData;
            for i=1:numel(compileData.InitAsgnCode)
                initAsgn=compileData.InitAsgnCode(i);
                switch initAsgn.lhsVarType
                case 'y'
                    for j=1:n
                        Y0AllGroups(initAsgn.lhsVarIdx,j)=initAsgn.rhsFcn(0,Y0AllGroups(:,j),PAllGroups(:,j));
                    end
                case 'p'
                    for j=1:n
                        PAllGroups(initAsgn.lhsVarIdx,j)=initAsgn.rhsFcn(0,Y0AllGroups(:,j),PAllGroups(:,j));
                    end
                otherwise
                    error(message('SimBiology:Internal:InternalError'));
                end
            end
        end


        function Y0AllGroups=correctConcentrationSensWRTCompartmentVol(obj,Y0AllGroups)







            if obj.ImplementationConstructorArguments{1}.SensitivityAnalysis

                nInputs=numel(obj.ImplementationConstructorArguments{1}.SensitivityInputs);
                nStates=numel(obj.CompileData.Y0);










                xObjects=obj.odedata.X0Objects(~obj.CompileData.tfYBelongsInP);
                xObjectParents={xObjects.Parent};
                xObjectTypes={xObjects.Type};
                pObjects=[obj.odedata.PObjects;obj.odedata.X0Objects(obj.CompileData.tfYBelongsInP)];

                jter=1;
                for iter=nStates:nStates:(nStates*nInputs)
                    if strcmp(obj.ImplementationConstructorArguments{1}.SensitivityInputs(jter).Type,'p')



                        thisParameterObject=pObjects(obj.ImplementationConstructorArguments{1}.SensitivityInputs(jter).Idx);

                        if strcmp(thisParameterObject.Type,'compartment')





                            outputIsChild=strcmp(xObjectParents,thisParameterObject.QualifiedName)';




                            outputIsChild=outputIsChild(strcmp(xObjectTypes,'species'));

                            outputNeedsInit=outputIsChild&obj.CompileData.YSpInC.tf;
                            idxIntoState=find(outputNeedsInit);

                            if~isempty(idxIntoState)






                                Y0AllGroups(iter+idxIntoState,:)=Y0AllGroups(idxIntoState,:);
                            end

                        end

                    end

                    jter=jter+1;
                end
            end

        end


        function[Y0AllGroups,PAllGroups]=convertConcentrationToAmount(obj,Y0AllGroups,PAllGroups)
            ySpInC=obj.CompileData.YSpInC;
            stateTF=ySpInC.tf(1:length(obj.CompileData.Y0));
            Y0AllGroups(stateTF,:)=Y0AllGroups(stateTF,:).*...
            PAllGroups(ySpInC.Cidx(stateTF),:);

        end


        function out=validatePhi(obj,phi)

            out=any(~isfinite(phi),2);


            [rows,iPhi]=find(phi<0);
            invalids=false(size(phi,1),1);
            negTypes=obj.CompileData.PEMap.estimatedType;
            for k=1:numel(iPhi)
                switch negTypes{iPhi(k)}
                case{'compartment','species'}
                    invalids(rows(k))=true;
                end
            end

            out=out|invalids;
        end


        function[yOut,tOut,errorMessages]=simulate(obj,phi,tOutput,doseTable,doseTargetIdx,v,optionalTStop)


            nGroups=numel(v);

            if exist('optionalTStop','var')
                [logSolverAndOutputTimes,tOutput]=computeLogSolverAndOutputTimes(optionalTStop,tOutput,v);
            else
                logSolverAndOutputTimes=false(nGroups,1);
            end

            [Y0AllGroups,PAllGroups]=obj.getInitialValues(nGroups);
            [Y0AllGroups,PAllGroups]=obj.applyPhi(Y0AllGroups,PAllGroups,phi);

            PAllGroupsBeforeIAR=PAllGroups;
            Y0AllGroupsBeforeIAR=Y0AllGroups;

            [Y0AllGroups,PAllGroups]=obj.applyInitialAssignments(Y0AllGroups,PAllGroups);
            Y0AllGroups=obj.correctConcentrationSensWRTCompartmentVol(Y0AllGroups);
            [Y0AllGroups,PAllGroups]=obj.convertConcentrationToAmount(Y0AllGroups,PAllGroups);




            if isempty(obj.Implementation)
                obj.Implementation=SimBiology.internal.Code.LinearModel(obj.ImplementationConstructorArguments{:});
            end

            callback=SimBiology.function.internal.SimulationCallback.get();
            if~isempty(callback)
                SimBiology.internal.setLoggerCallback(@(status,~,~)callCallback(callback,status));
                removeCallback=onCleanup(@()SimBiology.internal.setLoggerCallback([]));
            end
            [yOut,tOut,errorMessages]=obj.Implementation.simulate(Y0AllGroups,PAllGroups,tOutput,doseTable,doseTargetIdx,v,logSolverAndOutputTimes);

            if obj.odedata.SensitivityAnalysis











                PAllGroupsWithDummy=[PAllGroups;ones(1,size(PAllGroups,2))];




                inputCIDX=obj.CompileData.LinearModelInfo.YInConc.SensInputsCIDX;
                outputCIDX=obj.CompileData.LinearModelInfo.YInConc.SensOutputsCIDX;



                inputCIDX(inputCIDX==0)=size(PAllGroupsWithDummy,1);
                outputCIDX(outputCIDX==0)=size(PAllGroupsWithDummy,1);

                for iter=1:numel(yOut)
                    outputSensArray=repmat(PAllGroupsWithDummy(outputCIDX,iter),1,length(inputCIDX));
                    inputSensArray=repmat(PAllGroupsWithDummy(inputCIDX,iter)',length(outputCIDX),1);
                    sensConversion=outputSensArray./inputSensArray;

                    yOut{iter}(:,(end+1-numel(sensConversion)):end)=yOut{iter}(:,(end+1-numel(sensConversion)):end)./sensConversion(:)';
                end

                unitConversion=~isempty(obj.CompileData.LinearModelInfo.UCM);
                sensitivityNormalization=obj.CompileData.LinearModelInfo.SensitivityNormalization;
                userOrderInputUuids=obj.CompileData.sensitivityInputUuids;
                numStatesToLog=sum(cellfun(@(x)~strcmp(x.Type,'sensitivity'),obj.CompileData.SimDataInfo.StatesToLogStruct));
                for iter=1:numel(yOut)
                    thisYData=yOut{iter};
                    nonConstParams=obj.CompileData.LinearModelInfo.ResponseStruct.stateIsNonConstParam;
                    if any(nonConstParams)





                        states=thisYData(:,1:numStatesToLog);
                        repeatedValues=thisYData(:,(numStatesToLog+1):(numStatesToLog+length(obj.odedata.sensOutputs)));
                        sensitivities=thisYData(:,(numStatesToLog+length(obj.odedata.sensOutputs)+1):end);



                        numSimDataStates=numel(obj.odedata.X0Objects);
                        sensStateIn=obj.odedata.sensStateInputs;
                        sensParamIn=numSimDataStates+obj.odedata.sensParamInputs;
                        simDataSensOrder=[sensStateIn;sensParamIn];
                        tfMove=obj.CompileData.tfYBelongsInP(sensStateIn);
                        linearSensOrder=[sensStateIn(~tfMove);sensParamIn;sensStateIn(tfMove)];
                        [tf,newInputOrder]=ismember(simDataSensOrder,linearSensOrder);
                        assert(all(tf),'Internal error. Unexpected ordering of sensitivity data.');
                        numStates=numel(obj.CompileData.Y0);
                        numInputs=length(obj.odedata.sensStateInputs)+length(obj.odedata.sensParamInputs);

                        assert(numStates*numInputs==size(sensitivities,2),'Internal error. Unexpected number of sensitivities.');
                        sensitivities=reshape(sensitivities,[],numStates,numInputs);
                        sensitivities=sensitivities(:,:,newInputOrder);
                        sensitivities=sensitivities(:,:);









                        fullSens0=full(obj.odedata.Sens0);
                        sensitivitiesCorrected=repmat(fullSens0(:)',size(thisYData,1),1);
                        sensitivitiesCorrected(:,repmat(~nonConstParams,numInputs,1))=sensitivities;

                        thisYData=[states,repeatedValues,sensitivitiesCorrected];

                    end










                    idxYinY=find(~obj.CompileData.tfYBelongsInP);
                    idxYinP=find(obj.CompileData.tfYBelongsInP);
                    numMovedParams=numel(idxYinP);
                    obj.odedata.P=PAllGroups(1:(end-numMovedParams),iter);
                    obj.odedata.PKCompileData.PBeforeInitAsgns=PAllGroupsBeforeIAR(1:(end-numMovedParams),iter);





                    obj.odedata.PKCompileData.X0BeforeInitAsgns(idxYinY,1)=Y0AllGroupsBeforeIAR(1:numel(idxYinY),iter);
                    obj.odedata.PKCompileData.X0BeforeInitAsgns(idxYinP,1)=PAllGroupsBeforeIAR(((end-numMovedParams+1):end),iter);

                    yOut{iter}=sbiogate('sensPostProcess',...
                    thisYData,obj.odedata,unitConversion,sensitivityNormalization,userOrderInputUuids,numStatesToLog);
                end
            end
        end
    end

    methods
        function value=get.DependentFiles(obj)
            if~isa(obj.odedata,'SimBiology.internal.ODESimulationData')
                value={};
            else
                value=obj.odedata.DependentFiles;
            end
        end
    end
end

function[tfaccel,pkcm,cinfo]=pkcompile(m,configset,mmap,odedata)























































































    if nargin<2||isempty(mmap)
        mmap=[];
    end

    if~feature('SimBioPKAccel')
        tfaccel=false;
        pkcm=[];
        cinfo='PKAccelFeatureOff';
        return
    end

    pkCompileData=localGetPKCompileData(odedata);
    pkCompileData.ModelInfo=struct('Name',m.Name,'UUID',m.UUID);


    speciesSSIDs=localObjArray2SIDs(m.Species,pkCompileData.YMap,pkCompileData.PMap);

    [cinfo,pkcm]=localPKCompile(pkCompileData,mmap,speciesSSIDs,configset,odedata);


    if localIsFatalErr(cinfo)
        tfaccel=false;
        pkcm=[];
        return
    end


    localThrowCompileWarningsIfNecessary(cinfo);

    tfaccel=true;
end

function pkcdata=localGetPKCompileData(odedata)





    pkcdata.Y0=odedata.PKCompileData.X0BeforeInitAsgns;
    pkcdata.P=odedata.PKCompileData.PBeforeInitAsgns;
    pkcdata.YObjects=odedata.X0Objects;
    pkcdata.PObjects=odedata.PObjects;
    if isempty(odedata.XUuids)

        pkcdata.YMap=containers.Map('KeyType','char','ValueType','double');
    else
        pkcdata.YMap=containers.Map(odedata.XUuids,1:numel(odedata.XUuids));
    end
    if isempty(odedata.PUuids)

        pkcdata.PMap=containers.Map('KeyType','char','ValueType','double');
    else
        pkcdata.PMap=containers.Map(odedata.PUuids,1:numel(odedata.PUuids));
    end
    pkcdata.YUCM=odedata.XUCM(:);
    pkcdata.PUCM=odedata.PUCM(:);
    pkcdata.UCtf=~isempty(odedata.XUCM)||~isempty(odedata.PUCM);
    pkcdata.TimeUnits=odedata.Units.TimeUnits;
    pkcdata.AmountUnits=odedata.Units.AmountUnits;
    pkcdata.MassUnits=odedata.Units.MassUnits;

    pkcdata.spCvsAInfo=odedata.PKCompileData.spCvsAInfo;

    pkcdata.reactions=odedata.PKCompileData.reactions;
    pkcdata.reactionDimInfo.dimExplicitAndValid=odedata.PKCompileData.reactionDimsExplicitlySpcfd;
    pkcdata.reactionDimInfo.isPerUnitLength=odedata.PKCompileData.reactionIsPerUnitLengthX;
    pkcdata.initasgns=odedata.PKCompileData.InitAsgns;
    pkcdata.Code.stoich=odedata.Stoich;
    pkcdata.Code.constStr=odedata.Code.constStr;
    pkcdata.numRateDoseTargets=odedata.numNonReactingSpeciesWithRateDoses;
    pkcdata.unsupportedconstructs=odedata.PKCompileData.unsupportedconstructs;
end

function[cInfo,pkcm]=localPKCompile(pkcd,mmap,speciesSSIDs,configset,odedata)










    cInfo=struct('status','ok','warns',{cell(0,0)},'errs',{cell(0,0)});
    pkcm=[];


    if pkcd.unsupportedconstructs.RateRules,cInfo=localUpdateCinfo(cInfo,'fatalerr','RateRulesPresent');end
    if pkcd.unsupportedconstructs.AlgRules,cInfo=localUpdateCinfo(cInfo,'fatalerr','AlgRulesPresent');end
    if pkcd.unsupportedconstructs.RptAsgns,cInfo=localUpdateCinfo(cInfo,'fatalerr','RptAsgnRulesPresent');end
    if pkcd.unsupportedconstructs.Events,cInfo=localUpdateCinfo(cInfo,'fatalerr','EventsPresent');end
    if localIsFatalErr(cInfo),return;end


    pkcd=localPKStateReorder(pkcd);


    if isempty(mmap)
        pkcm.DoseInfo=[];
        pkcm.PEMap=[];
    else
        [cInfo,...
        pkcm.DoseInfo.doseY,...
        pkcm.DoseInfo.dosetype,...
        pkcm.DoseInfo.doseTk0,...
        pkcm.DoseInfo.hasLag,...
        pkcm.DoseInfo.doseLag,...
        pkcm.PEMap.estimated,...
        pkcm.PEMap.observed,...
        pkcm.PEMap.estimatedType]=localCompileModelMap(cInfo,mmap,pkcd.YMap,pkcd.PMap);
        if localIsFatalErr(cInfo),return;end
    end
    if configset.SolverOptions.SensitivityAnalysis
        if odedata.SensitivityAnalysis


            pkcm.PEMap.observed=[pkcm.PEMap.observed,...
            localObjArray2SIDs(configset.SensitivityAnalysisOptions.Outputs,pkcd.YMap,pkcd.PMap)];
        else


            cInfo=localUpdateCinfo(cInfo,'fatalerr','SensitivityAnalysisNotSupported');
            return
        end
    end
    [pkcm.iEstimated,pkcm.iDosed,...
    pkcm.iObserved,pkcm.iDoseTK0]=findIndices(pkcm);


    [cInfo,Amat,Bmat]=localReactionCompile(cInfo,pkcd.reactions,pkcd.YMap,pkcd.PMap,pkcd.reactionDimInfo,pkcd.spCvsAInfo);
    if localIsFatalErr(cInfo),return;end


    pkcm.InitAsgnCode=localInitAsgnCompile(pkcd.initasgns,pkcd.YMap,pkcd.PMap);







    pkcm.tfYBelongsInP=pkcd.tfYBelongsInP;
    pkcm.Y0=pkcd.Y0;
    pkcm.P=pkcd.P(:);
    pkcm.Units.tf=pkcd.UCtf;
    pkcm.Units.YUCM=pkcd.YUCM;
    pkcm.Units.PUCM=pkcd.PUCM;
    pkcm.Units.TimeUnits=pkcd.TimeUnits;
    pkcm.Units.AmountUnits=pkcd.AmountUnits;
    pkcm.Units.MassUnits=pkcd.MassUnits;
    pkcm.SimDataInfo.ModelInfo=pkcd.ModelInfo;
    pkcm.SimDataInfo.ConfigSet=SimData.convertConfigsetToStruct(configset);
    statesToLog=configset.RuntimeOptions.StatesToLog;


    statestr=SimData.convertComponentToStruct(statesToLog);
    if odedata.SensitivityAnalysis

        inputIsParam=ismember(get(configset.SensitivityAnalysisOptions.Inputs,{'UUID'}),odedata.PUuids);
        userSensInputUUIDs=cell(length([odedata.UserSuppliedSensParamInputs;odedata.UserSuppliedSensStateInputs]),1);
        userSensInputUUIDs(inputIsParam)=odedata.PUuids(odedata.UserSuppliedSensParamInputs);
        userSensInputUUIDs(~inputIsParam)=odedata.XUuids(odedata.UserSuppliedSensStateInputs);
    else
        userSensInputUUIDs={};
    end

    [userSensMDstr,~,~,~,outputFullObj,inputObj]=SimData.constructSensitivityMetadata(odedata,configset.SensitivityAnalysisOptions,pkcd.ModelInfo.UUID,userSensInputUUIDs);


    outputFullObj=outputFullObj(strcmp({outputFullObj.Type},'species'));
    userSensMDstr=mat2cell(userSensMDstr(:),ones(numel(userSensMDstr),1));



    pkcm.SimDataInfo.StatesToLogStruct=[statestr(:);userSensMDstr(:)];


    [pkcm.YSpInC.tf,pkcm.YSpInC.Cidx]=localSpeciesCvsACompile(pkcd.spCvsAInfo,pkcd.YObjects,pkcd.PMap);
    [outputFullTF,outputCIDX]=localSpeciesCvsACompile(pkcd.spCvsAInfo,outputFullObj,pkcd.PMap);
    [inputTF,inputCIDX]=localSpeciesCvsACompile(pkcd.spCvsAInfo,inputObj,pkcd.PMap);


    if~isempty(userSensMDstr)
        pkcm.YSpInC.SensInputsTF=inputTF;
        pkcm.YSpInC.SensOutputsTF=outputFullTF;
        pkcm.YSpInC.SensInputsCIDX=inputCIDX;
        pkcm.YSpInC.SensOutputsCIDX=outputCIDX;








        stateIsNonConstParam=arrayfun(@(x)strcmp(x.Type,'parameter')&&~x.Constant,odedata.X0Objects);
        pkcm.iObserved.stateIsNonConstParam=stateIsNonConstParam;

    end

    pkcm.sensitivityInputUuids=get(configset.SensitivityAnalysisOptions.Inputs,{'UUID'});





    pkcm.LinearModelInfo=localLinearModelCompile(odedata,Amat,Bmat,pkcd,pkcm.iObserved,pkcm.YSpInC,speciesSSIDs,configset,pkcm.Units);





    pkcm.LinearModelInfo.LogSolverAndOutputTimes=configset.SolverOptions.LogSolverAndOutputTimes;
    pkcm.LinearModelInfo.MaximumNumberOfLogs=configset.MaximumNumberOfLogs;


    prettyOrder={'SimDataInfo';'Y0';'P';'Units';'YSpInC';'InitAsgnCode';'tfYBelongsInP';'DoseInfo';'PEMap';'iEstimated';'iDosed';'iObserved';'iDoseTK0';'LinearModelInfo';'sensitivityInputUuids'};
    pkcm=orderfields(pkcm,prettyOrder);
end

function pkcd=localPKStateReorder(pkcd)










    NY=numel(pkcd.Y0);
    if NY~=pkcd.YMap.Count
        error(message('SimBiology:Internal:InternalError'));
    end
    uuid=reshape(get(pkcd.YObjects,{'UUID'}),1,[]);
    if~all(pkcd.YMap.isKey(uuid))||~all(cell2mat(pkcd.YMap.values(uuid))==1:NY)
        error(message('SimBiology:Internal:InternalError'));
    end
    NP=numel(pkcd.P);
    if NP~=pkcd.PMap.Count
        error(message('SimBiology:Internal:InternalError'));
    end
    uuid=reshape(get(pkcd.PObjects,{'UUID'}),1,[]);
    if~all(pkcd.PMap.isKey(uuid))||~all(cell2mat(pkcd.PMap.values(uuid))==1:NP)
        error(message('SimBiology:Internal:InternalError'));
    end










    if pkcd.PMap.Count==0

        newParamMap=containers.Map('KeyType','char','ValueType','double');
    else
        newParamMap=containers.Map(pkcd.PMap.keys(),pkcd.PMap.values());
    end
    nextParamMapIndex=newParamMap.Count+1;


    newStatesMap=containers.Map('KeyType','char','ValueType','double');
    nextStatesMapIndex=1;
    tfYBelongsInP=false(NY,1);
    for c=1:NY
        obj=pkcd.YObjects(c);
        switch obj.Type
        case 'species'

            newStatesMap(obj.UUID)=nextStatesMapIndex;
            nextStatesMapIndex=nextStatesMapIndex+1;
        case{'parameter','compartment'}


            newParamMap(obj.UUID)=nextParamMapIndex;
            nextParamMapIndex=nextParamMapIndex+1;
            tfYBelongsInP(c)=true;
        otherwise
            error(message('SimBiology:Internal:InternalError'));
        end
    end

    pkcd.tfYBelongsInP=tfYBelongsInP;
    pkcd.YMap=newStatesMap;
    pkcd.PMap=newParamMap;

    pkcd.P=[pkcd.P;pkcd.Y0(tfYBelongsInP)];
    pkcd.PObjects=[pkcd.PObjects;pkcd.YObjects(tfYBelongsInP)];
    pkcd.Y0=pkcd.Y0(~tfYBelongsInP);
    pkcd.YObjects=pkcd.YObjects(~tfYBelongsInP);

    if pkcd.UCtf
        pkcd.PUCM=[pkcd.PUCM;pkcd.YUCM(tfYBelongsInP)];
        pkcd.YUCM=pkcd.YUCM(~tfYBelongsInP);
    end


    pkcd.Code=localPKCodeReorder(pkcd.Code,tfYBelongsInP,pkcd.numRateDoseTargets);
end

function code=localPKCodeReorder(code,tfYBelongsInP,numRateDoseTargets)

















    NStoichSys=size(code.stoich,1);
    NConstSys=size(code.constStr,1);
    tfIsConstStr=[false(NStoichSys,1);true(NConstSys+numRateDoseTargets,1)];


    assert(all((tfYBelongsInP&tfIsConstStr)==tfYBelongsInP),message('SimBiology:Internal:InternalError'));












    NReactions=size(code.stoich,2);
    S=[code.stoich;zeros(NConstSys,NReactions)];




    S=S(~tfYBelongsInP,:);

    code.stoich=S;
    code=rmfield(code,'constStr');
end

function[info]=localLinearModelCompile(odedata,Amat,Bmat,pkcd,iObserved,YInConc,allStatesInfo,configSet,units)




























    solverOptions=configSet.SolverOptions;
    info.A=sparse(Amat);
    info.B=sparse(Bmat);
    info.S=sparse(pkcd.Code.stoich);
    info.ResponseStruct=iObserved;

    nSpecies=size(info.S,1);

    info.YInConc=YInConc;
    info.AbsoluteTolerance=solverOptions.AbsoluteTolerance;
    info.RelativeTolerance=solverOptions.RelativeTolerance;
    if units.tf
        info.UCM=zeros(numel(iObserved.tfY),1);
        info.UCM(iObserved.tfY)=units.YUCM(iObserved.idxY);
        info.UCM(iObserved.tfP)=units.PUCM(iObserved.idxP);
    else
        info.UCM=[];
    end

    if configSet.SolverOptions.SensitivityAnalysis




        tfNonConstParamSensInput=iObserved.stateIsNonConstParam(odedata.sensStateInputs);
        nonConstParamSensInputUuids=odedata.XUuids(odedata.sensStateInputs(tfNonConstParamSensInput));
        nonConstParamSensInputs=cell2mat(pkcd.PMap.values(nonConstParamSensInputUuids));
        sensStateInputs=odedata.sensStateInputs(~tfNonConstParamSensInput);
        sensParamInputs=[odedata.sensParamInputs;nonConstParamSensInputs];
        info.SensitivityInputs=localOdeSensArray2SIDs(sensStateInputs,sensParamInputs);




        info.SensitivityOutputs=localObjArray2SIDs(odedata.X0Objects(~iObserved.stateIsNonConstParam),...
        pkcd.YMap,pkcd.PMap);

        info.SensitivityNormalization=configSet.SensitivityAnalysisOptions.Normalization;
        info.SensitivityAnalysis=true;







        info.dKf_dki=cell(numel(info.SensitivityInputs),1);
        info.dKz_dki=cell(numel(info.SensitivityInputs),1);
        S_dKf_dki=cell(numel(info.SensitivityInputs),1);
        S_dKz_dki=cell(numel(info.SensitivityInputs),1);
        for i=1:numel(info.SensitivityInputs)
            info.dKf_dki{i}=sparse(d_dki(Amat,info.SensitivityInputs(i)));
            info.dKz_dki{i}=sparse(d_dki(Bmat,info.SensitivityInputs(i)));
            S_dKf_dki{i}=info.S*info.dKf_dki{i};
            info.dKf_dki{i}=S_dKf_dki{i};
            S_dKz_dki{i}=info.S*info.dKz_dki{i};
        end
        nAugMatrix=nSpecies*(1+numel(info.SensitivityInputs));
        aAug=zeros(nAugMatrix,nAugMatrix);
        aAug(nSpecies+1:end,1:nSpecies)=vertcat(S_dKf_dki{:});
        info.Aaug=sparse(aAug);

        info.Baug=sparse([zeros(nSpecies,1);vertcat(S_dKz_dki{:})]);



        sensSpeciesInputs=find(strcmp('y',{info.SensitivityInputs.Type}));
        sensParamInputs=find(strcmp('p',{info.SensitivityInputs.Type}));
        sensResponseStruct=struct('tfY',{},'idxY',{},'tfP',{},'idxP',{});
        for i=numel(info.SensitivityInputs):-1:1
            sensResponseStruct(i)=mapToIndex(allStatesInfo);
            sensResponseStruct(i).idxY=sensResponseStruct(i).idxY+i*nSpecies;
        end
        sensResponseStruct=sensResponseStruct([sensSpeciesInputs,sensParamInputs]);
        tempnum=numel(vertcat(sensResponseStruct.idxY));

        info.ResponseStruct.idxY=cat(1,info.ResponseStruct.idxY,sensResponseStruct.idxY);
        info.ResponseStruct.tfY=cat(1,info.ResponseStruct.tfY,sensResponseStruct.tfY);
        info.ResponseStruct.tfP=cat(1,info.ResponseStruct.tfP,sensResponseStruct.tfP);
        info.ResponseStruct.idxP=cat(1,info.ResponseStruct.idxP,sensResponseStruct.idxP);




        if~isempty(info.UCM)

            info.UCM=[info.UCM;ones(tempnum,1)];
        else


        end
    else
        info.SensitivityInputs=localObjArray2SIDs([],[],[]);
        info.SensitivityOutputs=localObjArray2SIDs([],[],[]);
        info.SensitivityNormalization='';
        info.SensitivityAnalysis=false;
        info.Aaug=sparse(zeros(nSpecies,nSpecies));
        info.Baug=sparse(zeros(nSpecies,1));
        info.dKf_dki={};
        info.dKz_dki={};
    end
end

function Df_Dki=d_dki(Kf,ki)
    if strcmp(ki.Type,'p')
        linearIdx=Kf(:);
        oneIdx=linearIdx==ki.Idx;
        Kf(oneIdx)=1;

        negOneIdx=linearIdx==-ki.Idx;
        Kf(negOneIdx&~oneIdx)=-1;

        zeroIdx=linearIdx~=ki.Idx;
        Kf(zeroIdx&~oneIdx&~negOneIdx)=0;
        Df_Dki=Kf;
    else

        Df_Dki=zeros(size(Kf));
    end
end

function[cinfo,doseY,doseType,doseTk0,hasLag,doseLag,estY,obsY,estYType]=localCompileModelMap(cinfo,mmap,yMap,pMap)























    doseY=localObjArray2SIDs(mmap.Dosed,yMap,pMap);
    doseType=mmap.DosingType;





    doseTk0=localObjArray2SIDs([mmap.ZeroOrderDurationParameter{:}],yMap,pMap);






    if isempty(mmap.LagParameter)
        hasLag=false(size(mmap.Dosed));
    else
        hasLag=~cellfun(@isempty,mmap.LagParameter);
    end
    doseLag=localObjArray2SIDs([mmap.LagParameter{:}],yMap,pMap);


    estY=localObjArray2SIDs(mmap.Estimated,yMap,pMap);
    obsY=localObjArray2SIDs(mmap.Observed,yMap,pMap);

    estYType=get(mmap.Estimated,{'Type'});
end






function[logSolverAndOutputTimes,tOutput]=computeLogSolverAndOutputTimes(tStop,tOutput,v)

    logSolverAndOutputTimes=false(numel(tStop),1);
    for i=1:numel(v)
        if isempty(tStop{i})&&isempty(tOutput{v(i)})
            error('SimBiology_internal_LinearModel:computeLogSolverAndOutputTimes:BOTH_TSTOP_AND_TOUTPUT_EMPTY','Both tStop and tOutput cannot be empty');
        end

        if isempty(tStop{i})
            logSolverAndOutputTimes(i)=false;
            continue;
        elseif isempty(tOutput{v(i)})
            tOutput{v(i)}=tStop{i};
            logSolverAndOutputTimes(i)=true;

        else
            temp=tOutput{v(i)};
            if tStop{i}>max(temp)
                temp(end+1)=tStop{i};%#ok<AGROW>
            end
            tOutput{v(i)}=temp;
            logSolverAndOutputTimes(i)=true;
        end
    end
end


function[cinfo,Amat,Bmat]=localReactionCompile(cinfo,reactions,yMap,pMap,...
    reactionDimInfo,speciesDimInfo)






















    Nreactions=numel(reactions);
    Nspecies=yMap.Count;
    Amat=zeros(Nreactions,Nspecies);
    Bmat=zeros(Nreactions,1);

    for c=1:Nreactions
        r=reactions(c);
        assert(r.Active);
        if isempty(r.KineticLaw)||~strcmp(r.KineticLaw.KineticLawName,'MassAction')
            cinfo=localUpdateCinfo(cinfo,'fatalerr','NonMAReaction');
            continue;
        end

        if r.Reversible

            rcts=r.Reactants;
            pcts=r.Products;
            Nrcts=numel(rcts);
            Npcts=numel(pcts);

            if Nrcts>1||Npcts>1

                cinfo=localUpdateCinfo(cinfo,'fatalerr','NonLinearRevMAReaction');
                continue;
            end


            pfName=r.kineticlaw.parametervariablenames{1};
            prName=r.kineticlaw.parametervariablenames{2};
            pfObj=r.resolveobject(pfName);
            prObj=r.resolveobject(prName);
            if~all(pMap.isKey({pfObj.UUID,prObj.UUID}))




                cinfo=localUpdateCinfo(cinfo,'fatalerr','UnresolvedParamVarName');
                continue;
            end
            pfIdx=pMap(pfObj.UUID);
            prIdx=pMap(prObj.UUID);

            cinfo=localCheckRateDimensions(cinfo,r,...
            reactionDimInfo.isPerUnitLength(c),...
            reactionDimInfo.dimExplicitAndValid(c),...
            speciesDimInfo,[rcts;pcts]);
            if localIsFatalErr(cinfo)

                continue;
            end

            if Nrcts==0
                if Npcts==0


                    assert(false);
                else

                    assert(Npcts==1);
                    pctIdx=yMap(pcts.UUID);
                    Bmat(c)=pfIdx;
                    Amat(c,pctIdx)=-prIdx;
                end
            else
                assert(Nrcts==1);
                if Npcts==0

                    rctIdx=yMap(rcts.UUID);
                    Bmat(c)=-prIdx;
                    Amat(c,rctIdx)=pfIdx;
                else

                    rctIdx=yMap(rcts.UUID);
                    pctIdx=yMap(pcts.UUID);
                    Amat(c,rctIdx)=pfIdx;
                    Amat(c,pctIdx)=-prIdx;
                end
            end
        else


            rcts=r.Reactants;
            Nrcts=numel(rcts);
            if Nrcts>1
                cinfo=localUpdateCinfo(cinfo,'fatalerr','NonLinearMAReaction');
                continue;
            end

            cinfo=localCheckRateDimensions(cinfo,r,...
            reactionDimInfo.isPerUnitLength(c),...
            reactionDimInfo.dimExplicitAndValid(c),...
            speciesDimInfo,rcts);
            if localIsFatalErr(cinfo)

                continue;
            end

            if Nrcts==0

                pName=r.kineticlaw.parametervariablenames;
                pObj=r.resolveobject(pName{1});
                pidx=pMap(pObj.UUID);
                Bmat(c)=pidx;
            elseif Nrcts==1

                pName=r.kineticlaw.parametervariablenames;
                pObj=r.resolveobject(pName{1});
                if~yMap.isKey(rcts.UUID)||~pMap.isKey(pObj.UUID)
                    cinfo=localUpdateCinfo(cinfo,'fatalerr','ReactionCompileErr');
                    continue;
                end
                rctidx=yMap(rcts.UUID);
                pidx=pMap(pObj.UUID);
                Amat(c,rctidx)=pidx;
            else
                assert(false);
            end
        end
    end
end

function initAsgnCode=localInitAsgnCompile(initasgns,yMap,pMap)





    Ninitasgns=numel(initasgns);
    initAsgnCode=struct('lhsVarType','',...
    'lhsVarIdx',num2cell(zeros(Ninitasgns,1)),...
    'rhsFcn',[]);

    for c=1:Ninitasgns
        initAsgnObj=initasgns(c);
        assert(strcmp(initAsgnObj.RuleType,'initialAssignment'));



        [lhspvars,rhspvars,~,rhsexpr]=initAsgnObj.parserule;
        lhspvars=SimBiology.internal.removeReservedTokens(lhspvars(:));
        rhspvars=SimBiology.internal.removeReservedTokens(rhspvars(:));
        rhsexpr=strtrim(rhsexpr);

        if numel(lhspvars)>1
            error(message('SimBiology:Internal:InternalError'));
        end

        lhsObj=initAsgnObj.resolveobject(lhspvars{1});
        [tf,initAsgnCode(c).lhsVarType,initAsgnCode(c).lhsVarIdx]=localLookupObjInMaps(lhsObj,yMap,pMap);
        assert(tf);

        rhsCode=localExpr2Code(initAsgnObj,rhsexpr,rhspvars,yMap,pMap);

        initAsgnCode(c).rhsFcn=str2func(['@(time,y,p) ',rhsCode]);
    end
end

function[tfvec,cidx]=localSpeciesCvsACompile(spCvsAInfo,YObjs,pMap)











    NY=numel(YObjs);
    tfvec=false(NY,1);
    cidx=zeros(NY,1);

    for c=1:NY
        yobj=YObjs(c);
        if strcmp(yobj.Type,'species')
            idx=spCvsAInfo.speciesMap(yobj.UUID);
            tfvec(c)=spCvsAInfo.SpeciesInConcentration(idx);
            if tfvec(c)
                cmptUUID=yobj.ParentUUID;
                cmptIdx=pMap(cmptUUID);
                cidx(c)=cmptIdx;
            end
        end
    end
end

function s=localObjArray2SIDs(objarr,yMap,pMap)






    s=struct('Type',cell(0,0),'Idx',cell(0,0));

    N=numel(objarr);
    for c=N:-1:1
        obj=objarr(c);
        [tf,s(c).Type,s(c).Idx]=localLookupObjInMaps(obj,yMap,pMap);
        assert(tf);
    end

end

function s=localOdeSensArray2SIDs(states,params)




    s=struct('Type',cell(0,0),'Idx',cell(0,0));

    N=numel(states);
    for c=numel(params):-1:1
        s(c+N).Type='p';
        s(c+N).Idx=params(c);
    end
    for c=N:-1:1
        s(c).Type='y';
        s(c).Idx=states(c);
    end

end

function[tf,type,idx]=localLookupObjInMaps(obj,yMap,pMap)








    assert(numel(obj)==1);

    if yMap.isKey(obj.UUID)
        idx=yMap(obj.UUID);
        type='y';
        tf=true;
    elseif pMap.isKey(obj.UUID)
        idx=pMap(obj.UUID);
        type='p';
        tf=true;
    else
        tf=false;
        type='';
        idx=0;
    end

end

function cinfo=localCheckRateDimensions(cinfo,rObj,reactInC,reactExplicitValidDims,speciesDimInfo,sVec)


















    if reactInC


        assert(reactExplicitValidDims);

        if~localCheckSpeciesDims(sVec,speciesDimInfo,'concentration')


            cinfo=localUpdateCinfo(cinfo,'fatalerr','NonCanonicalMAReaction');
        else

        end
    else


        if reactExplicitValidDims
            if~localCheckSpeciesDims(sVec,speciesDimInfo,'amount')
                cinfo=localUpdateCinfo(cinfo,'fatalerr','NonCanonicalMAReaction');
            else

            end
        else














            if~localCheckSpeciesDims(sVec,speciesDimInfo,'amount')
                cinfo=localUpdateCinfo(cinfo,'okwithwarn',...
                message('SimBiology:PKCompile:PKAccelNonCanonicalMA',rObj.Name));
            end
        end
    end
end

function tf=localCheckSpeciesDims(s,speciesDimInfo,type)







    assert(isempty(s)||isa(s,'SimBiology.Species'));

    switch type
    case 'amount'
        tfWantC=false;
    case 'concentration'
        tfWantC=true;
    otherwise
        assert(false);
    end

    tf=true;
    for c=1:numel(s)
        obj=s(c);
        idx=speciesDimInfo.speciesMap(obj.UUID);
        objIsInC=speciesDimInfo.SpeciesInConcentration(idx);
        if xor(tfWantC,objIsInC)
            tf=false;
            return;
        end
    end

end

function cinfo=localUpdateCinfo(cinfo,type,info)





    switch type
    case 'okwithwarn'

        if~strcmp(cinfo.status,'fatalerr')
            cinfo.status='okwithwarn';
        end
        cinfo.warns{end+1,1}=info;
    case 'fatalerr'
        cinfo.status='fatalerr';
        cinfo.errs{end+1,1}=info;
    otherwise
        assert(false);
    end

end

function tf=localIsFatalErr(cInfo)
    switch cInfo.status
    case{'ok','okwithwarn'}
        tf=false;
    case 'fatalerr'
        tf=true;
    otherwise
        assert(false);
    end
end

function localThrowCompileWarningsIfNecessary(cinfo)
    switch cinfo.status
    case 'okwithwarn'
        for c=1:numel(cinfo.warns)
            warninfo=cinfo.warns{c};
            warning(warninfo);
        end
    otherwise

    end
end




function code=localExpr2Code(obj,expr,parsevars,yMap,pMap)
    nvars=numel(parsevars);
    replvars=cell(nvars,1);


    for count=1:nvars
        tmpobj=obj.resolveobject(parsevars{count});

        if yMap.isKey(tmpobj.UUID)
            tmpObjIdx=yMap(tmpobj.UUID);
            replvars{count}=sprintf('y(%d)',tmpObjIdx);
        else
            tmpObjIdx=pMap(tmpobj.UUID);
            replvars{count}=sprintf('p(%d)',tmpObjIdx);
        end
    end

    code=SimBiology.internal.Utils.Parser.traverseSubstitute(expr,parsevars,replvars);
end




function[iEstimated,iDosed,iObserved,iDoseTK0]=findIndices(pkc)
    iEstimated=mapToIndex(pkc.PEMap.estimated);
    iObserved=mapToIndex(pkc.PEMap.observed);

    doseY=pkc.DoseInfo.doseY;

    iDosed=mapToIndex(doseY);

    iDoseTK0=mapToIndex(pkc.DoseInfo.doseTk0);

end

function index=mapToIndex(map)





    tfY=strcmp('y',{map.Type}.');
    tfY=reshape(tfY,[],1);

    idxY=cat(1,zeros(0,1),map(tfY).Idx);
    tfP=strcmp('p',{map.Type}.');
    tfP=reshape(tfP,[],1);

    idxP=cat(1,zeros(0,1),map(tfP).Idx);
    assert(all(tfY|tfP),'Unknown index type.')
    index=struct('tfY',tfY,'idxY',idxY,'tfP',tfP,'idxP',idxP);
end

function keepCalling=callCallback(callback,status)

    if status=="end"
        callback();
    end
    keepCalling=true;
end
