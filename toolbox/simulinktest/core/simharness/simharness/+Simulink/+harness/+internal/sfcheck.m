function sfcheck(ownerHandle)




    if~license('test','Stateflow')


        for block=find_system(ownerHandle,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','MaskType','Stateflow')'

            if~sfprivate('is_eml_chart_block',block)&&...
                ~sfprivate('is_reactive_testing_table_chart_block',block)&&...
                ~sfprivate('is_reqtable_chart_block',block)
                DAStudio.error('Simulink:Harness:StateflowLicenseRequired');
            end
        end
    end
end
