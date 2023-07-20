function[solved,u,x]=SolveSteadyState(obj,spec,varargin)























    needToTerm=false;
    needToRestore=false;
    setting='off';
    mdl='';
    solver='Line-Search';
    traceLevel=0;

    try
        mdl=get_param(bdroot(obj),'Name');

        if(~strcmp(get_param(mdl,'BlockDiagramType'),'model'))
            localCleanup(mdl,needToTerm,needToRestore,setting);
            DAStudio.error('Simulink:utility:SlGetLinearizationJacobianPatternNotModel');
        end

        if nargin==3
            solver=varargin{1};
        elseif nargin==4
            solver=varargin{1};
            traceLevel=varargin{2};
        end

        simStatus=get_param(mdl,'SimulationStatus');
        setting=get_param(mdl,'AnalyticLinearization');

        if strcmp(setting,'on')&&strcmp(simStatus,'paused')


            needToTerm=false;
        else
            if~strcmpi(simStatus,'stopped')
                feval(mdl,'term');
            end
            set_param(mdl,'AnalyticLinearization','on');
            needToRestore=true;
            feval(mdl,[],[],[],'lincompile');
            needToTerm=true;
        end

        if traceLevel>0
            [solved,result]=feval(mdl,'steadyState',spec,solver,traceLevel);
        else
            [solved,result]=feval(mdl,'steadyState',spec,solver);
        end

        u=result.u;
        x=result.x;

    catch e
        localCleanup(mdl,needToTerm,needToRestore,setting);
        rethrow(e);
    end

    localCleanup(mdl,needToTerm,needToRestore,setting);

end


function localCleanup(mdl,needToTerm,needToRestore,setting)
    if(needToTerm)
        feval(mdl,'term');
    end

    if(needToRestore)
        set_param(mdl,'AnalyticLinearization',setting);
    end
end