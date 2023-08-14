function[affectedPorts,affectedSignals]=findAffectedPortsOnComponent(port,busElementsToMatch)
















































    affectedPorts=[];
    affectedSignals=[];

    if nargin==1
        busElementsToMatch=[];
    end

    compPort=systemcomposer.utils.getArchitecturePeer(port);
    comp=compPort.getComponent();
    arch=comp.getArchitecture();
    rootArch=arch.getTopLevelArchitecture();
    if~rootArch.hasTrait(systemcomposer.architecture.model.traits.TimingTrait.StaticMetaClass)
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

        if stimulusPort.isArchitecturePort
            matchStimulus=compPort.getArchitecturePort()==stimulusPort;
        else
            matchStimulus=compPort==stimulusPort;
        end

        if matchStimulus
            if filterElements(stimulusInterfaceElements,busElementsToMatch)
                [slPort,sig]=getAffectedPortAndSignals(responsePort,responseInterfaceElements);

                affectedPorts=[affectedPorts,slPort];
                affectedSignals=[affectedSignals,{sig}];
            end
            continue
        end

        if responsePort.isArchitecturePort
            matchResponse=compPort.getArchitecturePort()==responsePort;
        else
            matchResponse=compPort==responsePort;
        end

        if matchResponse
            if filterElements(responseInterfaceElements,busElementsToMatch)
                [slPort,sig]=getAffectedPortAndSignals(stimulusPort,stimulusInterfaceElements);

                affectedPorts=[affectedPorts,slPort];
                affectedSignals=[affectedSignals,{sig}];
            end
            continue
        end
    end





    function[slPort,sig]=getAffectedPortAndSignals(port,nestedInterfaceElementLists)
        slPort=systemcomposer.utils.getSimulinkPeer(port);
        slPort=getRealPort(slPort);
        piface=port.getPortInterface();

        if isempty(piface)||isempty(nestedInterfaceElementLists)
            sig=get(slPort,'SignalHierarchy');
        else
            sig=struct('SignalName','',...
            'BusObject',piface.getName,...
            'Children',[]);

            elSig=[];
            for nestedElementList=nestedInterfaceElementLists
                delimitedString=getDelimitedStringForNestedInterfaceElementList(nestedElementList);
                elSig=[elSig,struct('SignalName',delimitedString,...
                'BusObject',[],...
                'Children',[])];
            end
            sig.Children=elSig;
        end




        function tf=filterElements(nestedInterfaceElementLists,busElementsToMatch)
            tf=false;
            if~isempty(busElementsToMatch)&&~isempty(nestedInterfaceElementLists)
                for nestedElementList=nestedInterfaceElementLists
                    delimitedString=getDelimitedStringForNestedInterfaceElementList(nestedElementList);

                    for i=1:length(busElementsToMatch)
                        if iscell(busElementsToMatch)
                            matchString=busElementsToMatch{i};
                        else
                            matchString=busElementsToMatch;
                        end
                        res=regexp(delimitedString,matchString,'match');
                        if~isempty(res)
                            tf=true;
                            return
                        end
                    end
                end
            else
                tf=true;
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



                function name=getDelimitedStringForNestedInterfaceElementList(nestedElementList)
                    name='';
                    for el=nestedElementList.getInterfaceElements
                        if isempty(name)
                            name=el.getName;
                        else
                            name=[name,'.',el.getName];
                        end
                    end


