function checkIfElementHasLossySubstrate(obj)

    tempElement=makeTemporaryElementCacheForConformal(obj,size(obj.FeedLocation,1));
    isLossySubstrate=cellfun(@(x)isprop(x,'Substrate')&&~isequal(x.Substrate.('LossTangent'),zeros(size(x.Substrate.('LossTangent')))),tempElement,'UniformOutput',false);
    isLossySubstrate=cell2mat(isLossySubstrate);
    elementWithLossySubstrate=tempElement(isLossySubstrate);

    idOfElemWithSubOnExciter=[];
    for i=1:numel(tempElement)


        [~,~,c]=isDielectricSubstrate(tempElement{i});
        if c==1
            idOfElemWithSubOnExciter=i;
        end
    end

    if~isempty(elementWithLossySubstrate)
        obj.privateSubstrate=elementWithLossySubstrate{1}.Substrate;
    elseif~isempty(idOfElemWithSubOnExciter)
        obj.privateSubstrate=tempElement{idOfElemWithSubOnExciter}.Exciter.Substrate;
    else




        isSubstrate=cellfun(@(x)isprop(x,'Substrate')&&~isequal(x.Substrate.('EpsilonR'),ones(size(x.Substrate.('EpsilonR')))),tempElement,'UniformOutput',false);
        isSubstrate=cell2mat(isSubstrate);
        elementWithSubstrate=tempElement(isSubstrate);
        if~isempty(elementWithSubstrate)
            obj.privateSubstrate=elementWithSubstrate{1}.Substrate;
        else
            obj.privateSubstrate=dielectric('Name','Air');
        end
    end