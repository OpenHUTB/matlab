










function[Net,Values,errorflag]=parseCircuitObject(obj,c,verbose)




    if(nargin<3)
        verbose=true;
    end
    Net=[];
    Values=[];
    errorflag=0;
    validateattributes(c,{'circuit'},{'scalar'});

    SER_CAP=1;
    SER_INDCT=2;
    SHNT_CAP=3;
    SHNT_INDCT=4;
    SER_RES=5;
    SHNT_RES=6;



    if(c.NumPorts~=2)
        if(verbose)
            warning(message('rf:matchingnetwork:CircuitParser_2Ports'));
        end
        errorflag=1;
        return;
    end

    portnames=c.Ports;
    port1Node1=c.TerminalNodes(strcmp([portnames{1},'+'],c.Terminals));
    port1Node2=c.TerminalNodes(strcmp([portnames{1},'-'],c.Terminals));
    port2Node1=c.TerminalNodes(strcmp([portnames{2},'+'],c.Terminals));
    port2Node2=c.TerminalNodes(strcmp([portnames{2},'-'],c.Terminals));

    port1Nodes=[port1Node1;port1Node2];
    port2Nodes=[port2Node1;port2Node2];


    if(port1Nodes(1)==port1Nodes(2))
        if(verbose)
            warning(message('rf:matchingnetwork:CircuitParser_ShortPort',1));
        end
        errorflag=2;
        return;
    end
    if(port2Nodes(1)==port2Nodes(2))
        if(verbose)
            warning(message('rf:matchingnetwork:CircuitParser_ShortPort',2));
        end
        errorflag=3;
        return;
    end


    if(port1Nodes(2)~=port2Nodes(2))
        if(verbose)
            warning(message('rf:matchingnetwork:CircuitParser_NoGndNode'));
        end
        errorflag=4;
        return;
    end
    gndNode=port1Nodes(2);


    Elements=c.Elements;
    componentTypes=arrayfun(@class,Elements,'UniformOutput',false);
    componentTypesNumeric=zeros(1,length(componentTypes));
    componentTypesNumeric(strcmp(componentTypes,'capacitor'))=SER_CAP;
    componentTypesNumeric(strcmp(componentTypes,'inductor'))=SER_INDCT;
    componentTypesNumeric(strcmp(componentTypes,'resistor'))=SER_RES;
    if(any(~componentTypesNumeric))
        if(verbose)
            warning(message('rf:matchingnetwork:CircuitParser_UnsupportedComponent'));
        end
        errorflag=5;
        return;
    end

    Net=zeros(1,length(componentTypes));
    Values=Net;
    currentComponent=1;


    connectionList=arrayfun(@(e)reshape(e.ParentNodes,[2,1]),Elements,'UniformOutput',false);
    connectionList=cell2mat(connectionList);


    if(any(connectionList(1,:)==connectionList(2,:)))
        if(verbose)
            warning(message('rf:matchingnetwork:CircuitParser_ShortedComponent'));
        end
        errorflag=6;
        return;
    end





    done=false;
    currentNode=port1Nodes(1);
    while(~done)

        [connectedNodesRows,connectedNodesColumns]=find(connectionList==currentNode);

        if(~isempty(connectedNodesColumns))
            unorderedCols=connectionList(1,connectedNodesColumns)~=currentNode;
            connectionList(:,unorderedCols)=flip(connectionList(:,unorderedCols),1);
        end

        gndConnections=[];
        seriesConnections=[];


        if(~isempty(connectedNodesColumns))
            gndConnections=connectedNodesColumns(connectionList(2,connectedNodesColumns)==gndNode);
            if(~isempty(gndConnections))
                for(j=1:length(gndConnections))
                    if(componentTypesNumeric(gndConnections(j))==SER_CAP)
                        Net(currentComponent)=SHNT_CAP;
                        Values(currentComponent)=Elements(gndConnections(j)).Capacitance;
                    elseif(componentTypesNumeric(gndConnections(j))==SER_INDCT)
                        Net(currentComponent)=SHNT_INDCT;
                        Values(currentComponent)=Elements(gndConnections(j)).Inductance;
                    elseif(componentTypesNumeric(connectedNodesColumns(gndConnections(j)))==SER_RES)
                        Net(currentComponent)=SHNT_RES;
                        Values(currentComponent)=Elements(gndConnections(j)).Resistance;
                    end
                    currentComponent=currentComponent+1;
                end





            end
        end



        if(~isempty(connectedNodesColumns))
            seriesConnections=connectedNodesColumns(connectionList(2,connectedNodesColumns)~=gndNode);
            if(~isempty(seriesConnections))
                if(length(seriesConnections)>1)
                    if(verbose)
                        warning(message('rf:matchingnetwork:CircuitParser_TooManySeriesConnections'));
                    end
                    errorflag=7;
                    return;
                end


                Net(currentComponent)=componentTypesNumeric(seriesConnections);
                if(Net(currentComponent)==SER_CAP)
                    Values(currentComponent)=Elements(seriesConnections).Capacitance;
                elseif(Net(currentComponent)==SER_INDCT)
                    Values(currentComponent)=Elements(seriesConnections).Inductance;
                elseif(Net(currentComponent)==SER_RES)
                    Values(currentComponent)=Elements(seriesConnections).Resistance;
                end
                currentComponent=currentComponent+1;



                currentNode=connectionList(2,seriesConnections);
            end
        end






        if(isempty(gndConnections)&&isempty(seriesConnections)&&~isempty(connectionList))
            if(verbose)
                warning(message('rf:matchingnetwork:CircuitParser_BrokenChain'));
            end
            errorflag=8;
            return;
        end










        Elements([gndConnections;seriesConnections])=[];
        componentTypes([gndConnections;seriesConnections])=[];
        componentTypesNumeric([gndConnections;seriesConnections])=[];
        connectionList(:,[gndConnections;seriesConnections])=[];



        if(isempty(connectionList))
            if(currentNode==port2Nodes(1))
                done=true;
                return;
            else
                if(verbose)
                    warning(message('rf:matchingnetwork:CircuitParser_BrokenChain'));
                end
                errorflag=7;
                return;
            end
        end
    end

end
