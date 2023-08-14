function moveLargeDelaysOutsideDUT(p,Threshold)




    ntwrks=p.Networks;
    for n=1:numel(ntwrks)
        compsToReplace={};
        for ii=1:numel(ntwrks(n).Components)
            nw=ntwrks(n);
            comp=nw.Components(ii);
            if isa(comp,'hdlcoder.integerdelayenabledresettable_comp')
                if comp.getNumDelays>Threshold
                    compsToReplace{end+1}=comp;%#ok<AGROW>
                end
            end
        end
        if numel(compsToReplace)>=1
            delayValues=[];
            for c=1:numel(compsToReplace)
                comp=compsToReplace{c};
                if isBalancingValidSignal(comp)
                    replaceLargeDelayWithCounterBasedLogic(comp);
                else
                    replaceIntegerDelayCompsWithPorts(comp,nw);
                    delayValues(end+1)=comp.getNumDelays;%#ok<AGROW> 
                end
            end
            if~isempty(delayValues)



                fixNetworkInstances(nw,delayValues);
            end
        end
    end

end

function replaceIntegerDelayCompsWithPorts(comp,nw)






    assert(numel(comp.PirInputSignals)==2&&numel(comp.PirOutputSignals)==1);



    inSig=comp.PirInputSignals(1);
    inSig.disconnectReceiver(comp.PirInputPorts(1));
    outPort=nw.addOutputPort(inSig.Name);
    inSig.addReceiver(outPort);


    inSig=comp.PirInputSignals(2);
    inSig.disconnectReceiver(comp.PirInputPorts(2));
    outPort=nw.addOutputPort(inSig.Name);
    inSig.addReceiver(outPort);

    outSig=comp.PirOutputSignals(1);
    outSig.disconnectDriver(comp.PirOutputPorts(1));
    inPort=nw.addInputPort(outSig.Name);
    outSig.addDriver(inPort);

end

function fixNetworkInstances(nw,delayValues)









    instance=nw.instances;
    assert(numel(instance)==1);


    instanceInSignals=instance.PirInputSignals;
    instanceNumIn=numel(instanceInSignals);
    for ii=1:instanceNumIn
        instanceInSignals(ii).disconnectReceiver(instance.PirInputPorts(ii));
    end
    instanceOutSignals=instance.PirOutputSignals;
    instanceNumOut=numel(instanceOutSignals);
    for ii=1:instanceNumOut
        instanceOutSignals(ii).disconnectDriver(instance.PirOutputPorts(ii));
    end


    nwInports=nw.PirInputPorts;
    instanceOwner=instance.Owner;
    for ii=instanceNumIn+1:numel(nwInports)
        inPort=instanceOwner.addInputPort(nwInports(ii).Name);
        inSignal=instanceOwner.addSignal(nw.PirInputSignals(ii).Type,...
        nw.PirInputSignals(ii).Name);
        inSignal.addDriver(inPort);
        instanceInSignals(end+1)=inSignal;%#ok<AGROW>
        inSignal.SimulinkRate=nw.PirInputSignals(ii).SimulinkRate;
    end
    nwOutports=nw.PirOutputPorts;
    for ii=instanceNumOut+1:numel(nwOutports)
        outPort=instanceOwner.addOutputPort(nwOutports(ii).Name);
        outSignal=instanceOwner.addSignal(nw.PirOutputSignals(ii).Type,...
        nw.PirOutputSignals(ii).Name);
        outSignal.addReceiver(outPort);
        instanceOutSignals(end+1)=outSignal;%#ok<AGROW>
        outSignal.SimulinkRate=nw.PirOutputSignals(ii).SimulinkRate;
    end

    pirelab.instantiateNetwork(instanceOwner,nw,...
    instanceInSignals,...
    instanceOutSignals,instance.Name);

    if instanceOwner.isModelgenRootNetwork

        delayIdx=1;
        for ii=numel(delayValues):-1:1
            tag=instanceOwner.PirInputPorts(end-ii+1).getExternalDelayTag;
            tag.setDelay(delayValues(delayIdx));

            newPort=instanceOwner.PirOutputPorts(end-2*ii+1);
            tag=newPort.getExternalDelayTag;
            tag.setDelay(delayValues(delayIdx));
            delayIdx=delayIdx+1;
        end
    else

        fixNetworkInstances(instanceOwner,delayValues);
    end


end

function y=isBalancingValidSignal(comp)
    in1=comp.PirInputSignals(1);
    in2=comp.PirInputSignals(2);


    y=strcmp(in1.RefNum,in2.RefNum);
end

function replaceLargeDelayWithCounterBasedLogic(comp)


    nw=comp.Owner;
    validInSignal=comp.PirInputSignals(1);
    andInput=comp.PirOutputSignals(1);
    nDelays=comp.getNumDelays;


    comp.PirInputSignals(1).disconnectReceiver(comp.PirInputPorts(1));
    comp.PirInputSignals(2).disconnectReceiver(comp.PirInputPorts(2));
    comp.PirOutputSignals(1).disconnectDriver(comp.PirOutputPorts(1));

    ctrIn=nw.addSignal(pir_boolean_t,'ctrIn');
    ctrIn.SimulinkRate=validInSignal.SimulinkRate;
    validControlInv=nw.addSignal(pir_boolean_t,'validControlInv');
    validControlInv.SimulinkRate=validInSignal.SimulinkRate;
    ctrOut=nw.addSignal(pir_ufixpt_t(ceil(log2(nDelays)+1),0),'ctrOut');
    ctrOut.SimulinkRate=validInSignal.SimulinkRate;

    pirelab.getLogicComp(nw,[validInSignal,validControlInv],ctrIn,'and','andBlock');
    pirelab.getCounterComp(...
    nw,...
    ctrIn,...
    ctrOut,...
    'Modulo',...
    0,...
    1,...
    nDelays,...
    false,...
    false,...
    true,...
    false,...
    'Count_Valid_Signal',...
    0);
    pirelab.getCompareToValueComp(nw,ctrOut,validControlInv,'<',nDelays,'Max Count Value');
    pirelab.getLogicComp(nw,validControlInv,andInput,'not','notBlock');


end




