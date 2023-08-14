function newTypes=makeFiTypesScaledDouble(origTypes)


    p=fipref;
    dto=p.DataTypeOverride;
    dtoa=p.DataTypeOverrideAppliesTo;
    p.DataTypeOverride='ScaledDoubles';
    p.DataTypeOverrideAppliesTo='Fixed-point';
    restoreDTOA=onCleanup(@()fipref('DataTypeOverrideAppliesTo',dtoa));
    restoreDTO=onCleanup(@()fipref('DataTypeOverride',dto));


    newTypes=makeFiTypesScaledDoubleImpl(origTypes);
end


function newType=makeFiTypesScaledDoubleImpl(origType)
    newType=origType;




    if iscell(origType)

        for ii=1:numel(origType)
            newType{ii}=makeFiTypesScaledDoubleImpl(origType{ii});
        end
    elseif~isscalar(origType)&&isa(origType,'coder.Type')

        for ii=1:numel(origType)
            newType(ii)=makeFiTypesScaledDoubleImpl(origType(ii));
        end

    elseif isa(origType,'coder.StructType')

        newType.Fields=makeFiTypesScaledDoubleImpl(origType.Fields);
        newType.Name=origType.Name;
        if~isempty(origType.InitialValue)

            newType.InitialValue=makeFiTypesScaledDoubleImpl(origType.InitialValue);
        end
    elseif isstruct(origType)

        NAMES=fieldnames(origType);
        for ii=1:length(NAMES)
            fieldName=NAMES{ii};
            for jj=1:numel(origType)
                fieldType=origType(jj).(fieldName);
                newFieldType=makeFiTypesScaledDoubleImpl(fieldType);
                newType(jj).(fieldName)=newFieldType;
            end
        end

    elseif isa(origType,'coder.Constant')

        newType=coder.Constant(makeFiTypesScaledDoubleImpl(origType.Value));
    else


        if isa(origType,'embedded.fi')


            newType=fi(origType);
        elseif isa(origType,'coder.FiType')


            fiVal=fi([],origType.NumericType);
            newType=coder.newtype('embedded.fi',...
            numerictype(fiVal),...
            origType.SizeVector,...
            origType.VariableDims,...
            'complex',origType.Complex,...
            'fimath',origType.Fimath);
            newType.Name=origType.Name;
            if~isempty(origType.InitialValue)

                newType.InitialValue=fi(origType.InitialValue);
            end
        else

            newType=origType;
        end
    end
end
