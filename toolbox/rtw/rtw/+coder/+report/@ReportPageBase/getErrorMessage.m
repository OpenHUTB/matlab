function out=getErrorMessage(obj,~)

    out=obj.getMessage('InternalError',obj.getTitle);
end
