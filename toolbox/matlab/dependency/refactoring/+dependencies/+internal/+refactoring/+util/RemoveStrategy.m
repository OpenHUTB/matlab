classdef(Abstract)RemoveStrategy





    properties(Abstract)
        Title(1,1)string;
        UpdateButtonName(1,1)string;
        SkipButtonName(1,1)string;
    end

    methods(Abstract)
        [msg,details]=getDescription(this,numberOfFiles);
        [msg,details]=getSuccess(this);
        [msg,details]=getIncomplete(this);
        [msg,details]=getError(this);
    end
end
