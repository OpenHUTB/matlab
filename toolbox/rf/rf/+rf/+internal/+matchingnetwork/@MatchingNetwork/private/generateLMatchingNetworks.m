




function[ckts,netOut,valuesOut]=generateLMatchingNetworks(sourceImpedance,loadImpedance,targetFrequency)

    reactances=[calculateMatchImpedancesShuntSeries(loadImpedance,sourceImpedance);calculateMatchImpedancesShuntSeries(sourceImpedance,loadImpedance)];

    [net,values]=makeLNet(reactances,targetFrequency);
    net(1:2,:)=[net(1:2,2),net(1:2,1)];
    values(1:2,:)=[values(1:2,2),values(1:2,1)];


    badRows=isnan(values(:,1))|isnan(values(:,2));
    net=net(~badRows,:);values=values(~badRows,:);


    badRows=imag(values(:,1))|imag(values(:,2));
    netOut=net(~badRows,:);valuesOut=values(~badRows,:);



    ckts=repmat(circuit(),[length(netOut(:,1)),1]);
    for j=1:length(netOut(:,1))
        ckts(j)=topologyToCircuit(netOut(j,:),valuesOut(j,:));
    end
end