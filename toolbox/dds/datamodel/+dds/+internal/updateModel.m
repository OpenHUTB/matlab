
















function updateModel(modelToUpdate,refModel)

    validateattributes(modelToUpdate,{'mf.zero.Model'},{'scalar'});
    validateattributes(refModel,{'mf.zero.Model'},{'scalar'});


    updateTxn=modelToUpdate.beginRevertibleTransaction();
    rootElement=getFirstSystem(modelToUpdate);
    refRootElement=getFirstSystem(refModel);
    validateattributes(rootElement,{'dds.datamodel.system.System'},{'scalar'});
    validateattributes(refRootElement,{'dds.datamodel.system.System'},{'scalar'});


    elementMap=containers.Map;


    updateElement(modelToUpdate,rootElement,refRootElement,elementMap);


    updateCrossRef(rootElement,refRootElement,elementMap);
    updateTxn.commit();
end



function updateElement(model,element,refElement,elementMap)

    elementClass=class(element);
    refElementClass=class(refElement);
    assert(strcmp(elementClass,refElementClass));



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
            if~isobject(refProperty)||isenum(refProperty)




                validateattributes(property,{'numeric','logical','char'},{});
                validateattributes(refProperty,{'numeric','logical','char'},{});
                element.setPropertyValue(thePropertyName,refProperty)
            elseif isa(refProperty,'mf.zero.Map')
                validateattributes(property,{'mf.zero.Map'},{});
                updateMap(model,property,refProperty,elementMap);
            elseif isa(refProperty,'mf.zero.Sequence')||isa(refProperty,'mf.zero.PrimitiveSequence')
                validateattributes(property,{'mf.zero.Sequence','mf.zero.PrimitiveSequence'},{});
                updateSequence(model,property,refProperty,elementMap);
            else



                validateattributes(property,{'mf.zero.ModelElement'},{});
                validateattributes(refProperty,{'mf.zero.ModelElement'},{});
                if isempty(refProperty)
                    property.destroy;
                    property=eval([class(refProperty),'.empty']);
                    element.setPropertyValue(thePropertyName,property);
                else



                    if isempty(property)||~strcmp(class(property),class(refProperty))
                        property.destroy;
                        property=feval(class(refProperty),model);
                        element.setPropertyValue(thePropertyName,property);
                    end

                    updateElement(model,property,refProperty,elementMap);
                end
            end
        end
    end
end


function updateMap(model,map,refMap,elementMap)





    myMap=dds.internal.utils.convertMF0MapToContainersMap(map);
    myRefMap=dds.internal.utils.convertMF0MapToContainersMap(refMap);


    keysToDelete=dds.internal.utils.findKeysToDelete(myMap,myRefMap);


    for index=1:length(keysToDelete)
        theKey=keysToDelete{index};

        if~isempty(map.getByKey(theKey))
            map{theKey}.destroy;
        end
        myMap.remove(theKey);
    end


    mapKeys=myMap.keys;
    for index=1:length(mapKeys)
        theKey=mapKeys{index};
        if~isvalid(myMap(theKey))


            myMap.remove(theKey);
        else
            updateElement(model,myMap(theKey),myRefMap(theKey),elementMap);
        end
    end


    keysToAdd=dds.internal.utils.findKeysToAdd(myMap,myRefMap);


    for index=1:length(keysToAdd)
        theKey=keysToAdd{index};
        elementType=class(myRefMap(theKey));
        addedElement=feval(elementType,model);
        updateElement(model,addedElement,myRefMap(theKey),elementMap);
        map.add(addedElement);
    end
end


