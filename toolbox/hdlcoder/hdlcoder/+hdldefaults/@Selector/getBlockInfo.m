function[numDims,indexMode,indexOptionArray,indexParamArray,...
    outputSizeArray,inputPortWidth,nfpOptions]=getBlockInfo(this,hC)





    slbh=hC.SimulinkHandle;
    numDims=str2double(get_param(slbh,'NumberOfDimensions'));
    indexMode=get_param(slbh,'IndexMode');
    indexOptionArray=get_param(slbh,'IndexOptionArray');
    indexParamArray=getResolvedInfo(slbh,'IndexParamArray');
    nfpOptions=getNFPBlockInfo(this);

    inputPortWidth=[1,hdlslResolve('InputPortWidth',slbh)];
    if any(inputPortWidth==-1)||numDims==2

        compiledDim=get_param(slbh,'CompiledPortDimensions');

        if numel(compiledDim.Inport)==2
            inputPortWidth=compiledDim.Inport;
        else
            inputPortWidth=compiledDim.Inport(2:3);
        end
    end
    try
        for ii=1:numel(indexParamArray)
            if~isempty(indexParamArray{ii})
                indexParamArray{ii}=slResolve(indexParamArray{ii},slbh);
            end
        end
    catch me
        fprintf('Block %s/%s emitted error ''%s''.',hC.Owner.FullPath,hC.Name,me.message);
    end
    outputSizeArray=getResolvedInfo(slbh,'OutputSizeArray');
    try
        for ii=1:numel(outputSizeArray)
            if~isempty(outputSizeArray{ii})
                outputSizeArray{ii}=slResolve(outputSizeArray{ii},slbh);
            end
        end
    catch me
        fprintf('Block %s/%s emitted error ''%s''.',hC.Owner.FullPath,hC.Name,me.message);
    end
end


function val=getResolvedInfo(block,prop)
    prop_val=get_param(block,prop);
    numCells=numel(prop_val);
    val=cell(numCells,1);
    for ii=1:numCells
        try
            resolved=slResolve(prop_val{ii},block);
        catch me
            if strcmp(me.identifier,'Simulink:Data:SlResolveNotResolved')



                continue;
            end
        end

        if isnumeric(resolved)||isfloat(resolved)||islogical(resolved)

            val{ii}=mat2str(resolved);
        end
    end
end
