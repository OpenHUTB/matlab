function setSampleTime(model,paramValue)
    if~isnan(str2double(paramValue))


        eventBlocks=plc_find_system(model,'LookUnderMasks','all','BlockType','EventListener');
        initializeBlocks=get_param(eventBlocks,'Parent');
        cellfun(@(x)set_param(x,'Commented','on'),initializeBlocks);

        allBlocks=plc_find_system(model,'LookUnderMasks','on','Type','block');
        cellfun(@(x)setSampleTime_internal(x,paramValue),allBlocks);

        cellfun(@(x)set_param(x,'Commented','off'),initializeBlocks);
    end
end

function setSampleTime_internal(blkName,sampleTime)




    try %#ok<TRYNC>
        set_param(blkName,'SampleTime',sampleTime)
    end
end