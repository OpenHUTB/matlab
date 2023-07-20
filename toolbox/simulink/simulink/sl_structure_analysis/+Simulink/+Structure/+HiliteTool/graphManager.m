classdef graphManager<handle






    properties(SetAccess=private,GetAccess=public)


graphMap
    end


    methods(Access=private)


        function obj=graphManager
            obj.graphMap=containers.Map('KeyType','double','ValueType','any');
        end

    end


    methods(Static,Hidden=true,Access={?Simulink.Structure.HiliteTool.graphManager,...
        ?Simulink.Structure.HiliteTool.HiliteTree,...
        ?Simulink.Structure.HiliteTool.tracer,...
        ?Simulink.Structure.HiliteTool.AppManager})



        function obj=getGraphManager

            persistent graphManagerObj

            if(isempty(graphManagerObj)||~isvalid(graphManagerObj))
                obj=Simulink.Structure.HiliteTool.graphManager;
                graphManagerObj=obj;
            else
                obj=graphManagerObj;
            end

        end



        function addToGraphList(Owner,graphHandle)

            assert(strcmpi(get_param(Owner,'type'),'block_diagram'),...
            message('Simulink:HiliteTool:ExpectedBDHandle'));
            assert(strcmpi(class(graphHandle),'double'));

            obj=Simulink.Structure.HiliteTool.graphManager.getGraphManager;
            oldOwner=Simulink.Structure.HiliteTool.graphManager.findOwner(graphHandle);

            if(~isempty(oldOwner)&&oldOwner~=Owner)
                error(message('Simulink:HiliteTool:InvalidOwner'));
            elseif(~isempty(oldOwner)&&oldOwner==Owner)

            else
                if(isKey(obj.graphMap,Owner))
                    obj.graphMap(Owner)=[obj.graphMap(Owner),graphHandle];
                else
                    obj.graphMap(Owner)=graphHandle;
                end
            end

        end



        function removeFromMap(Owner,varargin)

            narginchk(1,2);
            obj=Simulink.Structure.HiliteTool.graphManager.getGraphManager;
            if(isvalid(obj))
                if(isKey(obj.graphMap,Owner))
                    if(isempty(varargin))
                        remove(obj.graphMap,Owner);
                    else
                        child=varargin{1};
                        assert(isa(child,'double'));
                        values=obj.graphMap(Owner);
                        ind=ismember(values,child);
                        obj.graphMap(Owner)=values(~ind);
                    end
                end
            end

        end



        function owner=findOwner(graphHandle)

            assert(strcmpi(class(graphHandle),'double'));
            owner=[];
            obj=Simulink.Structure.HiliteTool.graphManager.getGraphManager;

            if(isvalid(obj))
                keys=obj.graphMap.keys;
            end

            if(~isempty(keys)&&iscell(keys))
                keys=cell2mat(keys);
            end

            for i=1:length(keys)
                localList=obj.graphMap(keys(i));
                if(ismember(graphHandle,localList))
                    try
                        owner=get_param(keys(i),'handle');
                        return;
                    catch
                        remove(obj.graphMap,keys(i));
                    end
                end
            end

        end

    end



    methods(Static,Access=public,Hidden=true)



        function reset
            obj=Simulink.Structure.HiliteTool.graphManager.getGraphManager;
            obj.graphMap=containers.Map('KeyType','double','ValueType','any');
        end

    end
end

