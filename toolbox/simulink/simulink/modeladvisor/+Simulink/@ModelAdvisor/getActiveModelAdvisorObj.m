function activeObj=getActiveModelAdvisorObj(varargin)




mlock
    persistent mdladvObj;

    if nargin==0
        if~isa(mdladvObj,'Simulink.ModelAdvisor')
            activeObj='';
        else
            activeObj=mdladvObj;
        end
    else
        mdladvObj=varargin{1};
        activeObj=mdladvObj;

        if~isempty(mdladvObj)

            Advisor.Manager.getActiveApplicationObj(mdladvObj.ApplicationID);
        end
    end
