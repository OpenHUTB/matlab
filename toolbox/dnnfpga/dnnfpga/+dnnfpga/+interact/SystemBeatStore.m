



classdef SystemBeatStore

    methods(Static=true)


        function v=registerSystemBeat(systemBeat)
            import dnnfpga.interact.*

            sbMap=SystemBeatStore.getMap();

            key=systemBeat.ModelName;

            sbMap(key)=systemBeat;
        end

        function v=getSystemBeat(modelName)

            import dnnfpga.interact.*

            sbMap=SystemBeatStore.getMap();

            v={};
            if isKey(sbMap,modelName)
                v=sbMap(modelName);
            end
        end

        function sbMap=getMap()
            persistent mMap

            if isempty(mMap)
                mMap=containers.Map('KeyType','char','ValueType','Any');

                mMap('ignore')=uint32(0);
            end
            sbMap=mMap;
        end
    end
end
