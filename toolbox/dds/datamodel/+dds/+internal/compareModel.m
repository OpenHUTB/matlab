















function modelEqual=compareModel(modelToCompare,refModel)
    modelEqual=true;


    validateattributes(modelToCompare,{'mf.zero.Model'},{'scalar'});
    validateattributes(refModel,{'mf.zero.Model'},{'scalar'});


    rootElement=modelToCompare.topLevelElements;
    refRootElement=refModel.topLevelElements;
    validateattributes(rootElement,{'dds.datamodel.system.System'},{'scalar'});
    validateattributes(refRootElement,{'dds.datamodel.system.System'},{'scalar'});


    elementMap=containers.Map;


    if~compareElement(rootElement,refRootElement,elementMap)
        modelEqual=false;
        return;
    end


    if~compareCrossRef(rootElement,refRootElement,elementMap)
        modelEqual=false;
        return;
    end
end



function elementEqual=compareElement(element,refElement,elementMap)
    elementEqual=true;

    elementClass=class(element);
    refElementClass=class(refElement);


    if~strcmp(elementClass,refElementClass)
        elementEqual=false;
        return;
    end



    elementMap(refElement.UUID)=element;



    theProperties=properties(refElement);
    for index=1:length(theProperties)
        thePropertyName=theProperties{index};
        refProperty=refElement.getPropertyValue(thePropertyName);
        propertyIsContained=refElement.MetaClass.getPropertyByName(thePropertyName).isComposite;
        propertyIsNotObject=~isobject(refProperty);
        propertyIsEnumOrPrimitiveSeq=isenum(refProperty)||isa(refProperty,'mf.zero.PrimitiveSequence');


        if propertyIsContained||propertyIsNotObject||propertyIsEnumOrPrimitiveSeq
            property=element.getPropertyValue(thePropertyName);

            if~strcmp(class(property),class(refProperty))
                elementEqual=false;
                return;
            end
            if~isobject(refProperty)||isenum(refProperty)




                validateattributes(property,{'numeric','logical','char'},{});
                validateattributes(refProperty,{'numeric','logical','char'},{});
                if ischar(property)
                    if~strcmp(property,refProperty)
                        elementEqual=false;
                        return;
                    end
                else
                    if property~=refProperty
                        elementEqual=false;
                        return;
                    end
                end
            elseif isa(refProperty,'mf.zero.Map')
                if~compareMap(property,refProperty,elementMap)
                    elementEqual=false;
                    return;
                end
            elseif isa(refProperty,'mf.zero.Sequence')||isa(refProperty,'mf.zero.PrimitiveSequence')
                if~compareSequence(property,refProperty,elementMap)
                    elementEqual=false;
                    return;
                end
            else




                assert(isa(property,'mf.zero.ModelElement'));
                propertyIsEmpty=isempty(property);
                refPropertyIsEmpty=isempty(refProperty);
                if xor(propertyIsEmpty,refPropertyIsEmpty)
                    elementEqual=false;
                    return;
                end
                if~propertyIsEmpty

                    if~compareElement(property,refProperty,elementMap)
                        elementEqual=false;
                        return;
                    end
                end
            end
        end
    end
end


function mapEqual=compareMap(map,refMap,elementMap)
    mapEqual=true;





    myMap=dds.internal.utils.convertMF0MapToContainersMap(map);
    myRefMap=dds.internal.utils.convertMF0MapToContainersMap(refMap);

    keysToDelete=dds.internal.utils.findKeysToDelete(myMap,myRefMap);

    if~isempty(keysToDelete)
        mapEqual=false;
        return;
    end


    keysToAdd=dds.internal.utils.findKeysToAdd(myMap,myRefMap);

    if~isempty(keysToAdd)
        mapEqual=false;
        return;
    end


    keys=myMap.keys;
    for index=1:length(keys)
        theKey=keys{index};
        if~compareElement(myMap(theKey),myRefMap(theKey),elementMap)
            mapEqual=false;
            return;
        end
    end
end


