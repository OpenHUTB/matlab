function[rec]=styleguide_na_0011








    rec=Advisor.Utils.getDefaultCheckObject('mathworks.maab.na_0011',false,@checkGotoScope,'PostCompile');
    rec.Visible=true;
    rec.Enable=true;
    rec.LicenseName={styleguide_license};
    rec.SupportExclusion=true;

    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='mathworks.maab.na_0011';

    inputParam1=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParam2=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParam2.Value='all';
    rec.setInputParameters({inputParam1,inputParam2});
    rec.setInputParametersLayoutGrid([1,6]);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end

function resultData=checkGotoScope(system)
    modelAdvisorObject=Simulink.ModelAdvisor.getModelAdvisor(system);
    followlinkParam=Advisor.Utils.getStandardInputParameters(modelAdvisorObject,'find_system.FollowLinks');
    lookundermaskParam=Advisor.Utils.getStandardInputParameters(modelAdvisorObject,'find_system.LookUnderMasks');



    resultData={};







    gotoBlks=find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'regexp','on',...
    'FollowLinks',followlinkParam.Value,...
    'LookUnderMasks',lookundermaskParam.Value,...
    'BlockType','Goto',...
    'TagVisibility','global|scoped');
    gotoBlks=modelAdvisorObject.filterResultWithExclusion(gotoBlks);
    if~isempty(gotoBlks)

        currentResult=notConnectedToFunctionCalls(gotoBlks);
        if~isempty(currentResult)
            resultData=currentResult;
        end
    end
end

function retBlks=notConnectedToFunctionCalls(inputBlks)
    ph=get_param(inputBlks,'PortHandles');
    retBlks={};
    for inx=1:length(ph)
        temp=get_param(ph{inx}.Inport,'CompiledPortDataType');



        if~any(strcmp(temp,{'fcn_call','action'}))
            retBlks{end+1}=inputBlks{inx};
        end
    end
end

