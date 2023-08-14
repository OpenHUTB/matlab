function adaptMaskProperties(CurrentBlock)




    topMask=Simulink.Mask.get(CurrentBlock);
    topMaskProperties={topMask.Parameters.Name};
    for idx=1:numel(topMaskProperties)
        if~isempty(topMask.Parameters(idx).Callback)
            eval(topMask.Parameters(idx).Callback);
        end
    end

end
