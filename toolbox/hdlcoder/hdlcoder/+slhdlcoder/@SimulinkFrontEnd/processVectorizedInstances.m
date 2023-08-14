function processVectorizedInstances(this)



    p=this.hPir;
    networks=p.Networks;
    numNetworks=numel(networks);

    for ii=1:numNetworks
        hN=networks(ii);
        components=hN.Components;
        for jj=1:numel(components)
            hC=components(jj);
            slbh=hC.SimulinkHandle;
            if slbh~=-1&&isprop(slbh,'BlockType')&&...
                isprop(slbh,'MaskType')&&...
                ~strcmpi(get_param(slbh,'MaskType'),'Stateflow')
                processMaskForVectorizedInstance(this,hC);
            end
        end
    end

end

function processMaskForVectorizedInstance(this,hC)
    slbh=hC.Simulinkhandle;
    if~isprop(slbh,'Mask')
        return;
    end

    if~strcmpi(get_param(slbh,'Mask'),'on')
        return;
    end

    maskNames=get_param(slbh,'MaskNames');
    maskValues=get_param(slbh,'MaskValues');
    inputPortDim=1;
    outputPortDim=1;
    for ii=1:length(maskNames)
        maskName=maskNames{ii};
        dim=str2num(maskValues{ii});%#ok<ST2NM>
        if strcmp(maskName,'MW_InputPortDimension')
            inputPortDim=dim;
        elseif strcmp(maskName,'MW_OutputPortDimension')
            outputPortDim=dim;
        end
    end

    if inputPortDim>1&&outputPortDim>1
        assert(inputPortDim==outputPortDim);
        processMIMOVectorizedInstance(this,hC,inputPortDim);
    elseif inputPortDim==1&&outputPortDim>1
        processSIMOVectorizedInstance(this,hC,outputPortDim);
    elseif outputPortDim==1&&inputPortDim>1
        processMISOVectorizedInstance(this,hC,inputPortDim);
    end
end

function processSIMOVectorizedInstance(this,hC,dims)
    slbh=hC.SimulinkHandle;
    hCInSignals=hC.PirInputSignals;
    hCInputPorts=hC.PirInputPorts;
    hCOutSignals=hC.PirOutputSignals;
    nouts=hC.NumberOfPirOutputPorts;
    nins=hC.NumberOfPirInputPorts;
    hN=hC.Owner;

    hVectOutSignals=hdlhandles(dims,nouts);
    for jj=1:nouts
        hVectOutSignals(:,jj)=hdlexpandvectorsignal(hCOutSignals(jj));
    end

    hNRef=hC.ReferenceNetwork;

    hInportNames=cell(1,nins);
    hInportTypes=hdlhandles(1,nins);
    hInportRates=zeros(1,nins);
    hInportKinds=cell(1,nins);
    hOutportNames=cell(1,nouts);
    hOutportTypes=hdlhandles(1,nouts);

    for ii=1:nins
        hInportNames{ii}=hCInSignals(ii).Name;
        hInportTypes(ii)=hCInSignals(ii).Type;
        hInportRates(ii)=hCInSignals(ii).SimulinkRate;
        hInportKinds{ii}=hCInputPorts(ii).Kind;
    end

    for ii=1:nouts
        hOutportNames{ii}=hCOutSignals(ii).Name;
        hOutportTypes(ii)=hVectOutSignals(ii,1).Type;
        pirelab.getMuxComp(hN,hVectOutSignals(:,ii),hCOutSignals(ii));
    end

    hNew=pirelab.createNewNetwork('Network',hN,...
    'Name',hNRef.Name,'InportNames',hInportNames,...
    'InportTypes',hInportTypes,'InportRates',hInportRates,...
    'InportKinds',hInportKinds,'OutportNames',hOutportNames,...
    'OutportTypes',hOutportTypes);
    hNew.SimulinkHandle=hNRef.SimulinkHandle;
    hOuts=hNew.PirOutputSignals;
    for jj=1:nouts
        hOuts(jj).SimulinkRate=hCOutSignals(jj).SimulinkRate;
    end

    for ii=1:dims
        hOutSignals=hdlhandles(1,nouts);
        for jj=1:nouts
            hOutSignals(jj)=hVectOutSignals(ii);

        end
        compName=[hC.Name,'_',num2str(ii)];
        hNIC=pirelab.instantiateNetwork(hN,hNew,hCInSignals,hOutSignals,compName);
        hNIC.Name=this.validateAndGetName(compName);
        hNIC.SimulinkHandle=slbh;
        hNIC.setConstrainedOutputPipeline(hC.getConstrainedOutputPipeline());
        hC.setConstrainedOutputPipeline(0);
    end
    hN.removeComponent(hC);
end