function sequenceEqual=compareSequence(seq,refSeq,elementMap)
    sequenceEqual=true;
    if seq.Size~=refSeq.Size
        sequenceEqual=false;
        return;
    end
    if(isa(refSeq,'mf.zero.PrimitiveSequence'))
        for index=1:seq.Size
            content=seq(index);
            refContent=refSeq(index);
            if~strcmp(class(content),class(refContent))
                sequenceEqual=false;
                return;
            end
            if iscell(content)
                content=content{1};
                refContent=refContent{1};
            end
            if ischar(content)
                if~strcmp(content,refContent)
                    sequenceEqual=false;
                    return;
                end
            else
                assert(isnumeric(content)||islogical(content));
                if content~=refContent
                    sequenceEqual=false;
                    return;
                end
            end
        end
    else
        assert(isa(refSeq,'mf.zero.Sequence'));
        for index=1:seq.Size

            if~compareElement(seq(index),refSeq(index),elementMap)
                sequenceEqual=false;
                return;
            end
        end
    end
end



function crossRefEqual=compareCrossRef(element,refElement,elementMap)
    crossRefEqual=true;
    elementClass=class(element);
    refElementClass=class(refElement);


    if~strcmp(elementClass,refElementClass)
        crossRefEqual=false;
        return;
    end



    if~isobject(refElement)
        return
    else
        theProperties=properties(refElement);
        for index=1:length(theProperties)
            thePropertyName=theProperties{index};
            property=element.getPropertyValue(thePropertyName);
            refProperty=refElement.getPropertyValue(thePropertyName);

            if isempty(refProperty)
                assert(isempty(property));
                continue;
            end
            propertyIsContained=refElement.MetaClass.getPropertyByName(thePropertyName).isComposite;


            if propertyIsContained

                assert(~isa(refProperty,'mf.zero.PrimitiveSequence'));
                if isa(refProperty,'mf.zero.Map')
                    myMap=dds.internal.utils.convertMF0MapToContainersMap(property);
                    myRefMap=dds.internal.utils.convertMF0MapToContainersMap(refProperty);

                    assert(length(myMap.keys)==length(myRefMap.keys));
                    theKeys=myRefMap.keys;
                    for i=1:length(theKeys)
                        theKey=theKeys{i};
                        if~compareCrossRef(myMap(theKey),myRefMap(theKey),elementMap)
                            crossRefEqual=false;
                            return;
                        end
                    end
                elseif isa(refProperty,'mf.zero.Sequence')

                    assert(property.Size==refProperty.Size);
                    for i=1:refProperty.Size
                        if~compareCrossRef(property(i),refProperty(i),elementMap)
                            crossRefEqual=false;
                            return;
                        end
                    end
                else



                    assert(isa(property,'mf.zero.ModelElement')&&isa(refProperty,'mf.zero.ModelElement'));
                    if~compareCrossRef(property,refProperty,elementMap)
                        crossRefEqual=false;
                        return;
                    end
                end

            else



                if~isobject(refProperty)||isenum(refProperty)||isa(refProperty,'mf.zero.PrimitiveSequence')
                    continue;
                elseif isa(refProperty,'mf.zero.Map')
                    myMap=dds.internal.convertMF0MapToContainersMap(property);
                    myRefMap=dds.internal.convertMF0MapToContainersMap(refProperty);
                    if length(myMap.keys)~=length(myRefMap.keys)
                        crossRefEqual=false;
                        return;
                    end
                    theKeys=myRefMap.keys;
                    for i=1:length(theKeys)
                        theKey=theKeys{i};
                        if elementMap(myRefMap(theKey).UUID)~=myMap(theKey)
                            crossRefEqual=false;
                            return;
                        end
                    end
                elseif isa(refProperty,'mf.zero.Sequence')
                    if property.Size~=refProperty.Size
                        crossRefEqual=false;
                        return;
                    end
                    for i=1:refProperty.Size
                        if elementMap(refProperty(i).UUID)~=property(i)
                            crossRefEqual=false;
                            return;
                        end
                    end
                else
                    assert(isa(property,'mf.zero.ModelElement')&&isa(refProperty,'mf.zero.ModelElement'));
                    if elementMap(refProperty.UUID)~=property
                        crossRefEqual=false;
                        return;
                    end
                end
            end
        end
    end
end