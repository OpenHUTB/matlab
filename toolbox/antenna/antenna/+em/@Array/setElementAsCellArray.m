function setElementAsCellArray(obj,propVal,excludeList)





    propValClasses=cellfun(@class,propVal,'UniformOutput',false);
    excludeClass=excludeList;

    for i=1:numel(excludeClass)
        if any(strcmpi(excludeClass{i},propValClasses))
            error(message('antenna:antennaerrors:Unsupported',...
            [excludeClass{i},' as Element'],'Arrays'));
        end
    end



    checkObjectClass(obj,propVal)
    infGPState=cellfun(@getInfGPState,propVal);
    if any(infGPState)

    end


    checkHeterogeneousElementForConformal(obj,propVal)

    obj.privateArrayStruct.Element=cell(size(propVal));
    feedtype=cell(size(propVal));
    for i=1:size(propVal,1)
        for j=1:size(propVal,2)

            obj.privateArrayStruct.Element{i,j}=copy(propVal{i,j});

            setParent(obj.privateArrayStruct.Element{i,j},obj);

            setChild(obj,obj.privateArrayStruct.Element{i,j});
            feedtype{i,j}=propVal{i,j}.MesherStruct.Mesh.FeedType;
            disableSource(obj.privateArrayStruct.Element{i,j});
        end
    end





    if all(strcmpi('singleedge',feedtype))
        setFeedType(obj,'singleedge');
    elseif all(strcmpi('doubleedge',feedtype))
        setFeedType(obj,'doubleedge');
    else
        obj.MesherStruct.Mesh.FeedType=feedtype;



    end
end