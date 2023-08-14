function addPIRConnectivity(~,hCD,codeGenCtx)





    hCD.setCurrentAdapter('String');

    p=codeGenCtx.getPathCtx;

    buildCgirPathUtil(p,hCD);
    updateTimingUtil(p,hCD);

    if hdlconnectivity.genConnectivity
        networks=p.Networks;
        for nn=1:length(networks)
            network=networks(nn);
            components=network.Components;
            numComps=numel(network.Components);
            for cc=1:numComps
                cmp=components(cc);
                add_connectivity(cmp,p,hCD)
            end
        end
    end
end




function buildCgirPathUtil(pathCtx,hCD)
    oldPathUtil=hCD.getPathUtil();
    hCD.setPathUtil(hdlconnectivity.hdlpathutil('pir',pathCtx,'pathDelim',oldPathUtil.getPathDelim()));
end


function handleMuxComp(muxComp,hCD)
    signals=muxComp.getInputSignals('data');


    outv=hdlexpandvectorsignal(muxComp.PirOutputSignals(1));
    selectSignal=signals(1);
    if~isempty(selectSignal)&&isa(selectSignal,'hdlcoder.signal')
        for i=1:length(outv)
            hCD.addDriverReceiverPair(selectSignal,outv(i),'realonly',true);
        end
    end

    for i=2:length(signals)
        signal=signals(i);
        if~isempty(signal)&&isa(signal,'hdlcoder.signal')
            inv=hdlexpandvectorsignal(signal);
            for j=1:length(outv)
                hCD.addDriverReceiverPair(inv(j),outv(j),'realonly',true);
            end
        end
    end
end


function add_connectivity(cmp,p,hCD)
    switch class(cmp)
    case{'hdlcoder.ratechange_comp','hdlcoder.typechange_comp','hdlcoder.buffer_comp'}
        hCD.setCurrentAdapter('CGIR');
        hCD.addDriverReceiverPair(cmp.PirInputSignals(1),cmp.PirOutputSignals(1),'realonly',true);
    case{'hdlcoder.mux_comp'}
        hCD.setCurrentAdapter('CGIR');
        handleMuxComp(cmp,hCD);
    case{'hdlcoder.and_comp'}
        hCD.setCurrentAdapter('CGIR');
        signals=cmp.getInputSignals('data');
        for i=1:length(signals)
            signal=signals(i);
            if isa(signal,'hdlcoder.signal')
                hCD.addDriverReceiverPair(signal,cmp.PirOutputSignals(1),'realonly',true);
            end
        end
    case{'hdlcoder.or_comp'}
        hCD.setCurrentAdapter('CGIR');
        signals=cmp.getInputSignals('data');
        for i=1:length(signals)
            signal=signals(i);
            if isa(signal,'hdlcoder.signal')
                hCD.addDriverReceiverPair(signal,cmp.PirOutputSignals(1),'realonly',true);
            end
        end
    case{'hdlcoder.nor_comp'}
        hCD.setCurrentAdapter('CGIR');
        signals=cmp.getInputSignals('data');
        for i=1:length(signals)
            signal=signals(i);
            if isa(signal,'hdlcoder.signal')
                hCD.addDriverReceiverPair(signal,cmp.PirOutputSignals(1),'realonly',true);
            end
        end
    case{'hdlcoder.concat_comp'}
        hCD.setCurrentAdapter('CGIR');
        outv=hdlexpandvectorsignal(cmp.PirOutputSignals(1));
        for i=1:cmp.NumberOfPirInputPorts
            hCD.addDriverReceiverPair(cmp.PirInputSignals(i),outv(i),'realonly',true);
        end
    case{'hdlcoder.index_comp'}
        hCD.setCurrentAdapter('CGIR');
        inv=hdlexpandvectorsignal(cmp.PirInputSignals(1));
        hCD.addDriverReceiverPair(inv(cmp.getIndex+1),cmp.PirOutputSignals(1),'realonly',true);
    case{'hdlcoder.slice_comp'}
        hCD.setCurrentAdapter('CGIR');
        inv=hdlexpandvectorsignal(cmp.PirInputSignals(1));
        outv=hdlexpandvectorsignal(cmp.PirOutputSignals(1));
        for i=cmp.getLeftBound:cmp.getRightBound
            hCD.addDriverReceiverPair(inv(i+1),outv(i-cmp.getLeftBound+1),'realonly',true);
        end
    case{'hdlcoder.reg_comp'}
        hCD.setCurrentAdapter('CGIR');
        if~isempty(cmp.Clock)&&~isempty(cmp.ClockEnable)
            hCD.addRegister(cmp.DataIn,cmp.DataOut,cmp.Clock,cmp.ClockEnable,'realonly',true);
        end
    case{'hdlcoder.ctx_ref_comp'}
        addNetworkConn(p,cmp,hCD);
    case{'hdlcoder.ntwk_instance_comp'}
        addNetworkConn(p,cmp,hCD);
    case{'hdlcoder.const_comp'}
    case{'hdlcoder.black_box_comp'}
    case{'hdlcoder.ram_single_comp'}
    case{'hdlcoder.ram_simple_dual_comp'}
    case{'hdlcoder.ram_dual_comp'}
    case{'hdlcoder.ram_dual_rate_dual_comp'}
    case{'hdlcoder.timingcontroller_comp'}
    otherwise
        error(message('hdlcoder:engine:unhandledcomp',cmp.Owner.RefNum,cmp.RefNum,class(cmp)));
    end
end


