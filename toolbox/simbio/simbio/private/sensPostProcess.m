function x=sensPostProcess(x,odedata,unitConversion,sensitivityNormalization,userOrderInputUuids,numStatesToLog)






















    nStates=length(odedata.X0);
    nSensOutputs=length(odedata.sensOutputs);
    ninpfacs=length(odedata.sensStateInputs)+length(odedata.sensParamInputs);
    ntimepts=size(x,1);

    if size(x,2)~=numStatesToLog+nSensOutputs+nStates*ninpfacs
        error(message('SimBiology:Internal:InternalError'));
    end


    xSTL=x(:,1:numStatesToLog);
    xSensOutputs=x(:,(numStatesToLog+1):(numStatesToLog+nSensOutputs));
    R=reshape(x(:,(numStatesToLog+nSensOutputs+1):end),ntimepts,nStates,ninpfacs);



    R=R(:,odedata.sensOutputs,:);













    UCM=1./[odedata.XUCM(:);odedata.PUCM(:)];
    ucflag=unitConversion&&~isempty(UCM);


    if ucflag

        outUMs=UCM(odedata.sensOutputs);
        ifUMs=[UCM(odedata.sensStateInputs);
        UCM(nStates+odedata.sensParamInputs)];



        for j=1:nSensOutputs
            R(:,j,:)=R(:,j,:)*outUMs(j);
        end



        for j=1:ninpfacs
            R(:,:,j)=R(:,:,j)/ifUMs(j);
        end
    end
























    indicesOfSpeciesInConcentration=odedata.speciesIndexToConstantCompartment(:,1);
    [sensOutputInConc,sensOutputLoc]=ismember(odedata.sensOutputs,indicesOfSpeciesInConcentration);
    compartmentIndices=odedata.speciesIndexToConstantCompartment(sensOutputLoc(sensOutputInConc),2);
    compartmentVolumesEngineUnits=odedata.P(compartmentIndices);
    if ucflag
        compartmentVolumeUserUnits=compartmentVolumesEngineUnits.*UCM(compartmentIndices+nStates);
    else
        compartmentVolumeUserUnits=compartmentVolumesEngineUnits;
    end
    sensOutputAmount=xSensOutputs(:,sensOutputInConc);
    counterForSpeciesInConcentration=0;
    simOrderInputUuids=[odedata.XUuids(odedata.sensStateInputs);...
    odedata.PUuids(odedata.sensParamInputs)];
    for i=1:numel(sensOutputInConc)
        if sensOutputInConc(i)==0
            continue
        end
        counterForSpeciesInConcentration=counterForSpeciesInConcentration+1;
        thisCompartmentParameterIndex=compartmentIndices(counterForSpeciesInConcentration);
        thisCompartmentVolume=compartmentVolumeUserUnits(counterForSpeciesInConcentration);
        thisCompartmentUUID=odedata.PUuids(thisCompartmentParameterIndex);
        sliceIndex=find(strcmp(thisCompartmentUUID,simOrderInputUuids));
        if~isempty(sliceIndex)
            sensOutputConc=sensOutputAmount(:,counterForSpeciesInConcentration)./thisCompartmentVolume;
            R(:,i,sliceIndex)=R(:,i,sliceIndex)-sensOutputConc;
        end
    end
















    if~isempty(odedata.InitialCodeGenerator)




        P=odedata.PKCompileData.PBeforeInitAsgns;
        X0=odedata.PKCompileData.X0BeforeInitAsgns;
        Z=[X0;P];

        jac0=odedata.InitialJacobianFcn(0,Z);




        idx=[odedata.sensStateInputs;odedata.sensParamInputs+numel(odedata.X0)];



        idy=[odedata.UserSuppliedSensStateInputs;odedata.UserSuppliedSensParamInputs+numel(odedata.X0)];

        jac1=jac0(idx,idy);

        if ucflag

            ucmrows=UCM(idx);
            ucmcols=UCM(idy);
            jac=(jac1.*ucmrows(:))./ucmcols(:)';
        else
            jac=jac1;
        end

        nUserSuppliedInputFactors=numel(odedata.UserSuppliedSensStateInputs)+numel(odedata.UserSuppliedSensParamInputs);
        RCorrected=NaN(ntimepts,numel(odedata.sensOutputs),nUserSuppliedInputFactors);
        for i=1:size(R,1)
            RCorrected(i,:,:)=permute(R(i,:,:),[2,3,1])*jac;
        end



        R=RCorrected;


        ninpfacs=length(odedata.UserSuppliedSensStateInputs)+length(odedata.UserSuppliedSensParamInputs);


        simOrderInputUuids=[odedata.XUuids(odedata.UserSuppliedSensStateInputs);...
        odedata.PUuids(odedata.UserSuppliedSensParamInputs)];
    end






    if strcmp(sensitivityNormalization,'Half')||strcmp(sensitivityNormalization,'Full')
        tmpNormMat=repmat(xSensOutputs,[1,1,ninpfacs]);
        R=R./tmpNormMat;
    end


    if strcmp(sensitivityNormalization,'Full')



        uifVals=[odedata.PKCompileData.X0BeforeInitAsgns(odedata.UserSuppliedSensStateInputs);...
        odedata.PKCompileData.PBeforeInitAsgns(odedata.UserSuppliedSensParamInputs)];



        if ucflag
            uifUMs=[UCM(odedata.UserSuppliedSensStateInputs);
            UCM(nStates+odedata.UserSuppliedSensParamInputs)];

            uifVals=uifVals.*uifUMs;
        end

        for j=1:ninpfacs
            R(:,:,j)=uifVals(j)*R(:,:,j);
        end
    end





    [tf,loc]=ismember(userOrderInputUuids,simOrderInputUuids);
    assert(all(tf),message('SimBiology:Internal:InternalError'));
    R=R(:,:,loc);

    x=[xSTL,R(:,:)];
