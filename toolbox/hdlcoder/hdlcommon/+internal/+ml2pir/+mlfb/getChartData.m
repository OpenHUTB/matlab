function data=getChartData(this,blockH)




    data=internal.mtree.mlfb.IOInfo;


    [inputStrs,inputTypes]=this.getInputData(blockH);

    for i=1:numel(inputStrs)
        inputData=internal.mtree.mlfb.ChartData(...
        inputStrs{i},inputTypes(i),'input');

        data.addData(inputData);
    end


    [outputStrs,outputTypes]=this.getOutputData(blockH);

    for i=1:numel(outputStrs)
        outputData=internal.mtree.mlfb.ChartData(...
        outputStrs{i},outputTypes(i),'output');

        data.addData(outputData);
    end



    [tunableParamStrs,tunableParamTypes,tunableDataIDs]=this.getTunableProperty(blockH);

    for i=1:numel(tunableParamStrs)
        tunableParam=internal.mtree.mlfb.TunableParameter(...
        tunableParamStrs{i},tunableParamTypes(i),tunableDataIDs(i));

        data.addData(tunableParam);
    end



    [paramStrs,paramTypes]=this.getNonTunableProperty(blockH);

    blockMask=Simulink.Mask.get(blockH);
    if isempty(blockMask)
        blockMaskParams={};
    else
        blockMaskParams={blockMask.Parameters.Name};
    end

    for i=1:numel(paramStrs)
        name=paramStrs{i};

        if ismember(name,blockMaskParams)

            value=hdlslResolve(name,blockH);
        else

            value=slResolve(name,blockH);
        end

        const=internal.mtree.mlfb.ConstantParameter(name,paramTypes(i),value);
        data.addData(const);
    end

end


