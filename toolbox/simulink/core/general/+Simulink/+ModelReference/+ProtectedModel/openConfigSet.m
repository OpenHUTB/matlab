function out=openConfigSet(model,paramName,varargin)











    persistent cs

    cs=Simulink.ModelReference.ProtectedModel.getConfigSet(model,varargin{:});
    cs.view;
    if nargin>1&&~isempty(paramName)
        configset.highlightParameter(cs,paramName);
    end

    out=cs.getDialogHandle;
