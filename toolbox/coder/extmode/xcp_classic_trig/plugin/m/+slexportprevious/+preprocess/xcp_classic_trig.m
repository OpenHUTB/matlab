function xcp_classic_trig(helper)





    if isInVersionInterval(helper.ver,'R2020b','R2021a')
        blockPath=get_param(helper.modelName,'ExtModeTrigSignalBlockPath');
        if~isempty(blockPath)



            helper.appendRule(...
            sprintf('<ExtModeTrigSignalBlockPath|WILDCARD:repval "%s">',blockPath));
        end
    end

end


