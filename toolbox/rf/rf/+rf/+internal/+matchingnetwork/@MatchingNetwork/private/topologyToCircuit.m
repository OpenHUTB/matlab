
function circuitOut=topologyToCircuit(net,values)
    EMPTY=0;
    SER_CAP=1;
    SER_INDCT=2;
    SHNT_CAP=3;
    SHNT_INDCT=4;
    SER_RES=5;
    SHNT_RES=6;
    circuitOut=circuit();

    node_gnd=1;
    node_series=2;
    for j=1:length(net)
        switch(net(j))
        case SER_CAP
            circuitOut.add([node_series,node_series+1],capacitor(values(j)));
            node_series=node_series+1;
        case SER_INDCT
            circuitOut.add([node_series,node_series+1],inductor(values(j)));
            node_series=node_series+1;
        case SHNT_CAP
            circuitOut.add([node_series,node_gnd],capacitor(values(j)));
        case SHNT_INDCT
            circuitOut.add([node_series,node_gnd],inductor(values(j)));
        case SER_RES
            circuitOut.add([node_series,node_series+1],resistor(values(j)));
            node_series=node_series+1;
        case SHNT_RES
            circuitOut.add([node_series,node_gnd],resistor(values(j)));
        case EMPTY

        otherwise

            error(message('rf:matchingnetwork:UndefinedElement','topologyToCircuit'));
        end
    end
    circuitOut.setports([2,node_gnd],[node_series,node_gnd]);
end