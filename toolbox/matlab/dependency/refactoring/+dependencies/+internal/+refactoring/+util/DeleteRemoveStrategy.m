classdef DeleteRemoveStrategy<dependencies.internal.refactoring.util.RemoveStrategy




    properties
        Title=i_getText("DeleteTitle");
        UpdateButtonName=i_getText("ButtonDeleteAndUpdate");
        SkipButtonName=i_getText("ButtonDelete");
    end

    methods
        function[msg,details]=getDescription(~,numberOfFiles)
            if numberOfFiles==1
                suffix="Single";
            else
                suffix="Multi";
            end
            boldCount="<b>"+string(numberOfFiles)+"</b>";
            msg=i_getText("DeleteRefactoringMessage"+suffix,boldCount);
            details=i_getText("DeleteRefactoringDetails"+suffix);
        end

        function[msg,details]=getSuccess(~)
            msg=i_getText("DeleteMessageSuccess");
            details="";
        end

        function[msg,details]=getIncomplete(~)
            msg=i_getText("DeleteMessageIncomplete");
            details=i_getText("DeleteDetailsIncomplete");
        end

        function[msg,details]=getError(~)
            msg=i_getText("DeleteMessageError");
            details="";
        end
    end
end

function text=i_getText(keyAppendix,varargin)
    resourceKey="MATLAB:dependency:refactoring:"+keyAppendix;
    text=string(message(resourceKey,varargin{:}));
end
