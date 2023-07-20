function newTypes=makeDoubleTypesSingle(origTypes)


    p=fipref;
    dto=p.DataTypeOverride;
    dtoa=p.DataTypeOverrideAppliesTo;
    p.DataTypeOverride='ForceOff';
    restoreDTOA=onCleanup(@()fipref('DataTypeOverrideAppliesTo',dtoa));
    restoreDTO=onCleanup(@()fipref('DataTypeOverride',dto));

    newTypes=makeDoubleTypesSingleImpl(origTypes);
end


function newType=makeDoubleTypesSingleImpl(origType)
    newType=origType;




    if iscell(origType)

        for ii=1:numel(origType)
            newType{ii}=makeDoubleTypesSingleImpl(origType{ii});
        end
    elseif~isscalar(origType)&&isa(origType,'coder.Type')

        for ii=1:numel(origType)
            newType(ii)=makeDoubleTypesSingleImpl(origType(ii));
        end

    elseif isa(origType,'coder.StructType')

        newType.Fields=makeDoubleTypesSingleImpl(origType.Fields);
        newType.Name=origType.Name;
        if~isempty(origType.InitialValue)

            newType.InitialValue=makeDoubleTypesSingleImpl(origType.InitialValue);
        end

    elseif isa(origType,'coder.CellType')

        newType.Cells=makeDoubleTypesSingleImpl(origType.Cells);

    elseif isstruct(origType)

        NAMES=fieldnames(origType);
        for ii=1:length(NAMES)
            fieldName=NAMES{ii};
            for jj=1:numel(newType)
                fieldType=origType(jj).(fieldName);
                newFieldType=makeDoubleTypesSingleImpl(fieldType);
                newType(jj).(fieldName)=newFieldType;
            end
        end

    elseif isa(origType,'coder.Constant')

        newType=coder.Constant(makeDoubleTypesSingleImpl(origType.Value));
        newType.Name=origType.Name;
    else


        if isa(origType,'double')

            newType=single(origType);
        elseif isa(origType,'embedded.fi')&&isdouble(origType)

            newType=fi(origType,'DataType','Single');
        elseif isa(origType,'coder.FiType')&&isdouble(origType.NumericType)
            fiVal=fi([],'DataType','Single');
            newType=coder.newtype('embedded.fi',...
            numerictype(fiVal),...
            origType.SizeVector,...
            origType.VariableDims,...
            'complex',origType.Complex,...
            'fimath',origType.Fimath);
            newType.Name=origType.Name;

        elseif isa(origType,'coder.PrimitiveType')&&strcmp(origType.ClassName,'double')

            newType=coder.newtype('single',...
            origType.SizeVector,...
            origType.VariableDims,...
            'complex',origType.Complex,...
            'sparse',origType.Sparse);
            newType.Name=origType.Name;
            if~isempty(origType.InitialValue)

                newType.InitialValue=makeDoubleTypesSingleImpl(origType.InitialValue);
            end
        else

            newType=origType;
        end
    end
end
