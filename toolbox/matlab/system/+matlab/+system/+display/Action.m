classdef(Sealed)Action<handle

























    properties









        ActionCalledFcn;



        Label;



        Description;







        Placement;



        Alignment;
    end

    properties(Hidden,SetAccess=protected)





        DialogAppliedFcn;




        SystemDeletedFcn;









        PropertyResolveErrorFcn=@matlab.system.display.Action.abortOnPropertyResolveError;




        IsEnabledFcn=@matlab.system.display.Action.alwaysEnable;
    end

    methods
        function set.ActionCalledFcn(obj,v)
            if isstring(v)&&isscalar(v)
                v=char(v);
            end
            if~ischar(v)||~isempty(v)
                validateattributes(v,{'char','function_handle'},{},'','ActionCalledFcn');
            end
            obj.ActionCalledFcn=v;
        end

        function set.Label(obj,v)
            if isstring(v)&&isscalar(v)
                v=char(v);
            end
            if~ischar(v)||~isempty(v)
                validateattributes(v,{'char'},{'row'},'','Label')
            end
            obj.Label=v;
        end

        function set.Description(obj,v)
            if isstring(v)&&isscalar(v)
                v=char(v);
            end
            if~ischar(v)||~isempty(v)
                validateattributes(v,{'char'},{'row'},'','Description')
            end
            obj.Description=v;
        end

        function set.Placement(obj,v)
            if isstring(v)&&isscalar(v)
                v=char(v);
            end
            validateattributes(v,{'char'},{'row'},'','Placement')
            obj.Placement=v;
        end

        function set.Alignment(obj,v)
            if isstring(v)&&isscalar(v)
                v=char(v);
            end
            if~ischar(v)||~isrow(v)||~ismember(v,{'left','right'})
                error(message('MATLAB:system:invalidActionAlignment'));
            end
            obj.Alignment=v;
        end

        function obj=Action(callback,varargin)


            p=inputParser;
            p.addParameter('Label','');
            p.addParameter('Description','');
            p.addParameter('Placement','last');
            p.addParameter('Alignment','left');
            p.parse(varargin{:});
            results=p.Results;


            obj.ActionCalledFcn=callback;
            obj.Label=results.Label;
            obj.Description=results.Description;
            obj.Placement=results.Placement;
            obj.Alignment=results.Alignment;
        end
    end

    methods(Hidden)
        function setCallbacks(obj,varargin)


            p=inputParser;
            p.addParameter('DialogAppliedFcn',[]);
            p.addParameter('SystemDeletedFcn',[]);
            p.addParameter('PropertyResolveErrorFcn',[]);
            p.addParameter('IsEnabledFcn',[]);
            p.parse(varargin{:});
            results=p.Results;




            if~ismember('DialogAppliedFcn',p.UsingDefaults)
                obj.DialogAppliedFcn=results.DialogAppliedFcn;
            end
            if~ismember('SystemDeletedFcn',p.UsingDefaults)
                obj.SystemDeletedFcn=results.SystemDeletedFcn;
            end
            if~ismember('PropertyResolveErrorFcn',p.UsingDefaults)
                obj.PropertyResolveErrorFcn=results.PropertyResolveErrorFcn;
            end
            if~ismember('IsEnabledFcn',p.UsingDefaults)
                obj.IsEnabledFcn=results.IsEnabledFcn;
            end
        end
    end

    methods(Static,Hidden)
        function abortOnPropertyResolveError(~,e,~)

            throw(e);
        end

        function isEnabled=alwaysEnable(~)
            isEnabled=true;
        end

        function isEnabled=disableWhileSystemLocked(systemHandle)
            isEnabled=~matlab.system.display.Action.isSystemLocked(systemHandle);
        end

        function isLocked=isSystemLocked(systemHandle)
            if isa(systemHandle,'matlab.System')
                isLocked=systemHandle.isLocked;
            else
                modelHandle=bdroot(systemHandle);
                modelSimStatus=get_param(modelHandle,'SimulationStatus');
                isLocked=~ismember(modelSimStatus,{'stopped','terminating'});
            end
        end
    end
end

