function[rec]=styleguide_db_0093






    rec=Simulink.MdlAdvisorCheck;
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:db0093Title');
    rec.TitleID='StyleGuide: db_0093';
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:db0093Tip');
    rec.TitleInRAWFormat=false;
    rec.CallbackHandle=@db_0093_StyleThreeCallback;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.CallbackReturnInRAWFormat=false;
    rec.PushToModelExplorer=false;
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group=sg_maab_group;
    rec.LicenseName={styleguide_license};
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='db0093Title';
end

function[ResultDescription,ResultHandles]=db_0093_StyleThreeCallback(varargin)

    system=varargin{1};


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);


    [resultData]=getCheckInformation(system);


    [ResultDescription,ResultHandles]=updateMdladvObj(mdladvObj,resultData);

end

function[ResultDescription,ResultHandles]=updateMdladvObj(mdladvObj,resultData)

    feature('scopedaccelenablement','off');


    ResultDescription={};
    ResultHandles={};

    ResultDescription{end+1}=sg_maab_msg('db0093Tip');
    ResultHandles{end+1}=[];

    if(isempty(resultData.badBlocks))
        currentDescription=DAStudio.message('ModelAdvisor:styleguide:PassedMsg');
        mdladvObj.setCheckResultStatus(true);
        ResultDescription{end+1}=currentDescription;
        ResultHandles{end+1}={};
    else

        currentDescription=DAStudio.message('ModelAdvisor:styleguide:db0093FailMsg');
        ResultDescription{end+1}=currentDescription;
        ResultHandles{end+1}=resultData.badBlocks;
        mdladvObj.setCheckResultStatus(false);
    end
end

function[resultData]=getCheckInformation(system)

    resultData.badBlocks={};



    origSetting=get_param(system,'SignalResolutionControl');
    if strcmp(origSetting,'UseLocalSettings')
        set_param(system,'SignalResolutionControl','TryResolveAll');
    end




    lineHandles=find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks',styleguide_lib_follow('check'),...
    'FindAll','on',...
    'LookUnderMasks','all',...
    'Type','line');
    lineNames=get_param(lineHandles,'Name');

    [index]=find(strcmp(lineNames,'')==0);
    lineHandles=lineHandles(index);
    srcBlkHand=get_param(lineHandles,'SrcBlockHandle');
    lineObj=get_param(lineHandles,'Object');
    lineNames=lineNames(index);
    numNamed=length(lineNames);
    for inx=1:numNamed
        try

            dstPortObj=get_param(lineObj{inx}.DstPortHandle(1),'Object');
            srcPortObj=dstPortObj.getActualSrc;
            actSrcName=get_param(srcPortObj(1),'Name');
        catch
            srcPortObj=get_param(lineObj{inx}.SrcPortHandle(1),'Object');
            actSrcName=srcPortObj.name;
        end
        if(strcmp(actSrcName,lineNames{inx})==0)
            srcBlkHandObj=get_param(srcBlkHand{inx},'Object');
            resultData.badBlocks{end+1}=srcBlkHandObj.getFullName;
        end
    end


    set_param(system,'SignalResolutionControl',origSetting);

end

