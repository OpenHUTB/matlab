function data=getTypedValue(untypedData,type,isRWV,modelH)




    if~exist('isRWV','var')
        isRWV=false;
    end


    if~exist('modelH','var')||isempty(modelH)
        modelH=[];
        modelObj=[];
    else
        modelH=bdroot(modelH);
        modelObj=get_param(modelH,'Object');
    end

    if iscell(untypedData)
        data=str2double(untypedData);

        if isempty(type)
            return;
        end

        parsedDt=SimulinkFixedPoint.DataTypeContainer.ParsedDataTypeContainer(type,modelObj);


        if parsedDt.isFixed&&~parsedDt.isBuiltInInteger

            fxpTypeInfo=parsedDt.ResolvedType;
            if~isempty(fxpTypeInfo)
                data=createFiObject(data,untypedData,fxpTypeInfo,isRWV,parsedDt.isScaledDouble);
                return;
            end
        end


        [isEnum,enumCls]=sldvshareprivate('util_is_enum_type',type);
        if isEnum
            data=feval(enumCls,data);
            return;
        end






        try




            if parsedDt.isBuiltInInteger
                resolvedType=type;
            else
                resolvedType=parsedDt.ResolvedString;
            end



            if strcmp(resolvedType,'boolean')||strcmp(resolvedType,'bool')
                resolvedType='logical';
            end

            data=cellfun(@(x)str2num([resolvedType,'(',x,')']),untypedData,'UniformOutput',1);%#ok<ST2NM>
        catch ME
            error(message('Sldv:privateUtils:UnrecognizedType',type));
        end
    else
        data=untypedData;

        if isempty(type)
            return;
        end


        [isfxptype,fxpTypeInfo,isScaledDouble]=sldvshareprivate('util_is_fxp_type',type,modelH);
        if isfxptype&&~isempty(fxpTypeInfo)
            data=Sldv.utils.createFiObjectFromDoubleVal(untypedData,fxpTypeInfo,isScaledDouble);
            if~isRWV


                untypedData=Sldv.utils.replaceInfWithRealmax(untypedData);


                for k=1:prod(size(data))%#ok<PSIZE>
                    a=data(k);
                    a.int=untypedData(k);
                    data(k)=a;
                end
            end

            return;
        end


        [isEnum,enumCls]=sldvshareprivate('util_is_enum_type',type);
        if isEnum
            data=feval(enumCls,untypedData);
            return;
        end






        try


            if strcmp(type,'boolean')||strcmp(type,'bool')
                type='logical';
            end

            data=cast(untypedData,type);
        catch ME
            error(message('Sldv:privateUtils:UnrecognizedType',type));
        end
    end
end

function data=createFiObject(data,untypedData,fxpTypeInfo,isRWV,isScaledDouble)
    if isScaledDouble
        fiObj=fi(zeros(size(data)),fxpTypeInfo,'DataType','ScaledDouble');
    else
        fiObj=fi(zeros(size(data)),fxpTypeInfo);
    end

    if~isRWV
        tempFiObj=stripscaling(fiObj);
    else
        tempFiObj=fiObj;
    end

    for k=1:numel(tempFiObj)
        a=tempFiObj(k);

        if isinf(data(k))
            if data(k)<0
                a.int=-realmax;
            else
                a.int=realmax;
            end
        elseif isnan(data(k))
            a.Value=num2str(realmax);
            a=a-a;
        else
            a.Value=untypedData{k};
        end

        tempFiObj(k)=a;
    end

    if~isRWV
        data=reinterpretcast(tempFiObj,fiObj.numerictype);
    else
        data=tempFiObj;
    end
end
