function varargout=EventListener_ddg_cb(source,action,varargin)






    blockH=varargin{1};

    switch action

    case 'getResetNames'
        varargout{1}=i_GetResetNames(blockH);

    case 'getReinitNames'
        varargout{1}=i_GetReinitNames(blockH);

    case 'checkEventName'
        varargout{1}=i_CheckEventName(blockH);

    case 'eventNameCallback'
        dialog=varargin{2};
        varargout{1}=i_ReportNameCollision(dialog,blockH);

    otherwise
        error(['assert - bad action, ',action]);
    end
end


function tableData=i_GetResetNames(blockH)

    tableData={};

    info=get_param(bdroot(blockH),'EventIdentifiers');

    for i=1:numel(info)
        if strcmp(info(i).EventFuncType,'Reset')
            tableData{end+1}=info(i).EventFuncName;
        end
    end
end


function tableData=i_GetReinitNames(blockH)

    tableData={};



    info=get_param(bdroot(blockH),'EventIdentifiers');

    for i=1:numel(info)
        if strcmp(info(i).EventFuncType,'Reinit')
            tableData{end+1}=info(i).EventFuncName;
        end
    end
end



function ret=i_CheckEventName(blockH)


    ret=false;

    thisType=get_param(blockH,'EventType');
    if strcmp(thisType,'Reinitialize')
        otherType='Reset';
    else
        otherType='Reinitialize';
    end

    thisName=get_param(blockH,'EventName');

    modelObj=get_param(bdroot(blockH),'Object');



    otherBlk=find_system(modelObj.Handle,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks','on','BlockType','EventListener','EventType',otherType,'EventName',thisName);

    if~isempty(otherBlk)
        if(numel(otherBlk)>1)
            ret=true;
        else
            if(otherBlk~=blockH)

                ret=true;
            end
        end
    end
end


function ret=i_ReportNameCollision(dialog,blockH)
    ret=i_CheckEventName(blockH);
    if ret
        thisName=get_param(blockH,'EventName');
        thisType=get_param(blockH,'EventType');
        if strcmp(thisType,'Reinitialize')

            otherType='Reset';
        else
            otherType='Reinitialize';
        end

        errObj=DAStudio.UI.Util.Error;
        errObj.ID='EventNameCollision';
        errObj.Tag='EventNameCollisionTag';
        errObj.Type='Error';
        errObj.Message=DAStudio.message('Simulink:blocks:WarnEventNameCollisionInfo',thisName,otherType,thisType);

        dialog.setWidgetWithError('EventName',errObj);
    else
        dialog.clearWidgetWithError('EventName');
    end
end