function updateSequence(model,seq,refSeq,elementMap)
    if(isa(refSeq,'mf.zero.PrimitiveSequence'))
        for index=1:min(seq.Size,refSeq.Size)
            refContent=refSeq(index);
            if iscell(refContent)


                assert(length(refContent)==1);
                refContent=refContent{1};
            end
            seq(index)=refContent;
        end

        if seq.Size>refSeq.Size
            while seq.Size~=refSeq.Size
                seq.removeAt(seq.Size);
            end

        elseif seq.Size<refSeq.Size
            index=seq.Size+1;
            while index<=refSeq.Size
                content=refSeq(index);
                if iscell(content)
                    content=content{1};
                end
                seq.add(content);
                index=index+1;
            end
        end
    else
        validateattributes(refSeq,{'mf.zero.Sequence'},{});
        for index=1:min(seq.Size,refSeq.Size)

            updateElement(model,seq(index),refSeq(index),elementMap);
        end

        if seq.Size>refSeq.Size
            while seq.Size~=refSeq.Size
                seq(seq.Size).destroy;
            end

        elseif seq.Size<refSeq.Size
            index=seq.Size+1;
            while index<=refSeq.Size
                elementType=class(refSeq(index));
                addedElement=feval(elementType,model);
                seq.add(addedElement);
                updateElement(model,seq(index),refSeq(index),elementMap);
                index=index+1;
            end
        end
    end
end



function updateCrossRef(element,refElement,elementMap)
    elementClass=class(element);
    refElementClass=class(refElement);


    assert(strcmp(elementClass,refElementClass));



    if~isobject(refElement)
        return
    else
        theProperties=properties(refElement);
        for index=1:length(theProperties)
            thePropertyName=theProperties{index};
            property=element.getPropertyValue(thePropertyName);
            refProperty=refElement.getPropertyValue(thePropertyName);
            if isempty(refProperty)





                element.setPropertyValue(thePropertyName,refProperty);

                continue;
            end
            if~isempty(property)&&isa(property,'mf.zero.Map')...
                &&isprop(property,'Type')...
                &&(isa(property.Type,'dds.datamodel.types.TypeMapEntry')...
                ||(isprop(property.Type,'mcosName')...
                &&isequal(property.Type.mcosName,'dds.datamodel.types.TypeMapEntry')))clear


                continue;
            end
            propertyIsContained=refElement.MetaClass.getPropertyByName(thePropertyName).isComposite;


            if propertyIsContained

                assert(~isa(refProperty,'mf.zero.PrimitiveSequence'));
                if isa(refProperty,'mf.zero.Map')
                    map=dds.internal.utils.convertMF0MapToContainersMap(property);
                    refMap=dds.internal.utils.convertMF0MapToContainersMap(refProperty);

                    assert(length(map.keys)==length(refMap.keys));
                    theKeys=refMap.keys;
                    for i=1:length(theKeys)
                        theKey=theKeys{i};
                        updateCrossRef(map(theKey),refMap(theKey),elementMap);
                    end
                elseif isa(refProperty,'mf.zero.Sequence')

                    assert(property.Size==refProperty.Size);
                    for i=1:refProperty.Size
                        updateCrossRef(property(i),refProperty(i),elementMap);
                    end
                else



                    validateattributes(property,{'mf.zero.ModelElement'},{});
                    validateattributes(refProperty,{'mf.zero.ModelElement'},{});
                    updateCrossRef(property,refProperty,elementMap);
                end

            else



                if~isobject(refProperty)||isenum(refProperty)||isa(refProperty,'mf.zero.PrimitiveSequence')
                    continue;
                elseif isa(refProperty,'mf.zero.Map')
                    property.clear;
                    myRefMap=dds.internal.convertMF0MapToContainersMap(refProperty);
                    theKeys=myRefMap.keys;
                    for i=1:length(theKeys)
                        theKey=theKeys{i};
                        property.add(elementMap(myRefMap(theKey).UUID));
                    end
                elseif isa(refProperty,'mf.zero.Sequence')
                    property.clear;
                    for i=1:refProperty.Size
                        property.add(elementMap(refProperty(i).UUID));
                    end
                else
                    validateattributes(property,{'mf.zero.ModelElement'},{});
                    validateattributes(refProperty,{'mf.zero.ModelElement'},{});
                    element.setPropertyValue(thePropertyName,elementMap(refProperty.UUID));
                end
            end
        end
    end
end

function systemElem=getFirstSystem(model)
    tpe=model.topLevelElements;
    if numel(tpe)>1
        for i=1:numel(tpe)
            if isa(tpe(i),'dds.datamodel.system.System')
                systemElem=tpe(i);
                return;
            end
        end
    else
        if isa(tpe,'dds.datamodel.system.System')
            systemElem=tpe;
            return;
        end
    end
end