function processMIMOVectorizedInstance(this,hC,dims)
    slbh=hC.SimulinkHandle;
    hCInSignals=hC.PirInputSignals;
    hCInputPorts=hC.PirInputPorts;
    hCOutSignals=hC.PirOutputSignals;
    nouts=hC.NumberOfPirOutputPorts;
    nins=hC.NumberOfPirInputPorts;
    hN=hC.Owner;
    hNRef=hC.ReferenceNetwork;

    hVectInSignals=hdlhandles(dims,nouts);
    for jj=1:nouts
        hVectInSignals(:,jj)=hdlexpandvectorsignal(hCInSignals(jj));
    end

    hVectOutSignals=hdlhandles(dims,nouts);
    for jj=1:nouts
        hVectOutSignals(:,jj)=hdlexpandvectorsignal(hCOutSignals(jj));
    end


    hInportNames=cell(1,nins);
    hInportTypes=hdlhandles(1,nins);
    hInportRates=zeros(1,nins);
    hInportKinds=cell(1,nins);
    hOutportNames=cell(1,nouts);
    hOutportTypes=hdlhandles(1,nouts);

    for ii=1:nins
        hInportNames{ii}=hCInSignals(ii).Name;
        hInportTypes(ii)=hVectInSignals(ii,1).Type;
        hInportRates(ii)=hCInSignals(ii).SimulinkRate;
        hInportKinds{ii}=hCInputPorts(ii).Kind;
        pirelab.getDemuxComp(hN,hCInSignals(ii),hVectInSignals(:,ii));
    end

    for ii=1:nouts
        hOutportNames{ii}=hCOutSignals(ii).Name;
        hOutportTypes(ii)=hVectOutSignals(ii,1).Type;
        pirelab.getMuxComp(hN,hVectOutSignals(:,ii),hCOutSignals(ii));
    end

    hNew=pirelab.createNewNetwork('Network',hN,...
    'Name',hNRef.Name,'InportNames',hInportNames,...
    'InportTypes',hInportTypes,'InportRates',hInportRates,...
    'InportKinds',hInportKinds,'OutportNames',hOutportNames,...
    'OutportTypes',hOutportTypes);
    hNew.SimulinkHandle=hNRef.SimulinkHandle;
    hOuts=hNew.PirOutputSignals;
    for jj=1:nouts
        hOuts(jj).SimulinkRate=hCOutSignals(jj).SimulinkRate;
    end

    for ii=1:dims
        hOutSignals=hdlhandles(1,nouts);
        for jj=1:nouts
            hOutSignals(jj)=hVectOutSignals(ii);
        end
        hInSignals=hdlhandles(1,nouts);
        for jj=1:nouts
            hInSignals(jj)=hVectInSignals(ii);
        end
        compName=[hC.Name,'_',num2str(ii)];
        hNIC=pirelab.instantiateNetwork(hN,hNew,hInSignals,hOutSignals,compName);
        hNIC.Name=this.validateAndGetName(compName);
        hNIC.SimulinkHandle=slbh;
        hNIC.setConstrainedOutputPipeline(hC.getConstrainedOutputPipeline());
        hC.setConstrainedOutputPipeline(0);
    end
    hN.removeComponent(hC);
end

function processMISOVectorizedInstance(this,hC,dims)
    slbh=hC.SimulinkHandle;
    hCInSignals=hC.PirInputSignals;
    hCInputPorts=hC.PirInputPorts;
    hCOutSignals=hC.PirOutputSignals;
    nouts=hC.NumberOfPirOutputPorts;
    nins=hC.NumberOfPirInputPorts;
    hN=hC.Owner;
    hNRef=hC.ReferenceNetwork;

    hInportNames=cell(1,nins);
    hInportTypes=hdlhandles(1,nins);
    hInportRates=zeros(1,nins);
    hInportKinds=cell(1,nins);
    hOutportNames=cell(1,nouts);
    hOutportTypes=hdlhandles(1,nouts);

    hVectInSignals=hdlhandles(dims,nouts);
    for jj=1:nouts
        hVectInSignals(:,jj)=hdlexpandvectorsignal(hCInSignals(jj));
        pirelab.getDemuxComp(hN,hCInSignals(jj),hVectInSignals(:,jj));
    end

    for ii=1:nins
        hInportNames{ii}=hCInSignals(ii).Name;
        hInportTypes(ii)=hVectInSignals(ii,1).Type;
        hInportRates(ii)=hCInSignals(ii).SimulinkRate;
        hInportKinds{ii}=hCInputPorts(ii).Kind;
    end

    for ii=1:nouts
        hOutportNames{ii}=hCOutSignals(ii).Name;
        hOutportTypes(ii)=hCOutSignals(ii,1).Type;
    end

    hNew=pirelab.createNewNetwork('Network',hN,...
    'Name',hNRef.Name,'InportNames',hInportNames,...
    'InportTypes',hInportTypes,'InportRates',hInportRates,...
    'InportKinds',hInportKinds,'OutportNames',hOutportNames,...
    'OutportTypes',hOutportTypes);
    hNew.SimulinkHandle=hNRef.SimulinkHandle;
    hOuts=hNew.PirOutputSignals;
    for jj=1:nouts
        hOuts(jj).SimulinkRate=hCOutSignals(jj).SimulinkRate;
    end

    for ii=1:dims
        hInSignals=hdlhandles(1,nouts);
        for jj=1:nouts
            hInSignals(jj)=hVectInSignals(ii);
        end
        compName=[hC.Name,'_',num2str(ii)];
        hNIC=pirelab.instantiateNetwork(hN,hNew,hInSignals,hCOutSignals,compName);
        hNIC.Name=this.validateAndGetName(compName);
        hNIC.SimulinkHandle=slbh;
        hNIC.setConstrainedOutputPipeline(hC.getConstrainedOutputPipeline());
        hC.setConstrainedOutputPipeline(0);
    end
    hN.removeComponent(hC);
end
