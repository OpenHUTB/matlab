classdef SignalDetector<matlab.DiscreteEventSystem




    properties
        edge=uint8(1);
        threshold=0;
        id=uint32(0);
    end
    properties(DiscreteState)

        value;
    end

    methods
        function valid=isEdgeEvent(obj,edge,threshold,newValue)

            valid=false;
            if edge==1||edge==3
                valid=obj.value+threshold<0&&newValue+threshold>=0;
            end
            if~valid&&(edge==2||edge==3)
                valid=obj.value+threshold>0&&newValue+threshold<=0;
            end
        end
    end


    methods

        function[entity,events]=SignalEventGenerate(obj,~,entity,tag)


            entity.data(1)=str2double(tag);
            entity.data(2)=obj.getCurrentTime();
            events=obj.eventForward('output',1,0);
        end
    end

    methods(Access=protected)

        function entityTypes=getEntityTypesImpl(obj)
            entityTypes=[obj.entityType('SignalEvent','double',2),...
            obj.entityType('Stimulus')];
        end

        function[inputTypes,outputTypes]=getEntityPortsImpl(~)



            inputTypes={'Stimulus'};
            outputTypes={'SignalEvent'};
        end

        function resetImpl(obj)

            obj.value=0;
        end

        function[storageSpecs,I,O]=getEntityStorageImpl(obj)
            storageSpecs=[obj.queueFIFO('SignalEvent',length(obj.edge)),...
            obj.queueFIFO('Stimulus',1)];
            I=2;
            O=1;
        end

        function[entity,events]=StimulusEntry(obj,~,entity,~)
            events=obj.eventDestroy();


            evId=2;
            for i=1:length(obj.edge)
                valid=obj.isEdgeEvent(obj.edge(i),obj.threshold(i),double(entity.data));
                if valid
                    events(evId)=obj.eventGenerate(1,char(string(obj.id(i))),0,10);
                end
            end
            obj.value=double(entity.data);
        end

        function num=getNumInputsImpl(~)


            num=1;
        end

        function num=getNumOutputsImpl(~)

            num=1;
        end
        function out1=getOutputSizeImpl(~)

            out1=2;
        end

        function out1=getOutputDataTypeImpl(~)

            out1="double";
        end

        function out1=isOutputComplexImpl(~)

            out1=false;
        end

        function[sz,dt,cp]=getDiscreteStateSpecificationImpl(~,name)


            switch name
            case 'value'
                sz=[1,1];
            end
            dt="double";
            cp=false;
        end
    end
end
