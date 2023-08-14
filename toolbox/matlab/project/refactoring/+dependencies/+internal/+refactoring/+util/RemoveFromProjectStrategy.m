classdef RemoveFromProjectStrategy<dependencies.internal.refactoring.util.RemoveStrategy




    properties
        Title=i_getText("RemoveTitle");
        UpdateButtonName=i_getText("ButtonRemoveAndUpdate");
        SkipButtonName=i_getText("ButtonRemove");
    end

    methods
        function[msg,details]=getDescription(~,numberOfFiles)
            if numberOfFiles==1
                suffix="Single";
            else
                suffix="Multi";
            end
            boldCount="<b>"+string(numberOfFiles)+"</b>";
            msg=i_getText("RemoveRefactoringMessage"+suffix,boldCount);
            details=i_getText("RemoveRefactoringDetails"+suffix);
        end

        function[msg,details]=getSuccess(~)
            msg=i_getText("RemoveMessageSuccess");
            details="";
        end

        function[msg,details]=getIncomplete(~)
            msg=i_getText("RemoveMessageIncomplete");
            details=i_getText("RemoveDetailsIncomplete");
        end

        function[msg,details]=getError(~)
            msg=i_getText("RemoveMessageError");
            details="";
        end
    end
end

function text=i_getText(keyAppendix,varargin)
    resourceKey="MATLAB:project:refactoring:"+keyAppendix;
    text=string(message(resourceKey,varargin{:}));
end
