function synthesized=synthesizeDimensions(choices,activeValue,identifierArray,variantVariableSpecification)






    if isempty(variantVariableSpecification)
        vv_spec=Simulink.Parameter();
    else

        vv_spec=copy(variantVariableSpecification);
    end

    vv_spec.Value=activeValue;


    dimsString='[';
    for c=1:numel(identifierArray)
        dimsString=sprintf('%s %s',dimsString,num2str(identifierArray{c}{1}));
    end
    dimsString=strcat(dimsString,']');

    vv_spec.Dimensions=dimsString;
    synthesized={vv_spec};

    conds=choices(1:2:end);
    numOfConds=length(conds);










    numberOfRows=numel(choices)/2;
    numberOfColumns=ndims(choices{2});
    choiceDims=zeros(numberOfRows,numberOfColumns);
    for c=1:numberOfRows
        choiceDims(c,:)=size(choices{2*c});
    end

    for m=1:numberOfColumns

        if nnz(diff(choiceDims(:,m)))==0
            continue;
        end



        kv=Simulink.VariantVariable();
        for n=1:numOfConds
            cond=conds{n};
            choice=choiceDims(n,m);
            kv=kv.addChoice({cond,choice});
        end
        kv.Specification=identifierArray{m}{2};

        pkv_spec=Simulink.Parameter;
        pkv_spec.DataType='int32';
        pkv_spec.Min=min(choiceDims(:,m));
        pkv_spec.Max=max(choiceDims(:,m));
        pkv_spec.CoderInfo.StorageClass='Custom';
        pkv_spec.CoderInfo.CustomStorageClass='Define';
        pkv_spec.CoderInfo.CustomAttributes.HeaderFile='rtw_variant_dims.h';
        pkv_spec.DataType='int32';

        synthesized{end+1}=kv;%#ok
        synthesized{end+1}=identifierArray{m}{1};%#ok
        synthesized{end+1}=pkv_spec;%#ok
        synthesized{end+1}=identifierArray{m}{2};%#ok
    end
end


