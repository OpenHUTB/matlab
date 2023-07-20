function hNewC=preElab(this,hN,hC)








    hNewC=elabBasic(this,hN,hC);





    if hNewC.elaborationHelper
        stateInfo=getStateInfo(this,hNewC);
        hNewC.setHasState(stateInfo.HasState);
        hNewC.setHasFeedback(stateInfo.HasFeedback);
        hNewC.setMaxOversampling(getMaxOversampling(this,hNewC));
        hNewC.setAllowDistributedPipelining(allowDistributedPipelining(this,hNewC));
    end






    system_name=get_param(hNewC.SimulinkHandle,'System');
    moveCompToNetwork(this,hNewC,system_name);

end



function hNIC=moveCompToNetwork(~,hC,system_name)

    slbh=hC.SimulinkHandle;
    blkName=get_param(slbh,'Name');
    blkPath=getfullname(slbh);

    hCInSignals=hC.PirInputSignals;
    hCOutSignals=hC.PirOutputSignals;

    inPortNames=get(hC.PirInputPorts,'Name');
    if~iscell(inPortNames)
        inPortNames={inPortNames};
    end
    outPortNames=get(hC.PirOutputPorts,'Name');
    if~iscell(outPortNames)
        outPortNames={outPortNames};
    end
    nins=numel(hCInSignals);
    nouts=numel(hCOutSignals);

    inPortNames=inPortNames(1:nins);
    outPortNames=outPortNames(1:nouts);



    maskStr=get_param(slbh,'MaskDisplay');
    for ii=1:numel(inPortNames)
        pat=sprintf('port_label\\(''input'',%u,''(.*?)''\\)',ii);
        label=regexp(maskStr,pat,'tokens');
        if~isempty(label)&&~isempty(label{1})
            inPortNames{ii}=label{1}{1};
        end
    end
    for ii=1:numel(outPortNames)
        pat=sprintf('port_label\\(''output'',%u,''(.*?)''\\)',ii);
        label=regexp(maskStr,pat,'tokens');
        if~isempty(label)&&~isempty(label{1})
            outPortNames{ii}=label{1}{1};
        end
    end

    for ii=1:nouts
        hCOutSignals(ii).Name=outPortNames{ii};
    end


    if slbh>0
        maskObj=get_param(slbh,'MaskObject');
        if~isempty(maskObj)
            if isempty(maskObj.BaseMask)
                maskDispStr=get_param(slbh,'MaskDisplay');
            else
                maskDispStr=maskObj.BaseMask.Display;
            end


            expr='Latency\s*=\s*(\d+)';
            latValCell=regexp(maskDispStr,expr,'tokens');
            if~isempty(latValCell)&&~isempty(latValCell{1})
                latVal=str2double(latValCell{1}{1});
                hC.setLatencyValue(latVal);
            end
        end
    end


    hN=hC.Owner;
    hNewNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'InportNames',inPortNames,...
    'OutportNames',outPortNames,...
    'RefComponent',hC);
    hNewNet.Name=blkPath;
    hNewNet.FullPath=blkPath;
    hNewNet.SimulinkHandle=slbh;

    hNInSignals=hNewNet.PirInputSignals;
    hNOutSignals=hNewNet.PirOutputSignals;

    hNewNet.acquireComp(hC);

    hBlackBox=[];
    if nouts>0
        drivers=hCOutSignals(1).getDrivers();
        for ii=1:length(drivers)
            if strcmp(drivers(ii).Owner.ClassName,'black_box_comp')
                hBlackBox=drivers(ii).Owner;
                break;
            end
        end
    end
    if~isempty(hBlackBox)
        hNewNet.acquireComp(hBlackBox);
    end

    for i=1:nins
        hCSignal=hCInSignals(i);
        hNSignal=hNInSignals(i);

        hCSignal.disconnectReceiver(hC,i-1);
        hNSignal.addReceiver(hC,i-1);
        hNSignal.Name=inPortNames{i};

        if~isempty(hBlackBox)
            hCSignal.disconnectReceiver(hBlackBox,i-1);
            hNSignal.addReceiver(hBlackBox,i-1);
        end
    end

    for i=1:nouts
        hCSignal=hCOutSignals(i);
        hNSignal=hNOutSignals(i);
        hNSignal.Name=outPortNames{i};

        hNSignal.SimulinkRate=hCSignal.SimulinkRate;
        hNSignal.SimulinkHandle=hCSignal.SimulinkHandle;
        hNSignal.acquireDrivers(hCSignal);
    end

    hNIC=pirelab.instantiateNetwork(hN,hNewNet,hCInSignals,hCOutSignals,hC.Name);
    hNIC.Name=strrep(char(blkName),'/','//');
    hNIC.SimulinkHandle=slbh;
    hNIC.copyComment(hC);

    hNewNet.flatten(false);
    hNIC.flatten(false);
    hNewNet.setFlattenHierarchy('off');


    hNewNet.renderCodegenPir(true);


    hNewNet.setConstrainedOutputPipeline(hC.getConstrainedOutputPipeline());
    hC.setConstrainedOutputPipeline(0);

end
