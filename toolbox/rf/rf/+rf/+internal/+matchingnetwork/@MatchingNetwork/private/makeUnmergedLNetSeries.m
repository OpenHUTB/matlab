

function[net,values]=makeUnmergedLNetSeries(allExtImpedances,targetFrequency)
    templateNets=cell(1,length(allExtImpedances)-1);
    templateValues=templateNets;

    [~,templateNets(:),templateValues(:)]=arrayfun(@(extZ1,extZ2)...
    (generateLMatchingNetworks(extZ1,extZ2,targetFrequency)),...
    allExtImpedances(1:end-1),allExtImpedances(2:end),'UniformOutput',0);

    indices=ones(1,length(templateNets));
    currentRow=1;

    netHeight=prod(cellfun(@(x)size(x,1),templateNets));
    if~netHeight
        error(message('rf:matchingnetwork:NoValidDesign','3'))
    end
    net0=zeros(netHeight,length(templateNets)*2);
    values0=net0;

    while(indices(1)<=size(templateNets{1},1))
        for k=1:length(indices)
            net0(currentRow,k*2-1:k*2)=templateNets{k}(indices(k),:);
            values0(currentRow,k*2-1:k*2)=templateValues{k}(indices(k),:);

        end

        currentRow=currentRow+1;
        indices(end)=indices(end)+1;
        for k=length(indices):-1:2
            if(indices(k)>size(templateNets{k},1))
                indices(k)=1;
                indices(k-1)=indices(k-1)+1;
            end
        end
    end
    net=net0;values=values0;
end