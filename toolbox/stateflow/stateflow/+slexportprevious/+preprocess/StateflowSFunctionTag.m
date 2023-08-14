function StateflowSFunctionTag(obj)






    if isR2019aOrEarlier(obj.ver)


        c=find_system(obj.modelName,'LookUnderReadProtectedSubsystems','on','LookUnderMasks','on','MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'MaskType','Stateflow');
        for i=1:numel(c)
            chart=c{i};
            sfblock=[chart,'/ SFunction '];
            if isempty(getSimulinkBlockHandle(sfblock))
                continue;
            end
            tag=get_param(sfblock,'Tag');
            match=regexp(tag,'Stateflow S-Function (?<num>\d*)','names');
            if numel(match)==1
                newtag=['Stateflow S-Function ',obj.modelName,' ',match.num];



                obj.appendRule(['<Block<Tag|"',tag,'":repval "',newtag,'">>']);
            end
        end
    end
end
