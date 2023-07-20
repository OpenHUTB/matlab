function scopeCallback(action,scopeblkOrModel)





    try
        switch action
        case 'comment'
            set_param(scopeblkOrModel,'Commented',uiservices.logicalToOnOff(...
            ~uiservices.onOffToLogical(get_param(scopeblkOrModel,'Commented'))));
        case 'open'
            isCommented=uiservices.onOffToLogical(get_param(scopeblkOrModel,'Commented'));
            s=get_param(scopeblkOrModel,'ScopeConfiguration');
            goingToOpen=~s.Visible;
            if goingToOpen&&isCommented

                set_param(scopeblkOrModel,'Commented','off');
            end
            s.Visible=goingToOpen;


            if goingToOpen
                s.ReduceUpdates=true;
            else
                s.OpenAtSimulationStart=false;
            end
        case 'commentall'
            scopeBlks=find_system(scopeblkOrModel,...
            'LookUnderMasks','all',...
            'MatchFilter',@Simulink.match.allVariants,...
            'BlockType','Scope');
            cellfun(@(x)set_param(x,'Commented','on'),scopeBlks);
        end
    catch E %#ok<NASGU>
        warndlg(DAStudio.message('Simulink:tools:MARegenerateReport'));
    end

end

