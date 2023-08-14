function checks=i18nParameterChecks(hDrv)

    checks=struct('path',{},...
    'type',{},...
    'message',{},...
    'level',{},...
    'MessageID',{});






    i18n_CLI_white_list={'AlteraSimulatorLibPath','BlocksWithNoCharacterizationFile','CPAnnotationFile',...
    'CPGuidanceFile','CriticalPathEstimationFile','DateComment','DistributedPipeliningBarriersFile',...
    'HighlightFeedbackLoopsFile','RetimingCPFile','SynthesisProjectAdditionalFiles',...
    'TargetDirectory','TargetSubdirectory','XilinxSimulatorLibPath'};


    CLI=hDrv.getCLI();
    CLI_fields=fields(CLI);
    for itr=1:length(CLI_fields)
        field_name=CLI_fields{itr};
        field_val=CLI.(field_name);
        if~ischar(field_val)
            continue;
        end
        if any(field_val>=128)
            if any(strcmpi(i18n_CLI_white_list,field_name))
                continue;
            end
            msg=message('hdlcoder:validate:i18nParameters',field_name);
            checks(end+1).message=msg.getString();%#ok<AGROW>
            checks(end).type='model';
            checks(end).level='Error';
            checks(end).type='model';
            checks(end).path=hDrv.ModelName;
            checks(end).MessageID=msg.Identifier;
        end
    end
end
