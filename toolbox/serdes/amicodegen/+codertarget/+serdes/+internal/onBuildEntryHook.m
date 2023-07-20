function onBuildEntryHook(~)



    if ismac
        error(message('serdes:export:MacNotSupported'));
    end
end

