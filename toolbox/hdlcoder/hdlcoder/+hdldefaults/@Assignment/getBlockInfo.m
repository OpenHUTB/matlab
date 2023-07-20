function[idxBase,ndims,idxParamArray,...
    idxOptionArray,outputSizeArray]=getBlockInfo(~,hC)


    slbh=hC.SimulinkHandle;

    idxBase=get_param(slbh,'IndexMode');
    ndims=get_param(slbh,'NumberOfDimensions');

    outputSizeArray=cell(1,str2double(ndims));
    uSigType=hC.getInputPortSignal(1).Type;
    if uSigType.isArrayType
        uDim=uSigType.Dimensions;
    else
        uDim=1;
    end
    if numel(outputSizeArray)>1&&isscalar(uDim)
        if uSigType.isArrayType&&uSigType.isRowVector
            uDim=[1,uDim];
        else
            uDim=[uDim,1];
        end
    end
    for ii=1:numel(outputSizeArray)
        outputSizeArray{ii}=double(uDim(ii));
    end

    idxParamArray=getResolvedInfo(slbh,'IndexParamArray');
    try
        for ii=1:numel(idxParamArray)
            if~isempty(idxParamArray{ii})
                idxParamArray{ii}=slResolve(idxParamArray{ii},slbh);
            end
        end
    catch me
        fprintf('Block %s/%s emitted error ''%s''.',hC.Owner.FullPath,hC.Name,me.message);
    end

    idxOptionArray=get_param(slbh,'IndexOptionArray');

end


function val=getResolvedInfo(block,prop)
    prop_val=get_param(block,prop);
    numCells=numel(prop_val);
    val=cell(numCells,1);
    for ii=1:numCells
        try
            resolved=slResolve(prop_val{ii},block);
        catch me
            if strcmp(me.identifier,'MATLAB:slResolve:NotResolved')||...
                strcmp(me.identifier,'Simulink:Data:SlResolveNotResolved')



                continue;
            end
        end

        if isnumeric(resolved)||isfloat(resolved)||islogical(resolved)

            val{ii}=mat2str(resolved);
        end
    end
end