classdef EventGenerator<matlab.DiscreteEventSystem





    properties(Nontunable)
        DataSetName='UDP';
        SourceName='Port 25000';
        SamplingRate=1;
    end

    properties(DiscreteState)

        Priority;

        Value;
    end

    properties(Access=private)
Ts
    end

    properties
        TimeStampCounter=1;
    end


    methods

        function events=setupEvents(obj)



            ds=RecordedData(obj.DataSetName);
            dataFile=getDataFile(ds,obj.SourceName);
            FTimeid=fopen(dataFile{1},'r');
            hdrSize=fread(FTimeid,1,'*uint');
            fseek(FTimeid,hdrSize,0);
            ftell(FTimeid);
            while~feof(FTimeid)
                ts=fread(FTimeid,1,'*double');
                if isempty(ts)
                    break;
                end
                obj.Ts(end+1)=ts;
            end
            fclose(FTimeid);

            events=obj.eventGenerate(1,'Eventgen',obj.Ts(1),obj.Priority);
        end

        function[entity,events]=generate(obj,~,entity,~)

            entity.data=obj.Value;
            entity.val=obj.Value;
            obj.TimeStampCounter=obj.TimeStampCounter+1;
            isLastTimeStamp=isequal(obj.TimeStampCounter,(numel(obj.Ts)+1));
            if isLastTimeStamp
                events=obj.eventForward('output',1,0);
            else
                events=[obj.eventForward('output',1,0)...
                ,obj.eventGenerate(1,'Eventgen',obj.Ts(obj.TimeStampCounter)-obj.Ts(obj.TimeStampCounter-1),obj.Priority)];
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