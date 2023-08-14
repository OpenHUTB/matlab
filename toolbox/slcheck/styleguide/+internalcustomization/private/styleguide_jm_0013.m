function rec=styleguide_jm_0013





    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:jm0013Title');
    rec.TitleID='mathworks.maab.jm_0013';
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:jm0013Tip');
    rec.TitleInRAWFormat=false;
    rec.CallbackHandle=@jm_0013_StyleOneCallback;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleOne';
    rec.CallbackReturnInRAWFormat=false;
    rec.PushToModelExplorer=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group=sg_maab_group;
    rec.LicenseName={styleguide_license};
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jm0013Title';


    function[ResultDescription]=jm_0013_StyleOneCallback(system)

        feature('scopedaccelenablement','off');
        ResultDescription={};




        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
        mdladvObj.setCheckResultStatus(false);



        hAnnDropShadow=[];
        hAnnDropShadowStr={};


        annotations=find_system(system,'FindAll','on','FollowLinks',styleguide_lib_follow('check'),...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all',...
        'type','annotation');

        for i=1:length(annotations)
            if strcmp(get_param(annotations(i),'DropShadow'),'on')
                hAnnDropShadow=[hAnnDropShadow,annotations(i)];
            end
        end

        currentResult=hAnnDropShadow;


        currentResult=mdladvObj.filterResultWithExclusion(currentResult);

        ft=ModelAdvisor.FormatTemplate('ListTemplate');

        ft.setSubBar(0);
        ft.setCheckText(DAStudio.message('ModelAdvisor:styleguide:jm0013_Info'));

        if isempty(currentResult)
            mdladvObj.setCheckResultStatus(true);
            ft.setSubResultStatus('pass');
            ft.setSubResultStatusText({DAStudio.message('ModelAdvisor:styleguide:jm0013_Pass')});
        else
            lnkStr={};
            for inx=1:length(currentResult)
                object=get_param(currentResult(inx),'Object');
                pathA=object.path;
                lnkStr{inx}=['<a href="matlab: styleguideprivate(',...
                '''view_annotation''',',','''',pathA,...
                '''',')">',pathA,'</a>'];
            end
            mdladvObj.setCheckResultStatus(false);
            ft.setSubResultStatus('warn');
            ft.setSubResultStatusText({DAStudio.message('ModelAdvisor:styleguide:jm0013FailMsg')});
            ft.setRecAction({DAStudio.message('ModelAdvisor:styleguide:jm0013_RecAct')});
            ft.setListObj(lnkStr(:)');
        end

        ResultDescription{end+1}=ft;
