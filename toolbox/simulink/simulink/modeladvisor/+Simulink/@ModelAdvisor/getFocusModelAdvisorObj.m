function activeObj=getFocusModelAdvisorObj(varargin)




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
    end
