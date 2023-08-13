classdef Simulation3DHandleMap<matlab.System


    properties(Hidden,SetAccess=private)
        loadflag=false;
    end


    methods
        function val=get.loadflag(self)
            val=self.useInitialState();
        end

    end

    methods(Access=private)
        function state=useInitialState(self)
            state=false;
            ModelRoot=get_param(bdroot,'Name');
            if~isempty(ModelRoot)
                activeConfigObj=getActiveConfigSet(ModelRoot);
                initstate=get_param(activeConfigObj,'LoadInitialState');
                fastrestart=get_param(bdroot,'FastRestart');
                if~strcmp(initstate,'on')||strcmp(fastrestart,'on')
                    state=false;
                else
                    state=true;
                end
            end
        end
    end

    methods(Static)

        function h=Sim3dSetGetHandle(key,varargin)
            persistent Sim3dhandleMap;
            if isempty(Sim3dhandleMap)
                Sim3dhandleMap=containers.Map;
            end
            if isempty(varargin)
                if~Sim3dhandleMap.isKey(key)
                    h=[];
                else
                    h=Sim3dhandleMap(key);
                end
            else
                if isempty(varargin{1})
                    if Sim3dhandleMap.isKey(key)
                        Sim3dhandleMap.remove(key);
                    end
                else
                    Sim3dhandleMap(key)=varargin{1};
                end
                h=[];
            end
        end
    end

end