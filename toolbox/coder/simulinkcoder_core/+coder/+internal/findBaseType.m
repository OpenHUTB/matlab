function[baseType,headerFile,dataScope,isNested]=findBaseType(designDataLocation,baseName)










































    baseType=baseName;
    headerFile='';
    dataScope='';
    isNested=false;

    assert(ischar(designDataLocation));
    if isempty(designDataLocation)
        designDataLocation='base';
    end



    featVal=slfeature('SLDataDictionaryAPIDuplicateMode',1);
    oc=onCleanup(@()slfeature('SLDataDictionaryAPIDuplicateMode',featVal));



    already_evaluated='';
    while globalDataItemExists(baseType,designDataLocation)
        recursionChkStr=[' ',baseType,' '];
        if~isempty(strfind(already_evaluated,recursionChkStr))

            break;
        end
        if~isempty(already_evaluated)
            isNested=true;
        end
        already_evaluated=[already_evaluated,recursionChkStr];%#ok<AGROW>
        rType=getGlobalDataItem(baseType,designDataLocation);
        if isa(rType,'Simulink.AliasType')
            baseType=rType.BaseType;
            if isequal(headerFile,rType.HeaderFile)
                isNested=false;
            else
                headerFile=rType.HeaderFile;
            end
            dataScope=rType.DataScope;

        elseif isa(rType,'Simulink.NumericType')


            if strcmp(rType.DataTypeMode,'Boolean')
                baseType='boolean';
            elseif strcmp(rType.DataTypeMode,'Double')
                baseType='double';
            elseif strcmp(rType.DataTypeMode,'Single')
                baseType='single';
            elseif(strcmp(rType.DataTypeMode,'Fixed-point: unspecified scaling')||...
                (strcmp(rType.DataTypeMode,'Fixed-point: binary point scaling')&&...
                rType.FractionLength==0)||...
                (strcmp(rType.DataTypeMode,'Fixed-point: slope and bias scaling')&&...
                rType.Slope==1&&rType.Bias==0))
                if(rType.WordLength==8)
                    if strcmp(rType.Signedness,'Signed')
                        baseType='int8';
                    elseif strcmp(rType.Signedness,'Unsigned')
                        baseType='uint8';
                    else
                        baseType='';
                    end
                elseif(rType.WordLength==16)
                    if strcmp(rType.Signedness,'Signed')
                        baseType='int16';
                    elseif strcmp(rType.Signedness,'Unsigned')
                        baseType='uint16';
                    else
                        baseType='';
                    end
                elseif(rType.WordLength==32)
                    if strcmp(rType.Signedness,'Signed')
                        baseType='int32';
                    elseif strcmp(rType.Signedness,'Unsigned')
                        baseType='uint32';
                    else
                        baseType='';
                    end
                elseif(rType.WordLength==64)
                    if strcmp(rType.Signedness,'Signed')
                        baseType='int64';
                    elseif strcmp(rType.Signedness,'Unsigned')
                        baseType='uint64';
                    else
                        baseType='';
                    end
                else
                    baseType='';
                end
            else

                baseType='';
            end
            headerFile=rType.HeaderFile;
            dataScope=rType.DataScope;

            break;
        else


            baseType='';
            break;
        end
    end

    if strcmp(baseType,'int8')||...
        strcmp(baseType,'uint8')||...
        strcmp(baseType,'int16')||...
        strcmp(baseType,'uint16')||...
        strcmp(baseType,'int32')||...
        strcmp(baseType,'uint32')||...
        strcmp(baseType,'single')||...
        strcmp(baseType,'double')||...
        strcmp(baseType,'boolean')||...
        strcmp(baseType,'char')||...
        strcmp(baseType,'uint64')||...
        strcmp(baseType,'int64')
        return;

    else
        baseType='';
        return;
    end

