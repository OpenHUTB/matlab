classdef SimMemStore




    methods(Static=true)


        function v=registerMem(simMem)
            import dnnfpga.interact.*

            memMap=SimMemStore.getMemMap();

            key=strcat(simMem.Model,'_',num2str(uint32(simMem.Id)));

            workSpace=get_param(simMem.Model,'ModelWorkspace');
            try
                stamp=evalin(workSpace,'modelInit');
            catch

                SimMemStore.clearFromModel(simMem.Model);
                assignin(workSpace,'modelInit',now);
            end
            if isKey(memMap,key)
                current=memMap(key);
                if strcmp(current.Path,simMem.Path)

                    delete(current.SystemObject);
                    memMap(key)=simMem;
                else
                    fprintf("SimMems in blocks '%s' and '%s' both have the same ID: %u.",current.Path,simMem.Path,uint32(simMem.Id));
                end
            else
                memMap(key)=simMem;
            end
        end


        function v=getMem(modelName,id,noError)

            import dnnfpga.interact.*

            if nargin<3
                noError=false;
            end

            memMap=SimMemStore.getMemMap();

            key=strcat(modelName,'_',num2str(uint32(id)));

            if isKey(memMap,key)
                v=memMap(key);
                if~v.isValid()
                    if noError
                        v={};
                    else
                        error(sprintf("There is no valid SimMem block in the model '%s' with id %u.\n",modelName,uint32(id)));
                    end
                else
                    v=copy(memMap(key));
                end
            else
                if noError
                    v={};
                else
                    error(sprintf("In model '%s': Unable to locate a SimMem block with id %u.\n",modelName,uint32(id)));
                end
            end
        end

        function so=getSystemObject(modelName,id)
            import dnnfpga.interact.*
            so={};
            mem=SimMemStore.getMem(modelName,id,true);
            if~isempty(mem)
                so=mem.SystemObject;
            end
        end


        function v=clear(onlyInvalid)
            import dnnfpga.interact.*

            memMap=SimMemStore.getMemMap();

            if nargin==0
                onlyInvalid=false;
            end

            keys=memMap.keys;
            for i=1:numel(keys)
                key=keys{i};
                simMem=memMap(key);
                if~onlyInvalid||~simMem.isValid()
                    state=simMem.SystemObject;
                    remove(memMap,key);

                    if isvalid(state)
                        delete(state);
                    end
                    delete(simMem);
                end
            end
        end


        function clearFromModel(modelName)
            import dnnfpga.interact.*

            memMap=SimMemStore.getMemMap();

            keys=memMap.keys;
            for i=1:numel(keys)
                key=keys{i};
                simMem=memMap(key);
                if~isnumeric(simMem)&&strcmp(simMem.Model,modelName)
                    state=simMem.SystemObject;
                    remove(memMap,key);

                    if isvalid(state)
                        delete(state);
                    end
                    delete(simMem);
                end
            end
        end


        function displayMemInfo()
            import dnnfpga.interact.*

            memMap=SimMemStore.getMemMap();
            keys=memMap.keys;
            first=true;
            for i=1:numel(keys)
                if first
                    first=false;
                    fprintf("Summary of Registered SimMems:\n\n");
                end
                key=keys{i};
                simMem=memMap(key);
                try
                    sz=simMem.Size;
                catch
                    sz=2^simMem.AddrSize;
                end
                fprintf("SimMem: '%s'\n",simMem.Path);
                fprintf("       class: '%s'\n",class(simMem));
                fprintf("          id: %u\n",simMem.Id);
                fprintf("        size: %u\n",sz);
                fprintf("        type: %s\n\n",class(simMem.ZeroData));
            end
        end


        function memMap=getMemMap()
            persistent mMap

            if isempty(mMap)
                mMap=containers.Map('KeyType','char','ValueType','Any');

                mMap('ignore')=uint32(0);
            end
            memMap=mMap;
        end
    end
end