function addNetworkConn(~,cmp,hCD)
    refnet=cmp.ReferenceNetwork;
    hCD.setCurrentAdapter('String');

    dpath=hCD.getNetworkHDLPath(cmp.Owner);
    rpath=hCD.getPathUtil().getComponentHDLPath(cmp);
    for dd=1:numel(dpath)
        for rr=1:numel(rpath)
            for ii=1:numel(refnet.PirInputSignals)
                cmpSignals=hdlexpandvectorsignal(cmp.PirInputSignals(ii));
                refNetSignals=hdlexpandvectorsignal(refnet.PirInputSignals(ii));
                for jj=1:length(cmpSignals)
                    hCD.addDriverReceiverPair(cmpSignals(jj).Name,refNetSignals(jj).Name,...
                    'driverPath',dpath{dd},'receiverPath',rpath{rr});
                end
            end
        end
    end


    dpath=hCD.getPathUtil().getComponentHDLPath(cmp);
    rpath=hCD.getNetworkHDLPath(cmp.Owner);
    for dd=1:numel(dpath)
        for rr=1:numel(rpath)
            for ii=1:numel(refnet.PirOutputSignals)
                refNetSignals=hdlexpandvectorsignal(refnet.PirOutputSignals(ii));
                cmpSignals=hdlexpandvectorsignal(cmp.PirOutputSignals(ii));
                for jj=1:length(cmpSignals)
                    hCD.addDriverReceiverPair(refNetSignals(jj).Name,cmpSignals(jj).Name,...
                    'driverPath',dpath{dd},'receiverPath',rpath{rr});
                end
            end
        end
    end
end


function updateTimingUtil(p,hCD)
    delim=hCD.getPathDelim();
    topNetwork=p.getTopNetwork;

    processClockEnablesNet(hCD,topNetwork.Name,topNetwork,[],delim)
end



function addClockEnable(hCD,newEnablePrefix,newEnable,existingEnablePrefix,existingEnable)
    hCD.addRelativeClockEnable(newEnable.Name,existingEnable.Name,0,1,...
    'newEnbPath',newEnablePrefix,'relEnbPath',existingEnablePrefix);
end


function processClockEnablesNet(hCD,networkPath,network,instance,delim)
    if isempty(instance)
        instancePath=networkPath;
    else
        instancePath=[networkPath,delim,instance.Name];
    end


    pairs=findGatedClockEnables(network);
    for i=1:length(pairs)
        pair=pairs(i);
        oldEnable=pair.enable;
        newEnable=pair.gated;

        addClockEnable(hCD,instancePath,newEnable,instancePath,oldEnable);


        propagateDownHierarchy(hCD,instancePath,delim,newEnable);
    end



    if hdlcoder.SimulinkData.isSFEMLNetwork(network)
        assert(~isempty(instance));
        addSFClockEnableInfo(hCD,networkPath,network,instancePath,instance);
    end

    components=network.Components;
    for i=1:length(components)
        component=components(i);
        if(isa(component,'hdlcoder.ntwk_instance_comp'))

            processClockEnablesInstance(hCD,component,instancePath,delim);
        end
    end
end



function propagateDownHierarchy(hCD,instancePath,delim,gatedEnable)
    receivers=gatedEnable.getReceivers();
    for j=1:length(receivers)
        port=receivers(j);
        if(isa(port.Component,'hdlcoder.ntwk_instance_comp'))
            instance=port.Component;
            refNet=instance.ReferenceNetwork;
            nestedInstancePath=[instancePath,delim,instance.Name];
            internalEnables=refNet.getInputSignals('clock_enable');

            portidx=port.getRelativePortNum()+1;


            if length(internalEnables)>=portidx
                internalEnable=internalEnables(port.getRelativePortNum()+1);
                addClockEnable(hCD,nestedInstancePath,internalEnable,instancePath,gatedEnable);
                propagateDownHierarchy(hCD,nestedInstancePath,delim,internalEnable);
            end
        end
    end
end


function processClockEnablesInstance(hCD,instance,networkPath,delim)
    network=instance.ReferenceNetwork;



    processClockEnablesNet(hCD,networkPath,network,instance,delim)

end



function addSFClockEnableInfo(hCD,networkPath,network,instancePath,instance)
    instanceEnables=instance.getInputSignals('clock_enable');
    networkEnables=network.getInputSignals('clock_enable');

    for enableCounter=1:length(instanceEnables)
        nwEnable=networkEnables(enableCounter);
        instEnable=instanceEnables(enableCounter);
        addClockEnable(hCD,instancePath,nwEnable,networkPath,instEnable);
    end
end

function pairs=findGatedEnable(signal)
    pairs=[];
    receivers=signal.getReceivers();
    for j=1:length(receivers)
        port=receivers(j);
        if isa(port.Component,'hdlcoder.and_comp')
            andComp=port.Component;
            newPair.enable=signal;
            newPair.gated=andComp.PirOutputSignal(1);
            pairs=[pairs,newPair];%#ok<AGROW>

            newPairs=findGatedEnable(newPair.gated);
            if~isempty(newPairs)
                pairs=[pairs,newPairs];%#ok<AGROW>
            end
        end
    end
end

function pairs=findGatedClockEnables(hN)
    enables=hN.getInputSignals('clock_enable');
    pairs=[];
    for i=1:length(enables)
        enable=enables(i);
        newPairs=findGatedEnable(enable);
        if~isempty(newPairs)
            pairs=[pairs,newPairs];%#ok<AGROW>
        end
    end
end


