function[arrayOfProps,errMessage,undoProperties]=moveIntoAndOrderSignal(scenarioIDs,sourceID,destID,...
    parentFullName,signalIDOfReference,IS_BEFORE,IS_REPLACE,baseMsg,appInstanceID,varargin)




    arrayOfProps=[];
    errMessage='';

    RE_ORDER_TREE=true;

    if~isempty(varargin)
        RE_ORDER_TREE=varargin{1};
    end

    if~IS_REPLACE
        [arrayOfProps,errMessage,undoProperties]=Simulink.sta.signaltree.moveAndInsertSignal(scenarioIDs,sourceID,destID,...
        parentFullName,baseMsg,appInstanceID,RE_ORDER_TREE);


        if isempty(arrayOfProps)&&~isempty(errMessage)
            return;
        end

    else
        [arrayOfProps,undoProperties]=Simulink.sta.signaltree.moveAndReplaceSignal(scenarioIDs,sourceID,destID,...
        parentFullName,baseMsg,appInstanceID,RE_ORDER_TREE);
    end

    order_arrayOfProps=Simulink.sta.signaltree.orderChildSignal(sourceID,signalIDOfReference,...
    IS_BEFORE,baseMsg,appInstanceID,RE_ORDER_TREE);

    arrayOfProps=[arrayOfProps,order_arrayOfProps];

end

