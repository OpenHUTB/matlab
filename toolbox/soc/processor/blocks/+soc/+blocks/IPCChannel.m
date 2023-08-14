classdef IPCChannel<matlab.DiscreteEventSystem



    properties
    end

    properties(Nontunable)
        Capacity=2;
    end

    properties(Access=private)
        NumElementsIn=0;
        OutportDataIdx=1;
        OutportDropIdx=4;
        OutportLevlIdx=3;
        OutportTrigIdx=2;
        StorageDataIdx=1;
        StorageTrigIdx=2;
    end

    methods(Access=protected)
        function num=getNumInputsImpl(~)
            num=1;
        end
        function num=getNumOutputsImpl(~)
            num=4;
        end
        function entityTypes=getEntityTypesImpl(obj)
            entityTypes=obj.entityType('SoCMsg');
        end
        function[inpTypes,outTypes]=getEntityPortsImpl(obj)%#ok<MANU> 
            inpTypes={'SoCMsg'};
            outTypes={'SoCMsg','SoCMsg','','SoCMsg'};
        end
        function[storageSpecs,I,O]=getEntityStorageImpl(obj)
            storageSpecs=[obj.queueFIFO('SoCMsg',obj.Capacity+1)...
            ,obj.queueFIFO('SoCMsg',8)];
            I=obj.StorageDataIdx;
            O={obj.StorageDataIdx,obj.StorageTrigIdx,0,obj.StorageDataIdx};
        end
    end

    methods
        function[entity,event,lvlOut]=SoCMsgEntry(obj,storage,entity,~)
            event=[];
            if isequal(obj.NumElementsIn,obj.Capacity)

                event=[event,obj.eventIterate(storage,'',0)];
            else
                obj.NumElementsIn=obj.NumElementsIn+1;
            end
            event=[event,obj.eventForward('output',obj.OutportDataIdx,0)];
            event=[event,obj.eventGenerate(obj.StorageTrigIdx,'trig',0,1);];
            lvlOut=obj.NumElementsIn;
        end

        function[event,lvlOut]=SoCMsgExit(obj,~,~,src)
            event=[];
            if isequal(src.index,1)
                obj.NumElementsIn=obj.NumElementsIn-1;
            end
            lvlOut=obj.NumElementsIn;
        end

        function[entity,events,next,lvlOut]=SoCMsgIterate(obj,storage,...
            entity,tag,position)%#ok<INUSL,INUSD> 
            events=obj.eventForward('output',obj.OutportDropIdx,0);
            next=false;
            lvlOut=obj.NumElementsIn;
        end
    end

    methods
        function[entity,event,lvlOut]=generate(obj,~,entity,~)
            lvlOut=obj.NumElementsIn;
            event=obj.eventForward('output',obj.OutportTrigIdx,0);
        end
    end
end