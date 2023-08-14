




function slidObj=convertSlObjectToSlidObject(mf0Mdl,name,slObjMap)
    global locSlObjMap
    global busInConvertion findCircularRef topBusName


    locSlObjMap=slObjMap;
    finishup1=onCleanup(@()clearvars('-global','locSlObjMap'));


    busInConvertion=containers.Map;
    findCircularRef=false;
    topBusName='';
    finishup2=onCleanup(@()clearvars('-global','busInConvertion','findCircularRef','topBusName'));


    slidObj=[];
    if~isKey(locSlObjMap,name)
        return;
    end

    slObj=slObjMap(name);
    className=class(slObj);
    switch className
    case 'Simulink.Bus'
        slidObj=getSlidStructForBus('',name,mf0Mdl);
    otherwise
        Simulink.internal.slid.LibraryUtil.throwWarning('slid:messages:InvalidType',name,className);
    end
end



function slidStruct=getSlidStructForBus(parentBusName,thisBusName,mf0Model)
    global locSlObjMap busInConvertion findCircularRef topBusName

    slidStruct=[];


    if isempty(parentBusName)
        topBusName=thisBusName;
    end
    isTopBus=strcmp(topBusName,thisBusName);


    if~isKey(locSlObjMap,thisBusName)
        assert(~isTopBus);
        Simulink.internal.slid.LibraryUtil.throwWarning('slid:messages:NestedBusNotFound',parentBusName,thisBusName);
        return;
    end



    if~findCircularRef&&isKey(busInConvertion,thisBusName)
        findCircularRef=true;
        if isTopBus

            Simulink.internal.slid.LibraryUtil.throwWarning('slid:messages:BusInCircularRef',thisBusName);
            findCircularRef=false;
        end
        return;
    end


    busObj=locSlObjMap(thisBusName);
    if~isa(busObj,'Simulink.Bus')
        Simulink.internal.slid.LibraryUtil.throwWarning('slid:messages:NestedBusNotFound',parentBusName,thisBusName);
        return;
    end


    if~hasValidCodeGenOptions(thisBusName,busObj)
        return;
    end


    busInConvertion(thisBusName)=1;


    slidStruct=slid.StructureType(mf0Model);
    slidStruct.Name=thisBusName;
    slidStruct.Description=busObj.Description;

    elements=busObj.Elements;
    elemNum=length(elements);
    for elementIndex=1:elemNum
        ele=elements(elementIndex);
        slidStructElement=slid.StructureElement(mf0Model);
        slidStructElement.Name=ele.Name;
        slidStructElement.Description=ele.Description;


        if isnumeric(ele.Dimensions)||~isempty(str2num(ele.Dimensions))




            slidStructElement.Dimensions=ele.Dimensions;
        else



            Simulink.internal.slid.LibraryUtil.throwWarning('slid:messages:InvalidDimensionsInBus',thisBusName,ele.Dimensions,ele.Name);
            slidStruct.destroy;
            slidStruct=[];
            return;
        end

        type=getSlidType(mf0Model,ele,thisBusName);
        if~isempty(type)
            slidStructElement.Type=type;
            slidStruct.Element.add(slidStructElement);
        else





            if isTopBus&&findCircularRef
                Simulink.internal.slid.LibraryUtil.throwWarning('slid:messages:SubBusInCircularRef',thisBusName);
                findCircularRef=false;
            end
            slidStruct.destroy;
            slidStruct=[];
            return;
        end
    end

    remove(busInConvertion,thisBusName);
end


function type=getSlidType(mf0Model,busElement,thisBusName)
    global locSlObjMap

    dtStr=busElement.DataType;
    pDT=parseDataType(dtStr);
    type=[];
    elName=busElement.Name;

    if pDT.isBus



        pair=split(pDT.ResolvedString,':');
        subBusName=pair{2};
        type=getSlidStructForBus(thisBusName,subBusName,mf0Model);
        return;
    end

    if pDT.isFloat



        type=slid.FloatingPointType(mf0Model);
        type.TypeIdentifier=pDT.OriginalString;
    elseif pDT.isBuiltInInteger






        type=slid.IntegerType(mf0Model);
        type.TypeIdentifier=pDT.OriginalString;
    elseif pDT.isFixed



        type=slid.FixedPointType(mf0Model);
        type.TypeIdentifier=pDT.OriginalString;
    elseif pDT.isBoolean


        type=slid.BooleanType(mf0Model);
        type.TypeIdentifier=pDT.OriginalString;
    elseif pDT.isEnum
        Simulink.internal.slid.LibraryUtil.throwWarning('slid:messages:InvalidTypeInBus',thisBusName,'Enumeration type',elName);
        return;
    else
        assert(pDT.isUnknown);







        if isKey(locSlObjMap,dtStr)
            dtObj=locSlObjMap(dtStr);
            if isa(dtObj,'Simulink.Bus')

                type=getSlidStructForBus(thisBusName,dtStr,mf0Model);
            else
                Simulink.internal.slid.LibraryUtil.throwWarning('slid:messages:InvalidTypeInBus',thisBusName,class(dtObj),elName);
            end
        else

            Simulink.internal.slid.LibraryUtil.throwWarning('slid:messages:InvalidTypeInBus',thisBusName,dtStr,elName);
        end
        return;
    end

    if isa(type,'slid.RealType')
        type.Minimum=busElement.Min;
        type.Maximum=busElement.Max;
        if strcmp(busElement.Complexity,'complex')
            type.Complexity=slid.ComplexityKind.COMPLEX;
        else
            type.Complexity=slid.ComplexityKind.REAL;
        end
        type.UnitExpression=busElement.Unit;
    end
end


function isValid=hasValidCodeGenOptions(busName,busObj)
    if~strcmp(busObj.DataScope,'Auto')
        isValid=false;
        Simulink.internal.slid.LibraryUtil.throwWarning('slid:messages:InvalidBusCodeGenOpts',busName,'DataScope');
        return;
    end

    if~isempty(busObj.HeaderFile)
        isValid=false;
        Simulink.internal.slid.LibraryUtil.throwWarning('slid:messages:InvalidBusCodeGenOpts',busName,'HeaderFile');
        return;
    end

    if~isequal(busObj.Alignment,-1)
        isValid=false;
        Simulink.internal.slid.LibraryUtil.throwWarning('slid:messages:InvalidBusCodeGenOpts',busName,'Alignment');
        return;
    end

    isValid=true;
end
