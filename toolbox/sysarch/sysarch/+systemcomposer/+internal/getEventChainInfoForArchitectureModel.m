function[stimulusList,responseList]=getEventChainInfoForArchitectureModel(model)






    stimulusList=[];
    responseList=[];


    if~slfeature('ZCEventChain')
        return;
    end

    modelH=get_param(model,'Handle');
    app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(modelH);


    if isempty(app)
        return;
    end


    rootArch=app.getTopLevelCompositionArchitecture;
    if~rootArch.isSoftwareArchitecture()||...
        ~rootArch.hasTrait(systemcomposer.architecture.model.traits.TimingTrait.StaticMetaClass)
        return
    end


    sw=rootArch.getTrait(systemcomposer.architecture.model.traits.TimingTrait.StaticMetaClass);
    chains=sw.eventChains;
    chains=chains.toArray;



    for chain=chains
        stimulus=chain.stimulus;
        stimulusPort=stimulus.port;
        stimulusInterfaceElements=stimulus.nestedInterfaceElementLists.toArray;

        response=chain.response;
        responsePort=response.port;
        responseInterfaceElements=response.nestedInterfaceElementLists.toArray;




        [stimulusPort,stimulusSignals]=parsePortAndSignal(stimulusPort,...
        stimulusInterfaceElements);

        s.port=stimulusPort;
        s.signals=stimulusSignals;
        stimulusList=[stimulusList,s];%#ok




        [responsePort,responseSignals]=parsePortAndSignal(responsePort,...
        responseInterfaceElements);
        r.port=responsePort;
        r.signals=responseSignals;
        responseList=[responseList,r];%#ok
    end
end





function[slPort,signalNames]=parsePortAndSignal(port,nestedInterfaceElementLists)
    slPort=systemcomposer.utils.getSimulinkPeer(port);
    slPort=getRealPort(slPort);
    piface=port.getPortInterface();
    signalNames={};

    if isempty(piface)||isempty(nestedInterfaceElementLists)
        return;
    else
        for nestedElementList=nestedInterfaceElementLists
            signalNames{end+1}=getDelimitedStringForNestedInterfaceElementList(nestedElementList);%#ok
        end
    end
end





function port=getRealPort(port)
    if strcmpi(get(port,'Type'),'block')
        pidx=str2double(get(port,'Port'));
        blk=get_param(get(port,'Parent'),'Handle');
        if~strcmp(get(blk,'Type'),'block_diagram')

            ph=get_param(blk,'PortHandles');
            if strcmpi(get(port,'BlockType'),'inport')
                port=ph.Inport(pidx);
            else
                port=ph.Outport(pidx);
            end
        else

            ph=get_param(port,'PortHandles');
            if strcmpi(get(port,'BlockType'),'outport')

                port=ph.Inport;
            else

                port=ph.Outport;
            end
        end
    end
end



function name=getDelimitedStringForNestedInterfaceElementList(nestedElementList)
    name='';
    for el=nestedElementList.getInterfaceElements
        if isempty(name)
            name=el.getName;
        else
            name=[name,'.',el.getName];%#ok
        end
    end
end


