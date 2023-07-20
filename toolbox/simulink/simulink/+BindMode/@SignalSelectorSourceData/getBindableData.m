function bindableData=getBindableData(this,selectionHandles,activeDropDownValue)







    selectionModelName='';
    for idx=1:numel(selectionHandles)
        if(selectionHandles(idx)~=0)
            validSelectionHandle=selectionHandles(idx);
            selectionModelName=get_param(bdroot(selectionHandles(idx)),'Name');
            break;
        end
    end
    sourceModelName=this.modelName;

    activeEditor=BindMode.utils.getLastActiveEditor();
    assert(~isempty(activeEditor));
    sourceFullPath=this.hierarchicalPathArray;
    if(strcmp(get_param(validSelectionHandle,'Type'),'port'))
        validSelectionHandle=get_param(get_param(validSelectionHandle,'Parent'),'Handle');
    end
    selectionFullPath=convertToCell(Simulink.BlockPath.fromHierarchyIdAndHandle(activeEditor.getHierarchyId,validSelectionHandle));
    if(~BindMode.utils.isSameModelInstance(sourceFullPath,selectionFullPath))
        shouldNotBind=showHelp(this,selectionModelName);
        if shouldNotBind
            selectionHandles=[];
        end
    end


    bindableData=slsignalselector.SignalSelectorBindMode.getBindableData(this,...
    selectionHandles,activeDropDownValue);

end

function shouldNotBind=showHelp(this,selectionModelName)
    editors=GLUE2.Util.findAllEditors(selectionModelName);
    shouldNotBind=0;

    if~isempty(editors)
        studio=editors(1).getStudio;
        activeEditor=studio.App.getActiveEditor();



        blockType=get_param(this.sourceElementHandle,'BlockType');
        isScope=strcmp('Scope',blockType)||strcmp('WebTimeScopeBlock',blockType);
        if isScope
            activeEditor.deliverInfoNotification('Spcuilib:scopes:OnlyTestpointedSignalsInModelRef',...
            message('Spcuilib:scopes:OnlyTestpointedSignalsInModelRef').string());
        else
            activeEditor.deliverInfoNotification('Spcuilib:scopes:ModelRefNotSupportedText',message('Spcuilib:scopes:ModelRefNotSupportedText').string());
            shouldNotBind=1;
        end




        notificationTimer=timer('TimerFcn',@(~,~)closeHelp(this,activeEditor),...
        'StopFcn',@(thisTimer,~)delete(thisTimer),...
        'ObjectVisibility','on','StartDelay',12,'Tag','ModelRefBanner');
        notificationTimer.start();
    end

end

function closeHelp(this,activeEditor)
    try
        if strcmp(get_param(this.sourceElementHandle,'BlockType'),'Scope')
            activeEditor.closeNotificationByMsgID('Spcuilib:scopes:OnlyTestpointedSignalsInModelRef');
        else
            activeEditor.closeNotificationByMsgID('Spcuilib:scopes:ModelRefNotSupportedText');
        end
    catch ME
        ME.message;
    end
end
