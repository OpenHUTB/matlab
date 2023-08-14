function setDlNetworkOptionsVisibility(block)




    mask=Simulink.Mask.get(block);

    miniBatchSize=mask.getParameter('MiniBatchSize');
    inputFormat=mask.getParameter('InputDataFormats');

    networkToLoad=deep.blocks.internal.getSelectedNetwork(block);

    try
        networkInfo=deep.blocks.internal.getNetworkInfo(block,networkToLoad);
    catch
        networkInfo=[];
    end

    validNetwork=~isempty(networkInfo);
    dlnetworkEnabled=strcmp(get_param(block,'EnableDLNetwork'),'on');

    if validNetwork&&networkInfo.IsDlNetwork&&dlnetworkEnabled

        currentTableData=eval(inputFormat.Value);
        if~isequal(currentTableData(:,1),networkInfo.InputLayerNames)
            tableData=cell(networkInfo.NumInputs,2);
            tableData(:,1)=networkInfo.InputLayerNames;
            tableData(:,2)={''};

            valueString="{";
            for i=1:networkInfo.NumInputs
                valueString=valueString+sprintf("'%s', '%s';",tableData{i,:});
            end
            valueString=valueString+"}";

            inputFormat.Value=valueString;
        end

        if~isempty(miniBatchSize)
            miniBatchSize.Visible='off';
        end
        inputFormat.Visible='on';
    else
        if~isempty(miniBatchSize)
            miniBatchSize.Visible='on';
        end
        inputFormat.Visible='off';
    end

end