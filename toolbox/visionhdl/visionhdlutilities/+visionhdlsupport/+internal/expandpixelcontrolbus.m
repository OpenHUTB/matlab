function[insig,outsig]=expandpixelcontrolbus(hN)

    pirinsignals=hN.PirInputSignals;
    insig=[];
    for ii=1:numel(pirinsignals)
        if pirinsignals(ii).Type.isRecordType

            insig=expandbusinput(hN,pirinsignals(ii),insig);
        else
            insig=addsigtolist(pirinsignals(ii),insig);
        end
    end

    piroutsignals=hN.PirOutputSignals;
    outsig=[];
    for ii=1:numel(piroutsignals)
        if piroutsignals(ii).Type.isRecordType

            outsig=formbusoutput(hN,piroutsignals(ii),outsig);
        else
            outsig=addsigtolist(piroutsignals(ii),outsig);
        end
    end

end


function siglist=addsigtolist(pirsig,siglist)

    siglist=[siglist,pirsig];
    return;

    if isempty(siglist)
        siglist=pirsig(1);
    else
        siglist(end+1)=pirsig(1);
    end

    for ii=2:numel(pirsig)
        siglist(end+1)=pirsig(ii);
    end
end


function insig=expandbusinput(hN,pirinsignal,insig)

    pcbus=privpixelcontrolbus;
    ctlType=pir_boolean_t();

    for ii=1:numel(pcbus.Elements)
        ctlbusin(ii)=hN.addSignal(ctlType,...
        [pcbus.Elements(ii).Name,'_in']);%#ok<AGROW>
        ctlbusin(ii).SimulinkRate=pirinsignal.SimulinkRate;%#ok<AGROW>
    end
    ct=pirinsignal.Type;
    indexArray=strjoin(ct.MemberNames,',');

    pirelab.getBusSelectorComp(hN,pirinsignal,ctlbusin,indexArray);

    insig=addsigtolist(ctlbusin,insig);

end


function outsig=formbusoutput(hN,piroutsignal,outsig)

    pcbus=privpixelcontrolbus;
    ctlType=pir_boolean_t();

    for ii=1:numel(pcbus.Elements)
        ctlbusout(ii)=hN.addSignal(ctlType,...
        [pcbus.Elements(ii).Name,'_out']);%#ok<AGROW>
        ctlbusout(ii).SimulinkRate=piroutsignal.SimulinkRate;%#ok<AGROW>
    end

    busTypeStr='Bus:privpixelcontrolbus';


    pirelab.getBusCreatorComp(hN,ctlbusout,piroutsignal,busTypeStr,'on');

    outsig=addsigtolist(ctlbusout,outsig);

end
