function verifyTaskMapButtonCallback(hMask,hDlg)%#ok<INUSD>




    import soc.internal.taskmanager.*

    btnLbl=DAStudio.message('codertarget:utils:TaskMapAutoMapLbl');
    for i=1:numel(hMask.TskMgrBlockHandles)
        tskMgrBlk=hMask.TskMgrBlockHandles(i);
        usedEvtSrcs={};
        tasks=getEventDrivenTaskNames(tskMgrBlk);
        for j=1:numel(tasks)
            taskName=tasks{j};
            connectedEvtSrcBlk=getEventSourceBlockForTask(tskMgrBlk,taskName);
            tskIdx=iGetTaskIndex();
            curEvtSrc=iGetCurEventSource();
            iCheckEventSrcNotEmpty();
            iCheckEventSrcSpecified();
            iCheckEventNotInternal();
            iCheckEventSrcMatchedConnection();
            iCheckEventSrcUnique();
            usedEvtSrcs{end+1}=curEvtSrc;%#ok<AGROW>
        end
    end
    function tskIdx=iGetTaskIndex
        [found,tskIdx]=ismember(taskName,hMask.taskMappingData(:,1));
        assert(found,[taskName,' is not found in the mapping data table']);
    end
    function curEvtSrc=iGetCurEventSource
        evtIdx=hMask.taskMappingData{tskIdx,2}+1;
        curEvtSrc=hMask.eventList{evtIdx};
    end
    function iCheckEventSrcNotEmpty
        if isempty(connectedEvtSrcBlk)
            error(message('codertarget:utils:TaskEventSourceBlockEmpty',taskName))
        end
    end
    function iCheckEventSrcSpecified
        unspecifiedEvtSrc=DAStudio.message('codertarget:utils:UnspecifiedEvent');
        if isequal(curEvtSrc,unspecifiedEvtSrc)
            error(message('codertarget:utils:TaskEventUnspecified',taskName,btnLbl))
        end
    end
    function iCheckEventNotInternal
        internal=DAStudio.message('codertarget:utils:InternalEvent');
        if isequal(curEvtSrc,internal)
            error(message('codertarget:utils:TaskEventSourceInternal',taskName));
        end
    end
    function iCheckEventSrcMatchedConnection
        assignmentMeth=hMask.taskMappingData{tskIdx,3};
        manual=DAStudio.message('codertarget:utils:ManuallyAssigned');
        expEvtSrc=get_param(connectedEvtSrcBlk,'Name');
        if~isequal(assignmentMeth,manual)&&~isequal(expEvtSrc,curEvtSrc)
            error(message('codertarget:utils:TaskEventSourceBlockInvalid',taskName,...
            curEvtSrc,expEvtSrc,getfullname(connectedEvtSrcBlk),btnLbl))
        end
    end
    function iCheckEventSrcUnique
        if ismember(curEvtSrc,usedEvtSrcs)
            error(message('codertarget:utils:TaskEventSourceNotUnique',curEvtSrc,taskName));
        end
    end
end
