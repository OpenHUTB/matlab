
function[ckts,net,values]=generatePiTMatchingNetworks(sourceImpedance,loadImpedance,targetFrequency,targetQ,type)




    if(~isstring(type)&&~ischar(type))
        type='both';
    elseif(~strcmp(type,'Pi')&&~strcmp(type,'Tee'))
        type='both';
    end



    allExtImpedancesPi=calculateVirtualResistancesPi(sourceImpedance,loadImpedance,targetQ);
    allExtImpedancesT=calculateVirtualResistancesT(sourceImpedance,loadImpedance,targetQ);


    [netsPi,valuesPi]=makeUnmergedLNetSeries(allExtImpedancesPi,targetFrequency);
    [netsT,valuesT]=makeUnmergedLNetSeries(allExtImpedancesT,targetFrequency);
    allNets=[netsPi;netsT];
    allValues=[valuesPi;valuesT];


    [netsReduced,valuesReduced]=simplifyNets(allNets,allValues,targetFrequency,1);


    if(length(netsReduced(1,:))>3)
        goodRows=netsReduced(:,4)==0;
        netsReduced=netsReduced(goodRows,1:3);
        valuesReduced=valuesReduced(goodRows,1:3);
    end

    if strcmp(type,'Tee')
        condition1=(netsReduced(:,1)==1)|(netsReduced(:,1)==2);
        condition2=(netsReduced(:,2)==3)|(netsReduced(:,2)==4);
        condition3=(netsReduced(:,3)==1)|(netsReduced(:,3)==2);
        condition=condition1&condition2&condition3;
        if any(condition)
            netsReduced=netsReduced(condition,1:3);
            valuesReduced=valuesReduced(condition,1:3);
        else
            error(message('rf:matchingnetwork:NoValidDesign','Tee'))
        end
    end

    if strcmp(type,'Pi')
        condition1=(netsReduced(:,1)==3)|(netsReduced(:,1)==4);
        condition2=(netsReduced(:,2)==1)|(netsReduced(:,2)==2);
        condition3=(netsReduced(:,3)==3)|(netsReduced(:,3)==4);
        condition=condition1&condition2&condition3;
        if any(condition)
            netsReduced=netsReduced(condition,1:3);
            valuesReduced=valuesReduced(condition,1:3);
        else
            error(message('rf:matchingnetwork:NoValidDesign','Pi'))
        end
    end


    goodValues=(imag(valuesReduced)==0)&~isinf(valuesReduced)&~isnan(valuesReduced);
    if isempty(goodValues)
        error(message('rf:matchingnetwork:NoValidDesign','3'))
    end
    goodRows=ones(length(goodValues(:,1)),1);
    for k=1:length(goodValues(1,:))
        goodRows=goodRows&goodValues(:,k);
    end
    net=netsReduced(goodRows,:);
    values=valuesReduced(goodRows,:);

    ckts=repmat(circuit(),[length(net(:,1)),1]);
    for j=1:length(net(:,1))
        ckts(j)=topologyToCircuit(net(j,:),values(j,:));
    end
end
