function lineStraightening(obj)













    featureOn=bitand(slfeature('SLLineStraightening'),2^10);
    if~featureOn
        return;
    end

    if~isR2018aOrEarlier(obj.ver)
        return;
    end


    if strcmp(get_param(obj.modelName,'AlignPorts'),'on')
        set_param(obj.modelName,'AlignPorts','off');
    end


    graphsToDisable=obj.findBlocksOfType('SubSystem',...
    'ReferenceBlock','',...
    'AlignPorts','on');

    cellfun(@(g)set_param(g,'AlignPorts','off'),graphsToDisable);


end
