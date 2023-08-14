function errInfo=verifyTaskToEventSourceAssignmentCore(tskMgrData,tskMgr)




    import soc.internal.taskmanager.*

    errInfo=[];
    usedEvtSrcs={};
    tasks=getEventDrivenTaskNames(tskMgrData);
    btnLbl=DAStudio.message('codertarget:utils:TaskMapAutoMapLbl');
    for j=1:numel(tasks)
        taskName=tasks{j};
        taskData=tskMgrData.getTask(taskName);
        connectedEvtSrcBlk=getEventSourceBlockForTask(tskMgr,taskName);
        curEvtSrc=taskData.taskEventSource;
        if~iCheckEventSrcNotEmpty(),break;end
        if~iCheckEventSrcSpecified(),break;end
        if~iCheckEventSrcMatchedConnection(),break;end
        if~iCheckEventSrcUnique(),break;end
        if~iCheckEventNotInternal(),break;end
        usedEvtSrcs{end+1}=curEvtSrc;%#ok<AGROW>
    end
    function ret=iCheckEventSrcNotEmpty
        if isempty(connectedEvtSrcBlk)
            errInfo.ID='codertarget:utils:TaskEventSourceBlockEmpty';
            errInfo.Args={taskName};
        end
        ret=isempty(errInfo);
    end
    function ret=iCheckEventSrcSpecified
        unspecifiedEvtSrc=DAStudio.message('codertarget:utils:UnspecifiedEvent');
        if isequal(curEvtSrc,unspecifiedEvtSrc)
            errInfo.ID='codertarget:utils:TaskEventUnspecified';
            errInfo.Args={taskName,btnLbl};
        end
        ret=isempty(errInfo);
    end
    function ret=iCheckEventSrcMatchedConnection
        assignmentMeth=taskData.taskEventSourceAssignmentType;
        manual=DAStudio.message('codertarget:utils:ManuallyAssigned');
        expEvtSrc=get_param(connectedEvtSrcBlk,'Name');
        if~isequal(assignmentMeth,manual)&&~isequal(expEvtSrc,curEvtSrc)
            expEvtSrcBlkName=getfullname(connectedEvtSrcBlk);
            errInfo.ID='codertarget:utils:TaskEventSourceBlockInvalid';
            errInfo.Args={taskName,curEvtSrc,expEvtSrc,expEvtSrcBlkName,btnLbl};
        end
        ret=isempty(errInfo);
    end
    function ret=iCheckEventSrcUnique
        if ismember(curEvtSrc,usedEvtSrcs)
            errInfo.ID='codertarget:utils:TaskEventSourceNotUnique';
            errInfo.Args={curEvtSrc,taskName};
        end
        ret=isempty(errInfo);
    end
    function ret=iCheckEventNotInternal
        internal=DAStudio.message('codertarget:utils:InternalEvent');
        if isequal(curEvtSrc,internal)
            errInfo.ID='codertarget:utils:TaskEventSourceInternal';
            errInfo.Args={taskName};
        end
        ret=isempty(errInfo);
    end
end
