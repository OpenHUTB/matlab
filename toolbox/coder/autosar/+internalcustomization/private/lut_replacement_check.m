function lut_replacement_check




    rec=ModelAdvisor.Check('mathworks.autosar.lut_replacement_check');
    rec.Title=DAStudio.message('autosarstandard:autosarchecks:lut_replacement_title');
    rec.TitleTips=DAStudio.message('autosarstandard:autosarchecks:lut_replacement_tip');
    rec.CSHParameters.MapKey='autosar';
    rec.CSHParameters.TopicID=rec.Id;

    rec.setCallbackFcn(@(system,checkObj)Advisor.Utils.genericCheckCallback(system,checkObj,'autosarstandard:autosarchecks:lut_replacement',@hCheckAlgo),'None','DetailStyle');
    rec.setReportStyle('ModelAdvisor.Report.SmartStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.SmartStyle'});

    rec.Value=true;
    rec.SupportLibrary=false;
    rec.SupportExclusion=true;
    rec.SupportHighlighting=true;

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParametersLayoutGrid([1,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense(autosar_license);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,autosar_group);
end


function violations=hCheckAlgo(system)

    violations={};

    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdlAdvObj.getInputParameters;



    blockTypesRegExp='\<Lookup_n-D\>|\<Interpolation_n-D\>|\<PreLookup\>';

    allBlocks=find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks',inputParams{1}.Value,...
    'LookUnderMasks',inputParams{2}.Value,...
    'RegExp','on',...
    'BlockType',blockTypesRegExp,...
    'MaskType',regexp('','emptystring'));

    allBlocks=mdlAdvObj.filterResultWithExclusion(allBlocks);

    for i=1:length(allBlocks)
        if strcmpi(get_param(allBlocks{i},'ExtrapMethod'),'Clip')

            vObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(vObj,'SID',allBlocks{i});
            vObj.Status=DAStudio.message('autosarstandard:autosarchecks:lut_replacement_warn_replace');
            vObj.IsViolation=false;
            vObj.IsInformer=true;

            if strcmpi(get_param(allBlocks{i},'BlockType'),'PreLookup')
                vObj.RecAction=DAStudio.message('autosarstandard:autosarchecks:lut_replacement_rec_action_prelookup');

            elseif strcmpi(get_param(allBlocks{i},'BlockType'),'Lookup_n-D')&&strcmpi(get_param(allBlocks{i},'NumberOfTableDimensions'),'1')
                vObj.RecAction=DAStudio.message('autosarstandard:autosarchecks:lut_replacement_rec_action_1DLUT');

            elseif strcmpi(get_param(allBlocks{i},'BlockType'),'Lookup_n-D')&&strcmpi(get_param(allBlocks{i},'NumberOfTableDimensions'),'2')
                vObj.RecAction=DAStudio.message('autosarstandard:autosarchecks:lut_replacement_rec_action_nDLUT');

            elseif strcmpi(get_param(allBlocks{i},'BlockType'),'Interpolation_n-D')&&strcmpi(get_param(allBlocks{i},'NumberOfTableDimensions'),'1')
                vObj.RecAction=DAStudio.message('autosarstandard:autosarchecks:lut_replacement_rec_action_1DInterp');

            elseif strcmpi(get_param(allBlocks{i},'BlockType'),'Interpolation_n-D')&&strcmpi(get_param(allBlocks{i},'NumberOfTableDimensions'),'2')
                vObj.RecAction=DAStudio.message('autosarstandard:autosarchecks:lut_replacement_rec_action_nDInterp');
            else


                vObj=[];
            end

            violations=[violations;vObj];%#ok<AGROW>

        else

            vObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(vObj,'SID',allBlocks{i});
            vObj.Status=DAStudio.message...
            ('autosarstandard:autosarchecks:lut_replacement_warn_no_routine');
            vObj.RecAction=DAStudio.message...
            ('autosarstandard:autosarchecks:lut_replacement_rec_action_no_routine');
            violations=[violations;vObj];%#ok<AGROW>
        end

    end





    configObj=getActiveConfigSet(bdroot(system));
    writableCheckObj=configset.getParameterInfo...
    (configObj,'CodeReplacementLibrary');
    if~writableCheckObj.IsWritable||~writableCheckObj.IsUI
        return;
    end





    if strcmp(writableCheckObj.Value,'None')
        vObj=ModelAdvisor.ResultDetail;
        ModelAdvisor.ResultDetail.setData(vObj,'Model',bdroot(system),'Parameter','CodeReplacementLibrary','CurrentValue',get_param(bdroot(system),'CodeReplacementLibrary'),'RecommendedValue','AUTOSAR 4.0');
        vObj.Status=DAStudio.message('Advisor:engine:CCOFModelParamFail');
        vObj.RecAction=DAStudio.message('Advisor:engine:CCOFModelParamRecAct');
        vObj.Description=DAStudio.message('autosarstandard:autosarchecks:lut_replacement_crl_description');
        violations=[violations;vObj];
    end

end
