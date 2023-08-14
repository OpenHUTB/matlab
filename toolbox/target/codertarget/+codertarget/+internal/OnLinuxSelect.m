function OnLinuxSelect(hObj,~,~)



    if strcmpi(get_param(getConfigSet(hObj),'SampleTimeConstraint'),'STIndependent')

        return;
    end

    set_param(getConfigSet(hObj),'PositivePriorityOrder','on');
end
