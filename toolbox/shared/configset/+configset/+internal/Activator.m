classdef Activator<handle























    properties
        Restore(1,1)logical=true
        ParamValuePairs(1,:)cell
    end

    properties(Access=private)
OrigConfigSetName
AltConfigSetName
AltConfigSet
ModelsToClose
HonoredParams
    end

    methods
        function obj=Activator(paramValuePairs,altConfigSet,honoredParams)

            narginchk(1,3);
            obj.ParamValuePairs=paramValuePairs;
            obj.OrigConfigSetName=containers.Map('KeyType','char','ValueType','char');
            obj.AltConfigSetName=containers.Map('KeyType','char','ValueType','char');
            obj.ModelsToClose={};
            if nargin>=2
                obj.AltConfigSet=altConfigSet;
            end
            if nargin>=3
                obj.HonoredParams=honoredParams;
            end
        end

        function out=activate(obj,model)





















            narginchk(2,3);
            model=get_param(model,'Handle');

            paramValuePairs=obj.ParamValuePairs;



            if~isempty(obj.AltConfigSet)&&...
                ~obj.isConfigSetMatched(obj.AltConfigSet,paramValuePairs)
                throw(MSLException([],message('configset:util:InvalidAltConfigSet')));
            end

            origConfigSet=getActiveConfigSet(model);
            if isempty(paramValuePairs)||...
                ~obj.isConfigSetMatched(origConfigSet,paramValuePairs)
                configSet=obj.findConfigSet(model,paramValuePairs);
                preserveDirtyFlag=Simulink.PreserveDirtyFlag(model,'blockDiagram');
                if~isempty(configSet)

                    configSet.activate;
                elseif~isempty(obj.AltConfigSet)

                    if obj.AltConfigSet==origConfigSet||...
                        isKey(obj.AltConfigSetName,get_param(model,'Name'))

                        out=true;
                        return
                    end
                    configSet=attachConfigSetCopy(model,obj.AltConfigSet,true);
                    obj.massage(configSet,origConfigSet);
                    configSet.activate;
                    obj.AltConfigSetName(get_param(model,'Name'))=configSet.Name;
                else
                    out=false;
                    return
                end
                if~isKey(obj.OrigConfigSetName,get_param(model,'Name'))
                    obj.OrigConfigSetName(get_param(model,'Name'))=origConfigSet.Name;
                end
                delete(preserveDirtyFlag);
            end
            out=true;
        end

        function loadModel(obj,model)


            load_system(model);
            obj.ModelsToClose{end+1}=model;
        end

        function delete(obj)

            model=obj.OrigConfigSetName.keys;
            if obj.Restore


                cellfun(@(x)close_system(x,0),obj.ModelsToClose);


                for k=1:length(model)
                    obj.restore(model{k});
                end
            else



                for k=1:length(model)
                    obj.release(model{k});
                end
            end
        end
    end

    methods(Access=private)
        function out=isConfigSetMatched(~,configSet,paramValuePairs)

            if isempty(paramValuePairs)
                out=true;
            else
                out=isequal(get_param(configSet,paramValuePairs{1}),paramValuePairs{2});
            end
        end

        function out=findConfigSet(obj,model,paramValuePairs)

            if~isempty(paramValuePairs)
                name=getConfigSets(model);
                for k=1:length(name)


                    configSet=getConfigSet(model,name{k});
                    if obj.isConfigSetMatched(configSet,paramValuePairs)
                        out=configSet;
                        return
                    end
                end
            end
            out=[];
        end

        function massage(obj,configSet,origConfigSet)
            for k=1:length(obj.HonoredParams)
                param=obj.HonoredParams{k};
                set_param(configSet,param,...
                get_param(origConfigSet,param));
            end
        end

        function restore(obj,model)

            if bdIsLoaded(model)
                preserveDirtyFlag=Simulink.PreserveDirtyFlag(model,'blockDiagram');
                configSet=getActiveConfigSet(model);
                if~strcmp(configSet.Name,obj.OrigConfigSetName(model))
                    setActiveConfigSet(model,obj.OrigConfigSetName(model));
                    if isKey(obj.AltConfigSetName,model)
                        detachConfigSet(model,obj.AltConfigSetName(model));
                    end
                end
                delete(preserveDirtyFlag);
            end
        end

        function release(obj,model)

            if bdIsLoaded(model)&&...
                ~strcmp(get_param(getActiveConfigSet(model),'Name'),...
                obj.OrigConfigSetName(model))
                set_param(model,'Dirty','on');
            end
        end
    end
end


