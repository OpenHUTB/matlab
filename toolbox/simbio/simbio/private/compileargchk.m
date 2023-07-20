function[cs,variants,doses]=compileargchk(mobj,varargin)











    try
        narginchk(1,4);

        if~isscalar(mobj)||~isa(mobj,'SimBiology.Model')
            validateattributes(mobj,{'SimBiology.Model'},{'scalar'},'','MOBJ',1);
        end



        cs=SimBiology.Configset.empty();

        numVarargin=numel(varargin);
        if numVarargin==1




            if~isempty(varargin{1})
                if isa(varargin{1},'SimBiology.Configset')
                    cs=varargin{1};
                elseif isa(varargin{1},'SimBiology.Variant')
                    variants=varargin{1};
                elseif isa(varargin{1},'SimBiology.Dose')
                    doses=varargin{1};
                else
                    validateattributes(varargin{1},{'SimBiology.Configset','SimBiology.Variant','SimBiology.Dose'},{},'','',2);
                end
            end
        elseif numVarargin==2



            if~isempty(varargin{1})
                cs=varargin{1};
                if~isa(cs,'SimBiology.Configset')
                    validateattributes(cs,{'SimBiology.Configset'},{},'','CSOBJ',2);
                end
            end
            if isempty(varargin{2})
                variants=SimBiology.Variant.empty(0,1);
            else
                arg=varargin{2};
                if isa(arg,'SimBiology.Variant')
                    variants=arg;
                elseif isa(arg,'SimBiology.Dose')
                    doses=arg;
                else
                    validateattributes(arg,{'SimBiology.Variant','SimBiology.Dose'},{},'','',3);
                end
            end
        elseif numVarargin==3

            if~isempty(varargin{1})
                cs=varargin{1};
                if~isa(cs,'SimBiology.Configset')
                    validateattributes(cs,{'SimBiology.Configset'},{},'','CSOBJ',2);
                end
            end
            if isempty(varargin{2})
                variants=SimBiology.Variant.empty(0,1);
            else
                variants=varargin{2};
                if~isa(variants,'SimBiology.Variant')
                    validateattributes(variants,{'SimBiology.Variant'},{},'','VOBJ',3);
                end
            end
            if isempty(varargin{3})
                doses=SimBiology.Dose.empty(0,1);
            else
                doses=varargin{3};
                if~isa(doses,'SimBiology.Dose')
                    validateattributes(doses,{'SimBiology.Dose'},{},'','DOBJ',4);
                end
            end
        end

        if isempty(cs)
            cs=mobj.getconfigset('active');
        end

        if isempty(cs)
            cs=mobj.addconfigset('default',true);
        end

        if~isscalar(cs)
            validateattributes(cs,{'SimBiology.Configset'},{'scalar'},'','CSOBJ',2);
        end

        if~any(cs==getconfigset(mobj))
            error(message('SimBiology:Compilation:ConfigsetNotAttached'));
        end


        if~exist('variants','var')
            if isempty(mobj.Variants)
                variants=SimBiology.Variant.empty(0,1);
            else
                variants=findobj(mobj.Variants,'Active',true);
            end
        end


        if~exist('doses','var')
            if isempty(mobj.getdose)
                doses=SimBiology.Dose.empty(0,1);
            else
                doses=findobj(mobj.getdose,'Active',true);
            end
        end



        if~isempty(doses)&&~isa(cs.SolverOptions,'SimBiology.ODESolverOptions')





            cs.SolverType='ode15s';

            localWarning(message('SimBiology:Compilation:InvalidSolverDoses',cs.SolverType));
        end


        if(isa(cs.SolverOptions,'SimBiology.ImplicitTauSolverOptions')||...
            isa(cs.SolverOptions,'SimBiology.ExplicitTauSolverOptions'))&&...
            (~isempty(mobj.Events)&&~isempty(findobj(mobj.Events,'Active',true)))
            localWarning(message('SimBiology:Compilation:InvalidSolverEvents'));
            cs.SolverType='ssa';
        end
    catch exception
        throwAsCaller(exception);
    end
end

function[]=localWarning(messageObj)
    msgStruct=struct("component",[],...
    "source",'Task',...
    "message",getString(messageObj),...
    "messageID",messageObj.Identifier,...
    "isError",false);
    SimBiology.web.eventhandler('message',msgStruct);
    warning(messageObj);
end
