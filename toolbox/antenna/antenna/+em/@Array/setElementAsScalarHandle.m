function setElementAsScalarHandle(obj,propVal,excludeList1,excludeList2)




    checkObjectClass(obj,propVal);
    propClass=class(propVal);


    excludeClass1=excludeList1;
    if any(strcmpi(propClass,excludeClass1))
        error(message('antenna:antennaerrors:Unsupported',...
        strcat(char(propClass),' as Element'),'Arrays'));
    end

    excludeClass2=excludeList2;
    if(any(strcmpi(propClass,{'reflector','reflectorCircular','reflectorCorner'}))&&...
        any(strcmpi(class(propVal.Exciter),excludeClass2)))||...
        ((isa(propVal,'em.BackingStructure')||isa(propVal,'em.ParabolicAntenna'))...
        &&em.internal.checkLRCArray(propVal.Exciter))
        error(message('antenna:antennaerrors:Unsupported',...
        [class(reflector),' with ',class(propVal.Exciter),' as exciter'],'Arrays'));
    end



    objParent=getParent(obj);
    if(isa(objParent,'em.BackingStructure')||isa(objParent,'em.ParabolicAntenna'))

        if(isa(propVal,'em.BackingStructure')||isa(propVal,'em.ParabolicAntenna'))
            error(message('antenna:antennaerrors:InvalideExciterInBacking',...
            class(obj),class(propVal),class(objParent)));

        elseif em.internal.checkLRCArray(propVal)
            error(message('antenna:antennaerrors:InvalidExciterSubArray',class(obj),...
            class(propVal),class(objParent)));
        end
    end

    obj.privateArrayStruct.Element=copy(propVal);

    setParent(obj.privateArrayStruct.Element,obj);

    setChild(obj,obj.privateArrayStruct.Element);






    if isempty(propVal.MesherStruct.Mesh.FeedType)
        propVal.MesherStruct.Mesh.FeedType='singleedge';
    end
    setFeedType(obj,propVal.MesherStruct.Mesh.FeedType);
    disableSource(obj.privateArrayStruct.Element);
