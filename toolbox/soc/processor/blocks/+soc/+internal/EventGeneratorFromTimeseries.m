classdef EventGeneratorFromTimeseries<matlab.DiscreteEventSystem




    properties(Nontunable)
        ObjectName='';
        TopBlockType='IO Data Source';
        DataTypeStr='';
        SamplingRate=1;
    end

    properties(DiscreteState)
        Priority;
        Value;
    end

    properties(Access=private)
        TimeseriesTime=[];
        TimeseriesDataInitialized=false;
    end

    properties
        TimeStampCounter=1;
    end

    methods
        function events=setupEvents(obj)
            setupTimeseriesObject(obj);
            events=obj.eventGenerate(1,'Eventgen',obj.TimeseriesTime(1),obj.Priority);
        end
        function[entity,events]=generate(obj,~,entity,~)

            entity.data=obj.Value;
            entity.val=obj.Value;
            obj.TimeStampCounter=obj.TimeStampCounter+1;
            isLastTimeStamp=isequal(obj.TimeStampCounter,(numel(obj.TimeseriesTime)+1));
            if isLastTimeStamp
                events=obj.eventForward('output',1,0);
            else
                events=[obj.eventForward('output',1,0)...
                ,obj.eventGenerate(1,'Eventgen',...
                obj.TimeseriesTime(obj.TimeStampCounter)-obj.TimeseriesTime(obj.TimeStampCounter-1),...
                obj.Priority)];
            end
        end
    end


    methods(Hidden,Access=protected)
        function setupTimeseriesObject(obj)
            if~obj.TimeseriesDataInitialized
                tsObj=soc.internal.getTimeseriesObject(obj.ObjectName,...
                obj.TopBlockType);
                obj.TimeseriesTime=tsObj.Time;
                obj.TimeseriesDataInitialized=true;
            end
        end
    end

    methods(Access=protected)
        function entityTypes=getEntityTypesImpl(obj)
            entityTypes=obj.entityType('EntityGen');
        end
        function[inputTypes,outputTypes]=getEntityPortsImpl(~)



            inputTypes={};
            outputTypes={'EntityGen'};
        end
        function resetImpl(obj)

            obj.Priority=1;
            obj.Value=1;
        end
        function[storageSpecs,I,O]=getEntityStorageImpl(obj)
            storageSpecs=obj.queueFIFO('EntityGen',1);
            I=[];
            O=1;
        end
        function num=getNumInputsImpl(~)

            num=0;
        end
        function out=getOutputSizeImpl(~)

            out=[1,1];
        end
        function out=getOutputDataTypeImpl(~)

            out="double";
        end
        function out=isOutputComplexImpl(~)

            out=false;
        end
        function[sz,dt,cp]=getDiscreteStateSpecificationImpl(~,name)

            switch name
            case 'Priority'
                sz=[1,1];
            case 'Value'
                sz=[1,1];
            end
            dt="double";
            cp=false;
        end
    end
end