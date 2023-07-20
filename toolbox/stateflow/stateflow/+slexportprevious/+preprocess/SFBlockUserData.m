function SFBlockUserData(obj)





    if isR2015bOrEarlier(obj.ver)


        c=find_system(obj.modelName,'LookUnderReadProtectedSubsystems','on','LookUnderMasks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,...
        'MaskType','Stateflow');
        for i=1:numel(c)
            chart=c{i};
            set_param(chart,'UserData',[]);
            set_param(chart,'UserDataPersistent','off');
        end
    end

end
