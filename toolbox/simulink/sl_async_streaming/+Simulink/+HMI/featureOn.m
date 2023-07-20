
function res=featureOn(varargin)


    res=struct();

    if nargin==1&&varargin{1}==true
        SLM3I.SLDomain.setSharedWebBrowserDebug(true);
    end


    Simulink.slx.refreshPartHandlers;
end
