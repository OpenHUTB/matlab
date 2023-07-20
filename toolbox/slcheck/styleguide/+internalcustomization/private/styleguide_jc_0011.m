function styleguide_jc_0011()

    rec=ModelAdvisor.Check('mathworks.maab.jc_0011');
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:jc0011Title');
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:jc0011Tip');
    rec.setCallbackFcn(@jc_0011_StyleOneCallback,'None','StyleOne');
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.LicenseName={styleguide_license};
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc0011Title';
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end

function[ResultDescription]=jc_0011_StyleOneCallback(system)

    feature('scopedaccelenablement','off');
    ResultDescription={};

    modelAdvisorObject=Simulink.ModelAdvisor.getModelAdvisor(system);
    modelAdvisorObject.setCheckResultStatus(false);

    status=false;

    try
        model=bdroot(system);
        if strcmp(get_param(model,'BooleanDataType'),'on')
            status=true;
        else

            encodedModelName=modeladvisorprivate('HTMLjsencode',get_param(model,'Name'),'encode');
            encodedModelName=[encodedModelName{:}];
            lnkStr={['<a href="matlab: modeladvisorprivate openCSAndHighlight ',...
            [encodedModelName,' ''BooleanDataType'' '],'">',...
            DAStudio.message('ModelAdvisor:styleguide:jc0011ModConf'),'</a>']};
        end
    catch
        lnkStr={};
        msgStr=DAStudio.message('ModelAdvisor:do178b:MissingParameterMsg','BooleanDataType');
    end;

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    msgStr=[DAStudio.message('ModelAdvisor:styleguide:MathWorksAutomotiveAdvisoryBoardChecks'),': jc_0011'];
    ft.setCheckText({DAStudio.message('ModelAdvisor:styleguide:jc0011_Info')});

    if~status
        ft.setSubResultStatus('warn');
        ft.setSubResultStatusText({DAStudio.message('ModelAdvisor:styleguide:jc0011FailMsg')});
        ft.setRecAction({DAStudio.message('ModelAdvisor:styleguide:jc0011_RecAct')});
        ft.setListObj(lnkStr);
        modelAdvisorObject.setCheckResultStatus(false);
    else
        ft.setSubResultStatus('pass');
        ft.setSubResultStatusText({DAStudio.message('ModelAdvisor:styleguide:jc0011_Pass')});
        modelAdvisorObject.setCheckResultStatus(true);
    end
    ft.setSubBar(0);
    ResultDescription{end+1}=ft;
end


