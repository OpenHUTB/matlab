function setElementAsHandleArray(obj,propVal,excludeList)





    checkObjectClass(obj,propVal);
    propClass=class(propVal);
    excludeClass=excludeList;
    if any(strcmpi(propClass,excludeClass))
        error(message('antenna:antennaerrors:Unsupported',...
        strcat(char(propClass),...
        ' as separate antenna elements'),'Arrays'));
    end

    for i=1:numel(propVal)
        if isprop(propVal(i),'Exciter')&&em.internal.checkLRCArray(propVal(i).Exciter)
            error(message('antenna:antennaerrors:Unsupported',...
            [class(propVal(i)),' with ',(class(propVal(i).Exciter)),...
            ' as Exciter, as separate antenna elements'],'Arrays'));
        end
        if isa(propVal,'helix')||isa(propVal,'dipoleHelix')
            if isDielectricSubstrate(propVal(i))
                error(message('antenna:antennaerrors:UnsupportedHetArrayWithSub',class(propVal)));
            end
        end
    end



    if isa(obj,'linearArray')||isa(obj,'circularArray')
        checkHeterogeneousElementForLinear(obj,propVal);
    elseif isa(obj,'rectangularArray')
        checkHeterogeneousElementForRectangular(obj,propVal);
    else
        checkHeterogeneousElementForConformal(obj,propVal);
    end


    obj.privateArrayStruct.Element=propVal(1).empty(0,size(propVal,2));
    for i=1:size(propVal,1)
        for j=1:size(propVal,2)
            obj.privateArrayStruct.Element(i,j)=copy(propVal(i,j));

            setParent(obj.privateArrayStruct.Element(i,j),obj);

            setChild(obj,obj.privateArrayStruct.Element(i,j));
            disableSource(obj.privateArrayStruct.Element(i,j));
        end
    end






    if isempty(propVal(1).MesherStruct.Mesh.FeedType)
        propVal(1).MesherStruct.Mesh.FeedType='singleedge';
    end
    setFeedType(obj,propVal(1).MesherStruct.Mesh.FeedType);

end
