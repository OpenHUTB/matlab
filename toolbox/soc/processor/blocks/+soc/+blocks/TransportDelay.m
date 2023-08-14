classdef TransportDelay<matlab.DiscreteEventSystem



    properties(Nontunable)
        Delay=0;
    end

    properties(Access=private)
        QueueIdx=1
    end

    methods(Access=protected)
        function num=getNumInputsImpl(~)
            num=1;
        end
        function num=getNumOutputsImpl(~)
            num=1;
        end
        function entityTypes=getEntityTypesImpl(obj)
            entityTypes=obj.entityType('SoCMsg');
        end
        function[inpTypes,outTypes]=getEntityPortsImpl(obj)%#ok<MANU> 
            inpTypes={'SoCMsg'};
            outTypes={'SoCMsg'};
        end
        function[storageSpecs,I,O]=getEntityStorageImpl(obj)
            storageSpecs=obj.queueFIFO('SoCMsg',inf);
            I=1;
            O={1};
        end
    end

    methods
        function[entity,event]=SoCMsgEntry(obj,storage,entity,source)%#ok<*INUSL>
            if isequal(source.type,'input')
                event=obj.eventForward('storage',obj.QueueIdx,obj.Delay);
            else
                event=obj.eventForward('output',1,0);
            end
        end
        function[event]=SoCMsgExit(obj,storage,entity,source)%#ok<*INUSD> 
            event=[];
        end
    end
end