function validateInputDataFormats(inputFormats,isDlNetwork)




    if~isDlNetwork
        return
    end

    for i=1:numel(inputFormats)
        inputFormat=inputFormats{i};
        assert(~isempty(inputFormat),...
        message('deep_blocks:common:InputDataFormatEmpty'));
    end

end

