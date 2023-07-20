function out=undohandler(action,varargin)











    out=[];

    switch(action)
    case 'undo'
        undo(varargin{:});
    case 'redo'
        redo(varargin{:});
    end

end

function undo(input)



    oldWarningState=warning('off');
    warningStateCleanup=onCleanup(@()warning(oldWarningState));

    model=SimBiology.web.modelhandler('getModelFromSessionID',input.modelSessionID);
    SimBiology.Transaction.undo(model);

end

function redo(input)



    oldWarningState=warning('off');
    warningStateCleanup=onCleanup(@()warning(oldWarningState));

    model=SimBiology.web.modelhandler('getModelFromSessionID',input.modelSessionID);
    SimBiology.Transaction.redo(model);
end
