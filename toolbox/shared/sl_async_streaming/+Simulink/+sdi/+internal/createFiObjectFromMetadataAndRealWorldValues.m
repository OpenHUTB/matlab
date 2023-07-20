function fiObj=createFiObjectFromMetadataAndRealWorldValues(...
    fiMetadata,fiIntegerArray,flattenValues)






    if nargin<3
        flattenValues=true;
    end




    if flattenValues
        fiIntegerArray=fiIntegerArray(:);
    end


    if isfield(fiMetadata,'NumericDataType')&&...
        strcmpi(fiMetadata.NumericDataType,'Half')
        fiObj=half.typecast(fiIntegerArray);
        return
    end

    if isfield(fiMetadata,'NumericDataType')&&...
        strcmpi(fiMetadata.NumericDataType,'ScaledDouble')
        cmd=@Simulink.SimulationData.utFI.createScaledDoubleFI;
    else
        cmd=@sim2fi;
    end

    try
        if isfield(fiMetadata,'FractionLength')

            fiObj=feval(cmd,...
            fiIntegerArray,...
            fiMetadata.Signedness,...
            fiMetadata.WordLength,...
            fiMetadata.FractionLength);
        elseif isfield(fiMetadata,'SlopeAdjustmentFactor')

            fiObj=feval(cmd,...
            fiIntegerArray,...
            fiMetadata.Signedness,...
            fiMetadata.WordLength,...
            fiMetadata.SlopeAdjustmentFactor,...
            fiMetadata.FixedExponent,...
            fiMetadata.Bias);
        else

            fiObj=feval(cmd,...
            fiIntegerArray,...
            numerictype(fiMetadata.Signedness,...
            fiMetadata.WordLength));
        end
    catch me
        Simulink.sdi.internal.warning(me.message);
        fiObj=[];
    end
end
