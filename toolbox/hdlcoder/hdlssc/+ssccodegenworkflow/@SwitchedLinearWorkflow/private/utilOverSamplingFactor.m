function overSamplingLatencyHdlSubsystems=utilOverSamplingFactor(h,ssp,algorithmDataType,nfpConfigSettings)




    hdlSubsystems=numel(h);


    if strcmpi(algorithmDataType,'MixedDoubleSingle')
        dataType='double';
        dtcCompDelay=3;
    else
        dataType=algorithmDataType;
        dtcCompDelay=0;
    end




    for i=1:hdlSubsystems
        stateSpaceParameters(i)=ssp(i);
        stateSpaceParametersVarName{i}=strcat(utilGetVarName(stateSpaceParameters),'_',num2str(i));
        eval([stateSpaceParametersVarName{i},'= stateSpaceParameters(i);']);

        Bd1=ones(size(stateSpaceParameters(i).Bd),dataType);
        Bd=cast(stateSpaceParameters(i).Bd,'like',Bd1);

        X0d1=ones(size(stateSpaceParameters(i).X0),dataType);
        X=cast(stateSpaceParameters(i).X0,'like',X0d1);

        numOfSwitchingModes=stateSpaceParameters(i).NumberOfSwitchingModes;
        U=ones(size(Bd,2));
        U=cast(U,lower(dataType));
        if isempty(U)
            U=cast(1,lower(dataType));
        end
        if isempty(X)
            X=cast(1,lower(dataType));
        end

        computeModeFcn=stateSpaceParameters(i).ComputeSwitchingMode;
        latencyStrategy=nfpConfigSettings.LibrarySettings.LatencyStrategy;





        sysName=find_system(getfullname(h(i)),'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','hdlssclib/NFPSparseConstMultiply');



        ramLatency=cell2mat(cellfun(@(x)strcmpi(hdlget_param(x,'UseRAM'),'on'),sysName,'UniformOutput',false));
        sharingFactorLatency=cell2mat(cellfun(@(x)getSharingFactorLatency(x),sysName,'UniformOutput',false));

        dotProductLatency=[];
        sumInputPortCount=0;




        for k=1:size(sysName)
            constMatrix=hdlslResolve('constMatrix',get_param(sysName{k},'handle'));


            if(ischar(constMatrix))
                constMatrix=eval(constMatrix);
            end
            dotProductLatency(k)=getMatrixMultiplyLatency((constMatrix),dataType,latencyStrategy);
            sumBlksHandles=Simulink.findBlocksOfType(h(i),'Sum');
            for ii=1:numel(sumBlksHandles)
                sumPortHandles(ii)=get_param(sumBlksHandles(ii),'porthandles');
                sumInputPortCount(ii)=length(sumPortHandles(ii).Inport);
            end
        end
        dotprodLatencyOfSystem=max(dotProductLatency);
        if isempty(dotprodLatencyOfSystem)
            dotprodLatencyOfSystem=0;
        end
        addersLatency=0;



        if max(sumInputPortCount)>0
            addersLatency=getaddersLatency(max(sumInputPortCount),dataType,latencyStrategy);
        end

        ramLatencySys=numel(ramLatency(ramLatency==1));
        additionalLatency=0;
        sharingFacLatSys=0;
        if~isempty(sharingFactorLatency)
            sharingFacLatSys=max(sharingFactorLatency);
        end



        if sharingFacLatSys>1
            additionalLatency=4;
        end




        ramRateTransLatency=0;
        if ramLatencySys>1
            ramRateTransLatency=4;
        end
        if~isempty(computeModeFcn)&&numOfSwitchingModes>1

            MlBlkInfo=utilGetMatlabFunBlkInfo(computeModeFcn,U,X,nfpConfigSettings);%#ok<ASGLU>
        else
            MlBlkInfo.mlfbBlkLatency=0;
            MlBlkInfo.mlfbAdds=0;
            MlBlkInfo.mlfbMuls=0;
            MlBlkInfo.failed=0;
        end

        if~(MlBlkInfo.failed==1)


            overSamplingLatencyHdlSubsystem(i)=dotprodLatencyOfSystem+addersLatency+ramLatencySys+additionalLatency+MlBlkInfo.mlfbBlkLatency+ramRateTransLatency+sharingFacLatSys+dtcCompDelay;
        else


            overSamplingLatencyHdlSubsystem(i)=60;
        end

        if~(overSamplingLatencyHdlSubsystem(i)>0)
            overSamplingLatencyHdlSubsystem(i)=1;
        end

    end


    overSamplingLatencyHdlSubsystems=max(overSamplingLatencyHdlSubsystem);
end


function sharingFactorLatency=getSharingFactorLatency(sysName)
    sharingFactor=hdlget_param(sysName,'SharingFactor');
    if sharingFactor>1
        sharingFactorLatency=sharingFactor;
    else
        sharingFactorLatency=0;
    end

end

function dotprodLatencyFun=getMatrixMultiplyLatency(constMatrix,dataType,latencyStrategy)


    [~,activeRowPositions,~]=sschdloptimizations.getActiveElements(constMatrix,1);



    maxRowElements=0;
    for ii=1:numel(activeRowPositions)
        rowElements=activeRowPositions{ii};
        if(numel(rowElements)>maxRowElements)
            maxRowElements=numel(rowElements);
        end
    end


    maxAdderTreeStages=0;
    if(maxRowElements>0)
        maxAdderTreeStages=ceil(log2(maxRowElements));
    end


    [minval,maxval]=targetcodegen.targetCodeGenerationUtils.getOperatorLatencies('Mul',dataType,'NATIVEFLOATINGPOINT');
    if strcmpi(latencyStrategy,'MIN')
        mulLatency=minval;
    elseif strcmpi(latencyStrategy,'MAX')
        mulLatency=maxval;
    else
        mulLatency=0;
    end

    [minval,maxval]=targetcodegen.targetCodeGenerationUtils.getOperatorLatencies('ADDSUB',dataType,'NATIVEFLOATINGPOINT');
    if strcmpi(latencyStrategy,'MIN')
        addLatency=minval;
    elseif strcmpi(latencyStrategy,'MAX')
        addLatency=maxval;
    else
        addLatency=0;
    end



    dotprodLatencyFun=double(mulLatency+maxAdderTreeStages*addLatency);

end



function addersLatency=getaddersLatency(chk,dataType,latencyStrategy)

    addCompsCount=chk-1;

    [minval,maxval]=targetcodegen.targetCodeGenerationUtils.getOperatorLatencies('ADDSUB',dataType,'NATIVEFLOATINGPOINT');
    if strcmpi(latencyStrategy,'MIN')
        addLatency=minval;
    elseif strcmpi(latencyStrategy,'MAX')
        addLatency=maxval;
    else
        addLatency=0;
    end
    addersLatency=0;
    if addCompsCount>0
        addersLatency=addLatency*addCompsCount;
    end
end
