classdef(ConstructOnLoad)LoadingEventData<event.EventData



    properties
Name
Elem
Process
Index
numWaveforms
PRFPRIIndex
    end

    methods
        function data=LoadingEventData(name,elem,process,waveforms,index,prfIndex)
            data.Name=name;
            data.Elem=elem;
            data.Process=process;
            data.numWaveforms=waveforms;
            if nargin==5
                data.Index=index;
            end
            if nargin==6
                data.PRFPRIIndex=prfIndex;
            end
        end
    end
end
