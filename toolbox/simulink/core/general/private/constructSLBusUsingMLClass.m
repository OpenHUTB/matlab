


















function result=constructSLBusUsingMLClass(className,w2Dict)
    if(nargin<2)
        w2Dict=true;
    end


    result=[];




    if~contains(which(className),matlabroot)
        return;
    end


    busDict=Simulink.BusDictionary.getInstance();


    cDef=meta.class.fromName(className);

    busTypeExists=busDict.classBasedBusTypeDefined(className);


    if numel(cDef)==0

        if busTypeExists
            busDict.deleteClassBasedBusType(className);
        end
        return;
    end


    if busDict.classHandleExists(className)
        prevHandle=busDict.getclassMetaDataHandle(className);

        if~isequal(prevHandle,cDef)
            busDict.deleteClassBasedBusType(className);
            busTypeExists=false;
        end
    end



    if busTypeExists
        result=busDict.getClassBasedBusType(className);
        return;
    end



    cProperties=cDef.PropertyList;
    elems=repmat(Simulink.BusElement,[1,numel(cProperties)]);
    publicElemIdx=1;
    for propIdx=1:numel(cProperties)

        propCurElem=cProperties(propIdx);


        if~strcmp(propCurElem.GetAccess,'public')
            continue;
        end

        elems(publicElemIdx).Name=propCurElem.Name;






        validationProvidesDT=false;
        validationProvidesDim=false;
        if~isempty(propCurElem.Validation)
            curVal=propCurElem.Validation;

            if~isempty(curVal.Class)
                curClassName=curVal.Class.Name;


                if contains(which(curClassName),'built-in')
                    elems(publicElemIdx).DataType=curClassName;

                elseif~isempty(enumeration(curClassName))
                    enumStrHead="Enum: ";
                    elems(publicElemIdx).DataType=strcat(enumStrHead,curClassName);

                else


                    if numel(constructSLBusUsingMLClass(curClassName,w2Dict))==0
                        return;
                    end

                    busStrHead="Bus: ";
                    elems(publicElemIdx).DataType=strcat(busStrHead,curClassName);
                end
                validationProvidesDT=true;
            end


            curSize=curVal.Size;
            sizeLength=length(curSize);
            if~isequal(sizeLength,0)
                dims=repmat(-1,[1,sizeLength]);
                for dimsIdx=1:sizeLength
                    dims(dimsIdx)=curSize(dimsIdx).Length;
                end
                elems(publicElemIdx).Dimensions=dims;
                validationProvidesDim=true;
            end
        end



        defVal=[];
        defValExists=false;
        if propCurElem.HasDefault
            defVal=propCurElem.DefaultValue;
            defValExists=true;
        end

        if~validationProvidesDT&&defValExists
            if(isnumeric(defVal)||isfi(defVal)||islogical(defVal))
                elems(publicElemIdx).DataType=class(defVal);


                if islogical(defVal)
                    elems(publicElemIdx).DataType='boolean';
                end


                if isfi(defVal)
                    elems(publicElemIdx).DataType=fixdt(numerictype(defVal));
                end


                if isenum(defVal)

                    enumStrHead="Enum: ";
                    elems(publicElemIdx).DataType=strcat(enumStrHead,class(defVal));
                end

            else
                if isnumerictype(defVal)
                    elems(publicElemIdx).DataType=fixdt(defVal);
                elseif isa(defVal,'Simulink.NumericType')
                    elems(publicElemIdx).DataType=defVal.tostring;
                end
            end
        end


        if~validationProvidesDim&&defValExists
            curElemSize=size(defVal);



            if isequal(curElemSize,[1,1])
                curElemSize=1;
            end
            elems(publicElemIdx).Dimensions=curElemSize;
        end


        if defValExists&&isnumeric(defVal)&&~isreal(defVal)
            elems(publicElemIdx).Complexity='complex';
        end

        publicElemIdx=publicElemIdx+1;
    end

    elems=elems(1:publicElemIdx-1);


    busType=Simulink.Bus;
    busType.Elements=elems;
    clear elems;








    busType=l_busTypeDecoration(className,busType,false);

    if w2Dict
        busDict.addClassBasedBusType(className,busType);
        busDict.addClassMetaDataHandle(className,cDef);
    end
    result=busType;
end






function decoratedBusType=l_busTypeDecoration(className,rawBusType,superClass)
    decoratedBusType=rawBusType;

    command=strcat(className,'.configAsSimulinkBus');

    method=which(command);
    if isempty(method)
        return;
    end


    [busAttr,elemAttr]=feval(command);



    if~superClass
        fields={'Description','DataScope','HeaderFile','Alignment'};
        for fieldIdx=1:numel(fields)
            if isfield(busAttr,fields(fieldIdx))
                decoratedBusType.(fields{fieldIdx})=busAttr.(fields{fieldIdx});
            end
        end
    end





    fields={'Dimensions','Min','Max','DimensionsMode','Description','Unit'};



    excludedProps=[];
    if isfield(busAttr,'ExcludedProperties')
        excludedProps=busAttr.ExcludedProperties;
    end

    busElemIdx=1;
    totalNumElems=numel(decoratedBusType.Elements);
    while busElemIdx<=totalNumElems
        curName=decoratedBusType.Elements(busElemIdx).Name;


        if any(strcmp(excludedProps,curName))
            decoratedBusType.Elements(busElemIdx)=[];
            totalNumElems=totalNumElems-1;
            continue;
        end


        if~isfield(elemAttr,curName)
            busElemIdx=busElemIdx+1;
            continue;
        end
        command=strcat('elemAttr.',curName);
        curDecor=eval(command);

        curElem=decoratedBusType.Elements(busElemIdx);
        for fieldIdx=1:numel(fields)
            if isfield(curDecor,fields(fieldIdx))
                curElem.(fields{fieldIdx})=curDecor.(fields{fieldIdx});
            end
        end

        decoratedBusType.Elements(busElemIdx)=curElem;
        busElemIdx=busElemIdx+1;
    end


    cDef=meta.class.fromName(className);
    superClassList=cDef.SuperclassList;

    for scIdx=1:numel(superClassList)
        curSCName=superClassList(scIdx).Name;

        cPathInfo=which(curSCName);
        if~contains(cPathInfo,'built-in')
            decoratedBusType=...
            l_busTypeDecoration(superClassList(scIdx).Name,decoratedBusType,true);
        end
    end
end

