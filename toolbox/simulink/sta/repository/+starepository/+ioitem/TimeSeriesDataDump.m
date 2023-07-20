classdef TimeSeriesDataDump<starepository.ioitem.DataDump



    properties
    end

    methods


        function[timeDims,sampleDims]=getTimeAndSampleDims(obj)
            timeDims=getTimeDim(obj);
            sampleDims=getSampleDims(obj);

        end


        function timeDims=getTimeDim(obj)

            if obj.Data.IsTimeFirst
                timeDims=1;
            elseif length(obj.Data.Time)==1
                timeDims=[];
            else
                timeDims=ndims(obj.Data.Data);
            end

        end


        function sampleDims=getSampleDims(obj)

            tssize=size(obj.Data.Data);
            if obj.Data.IsTimeFirst
                sampleDims=tssize(2:end);
            elseif length(obj.Data.Time)==1
                sampleDims=tssize;
            else
                sampleDims=tssize(1:end-1);
            end
        end


        function timeAndDataVals=getTimeAndDataVals(obj)
            timeAndDataVals.Time=double(obj.Data.Time);
            timeAndDataVals.Data=obj.Data.Data;
        end


        function rootSource=getRootSource(obj)
            if~isempty(obj.Name)
                rootSource=obj.Name;
            else
                rootSource='';
            end
        end


        function timeSource=getTimeSource(obj)
            timeSource=[obj.Name,'.Time'];
        end


        function sourceOfData=getDataSource(obj)
            sourceOfData=[obj.Name,'.Data'];
        end


        function blockSource=getBlockSource(obj)

            blockSource='';

        end


        function signalLabel=getSignalLabel(obj)
            signalLabel=obj.Name;

            if isempty(signalLabel)
                signalLabel='';
            end
        end


        function modelSource=getModelSource(obj)
            modelSource='';
        end


        function sID=getSID(obj)
            sID='';
        end


        function metaData_struct=getMetaData(obj)

            setFixedPointProperties(obj);
            metaData_struct.DataType=obj.Properties.DataType;
            metaData_struct.SignalType=obj.Properties.SignalType;
            metaData_struct.Dimension=obj.Properties.Dimension;
            metaData_struct.SampleTime=obj.Properties.SampleTime;
            tsDataVals=obj.Data.Data;
            tsTimeVals=obj.Data.Time;

            if~isa(tsDataVals,'string')&&~(~isreal(tsDataVals)&&...
                any(strcmpi(class(tsDataVals),{'int8','int16','int32','uint8','uint16','uint32','int64','uint64'})))
                metaData_struct.Min=min(tsDataVals);
                metaData_struct.Max=max(tsDataVals);
            else
                metaData_struct.Min=[];
                metaData_struct.Max=[];
            end
            metaData_struct.MinTime=min(tsTimeVals);
            metaData_struct.MaxTime=max(tsTimeVals);

            if obj.isEnum
                metaData_struct.EnumName=obj.Properties.DataType;
            end

            if isa(obj,'starepository.ioitem.NDimensionalTimeSeries')
                metaData_struct.FullDimensions=num2str(size(tsDataVals));
            end

            if~isempty(obj.ParentName)
                metaData_struct.ParentName=obj.ParentName;
            else
                metaData_struct.ParentName='';
            end

            metaData_struct.FullName=getFullName(obj);

            if obj.isFixDTOverride
                if~isempty(obj.overrideType)

                    metaData_struct.FixDTOverrideType=obj.overrideType;
                else

                    metaData_struct.FixDTOverrideType='';
                end
            end

            dataFormatStr='';

            if obj.isDataSetElement
                dataFormatStr='datasetElement:';


                metaData_struct.datasetElementIndex=['datasetElementIndex:',num2str(obj.DataSetIdx)];

                dsElName=obj.Name;
                if isempty(obj.Name)&&~ischar(obj.Name)
                    dsElName='';
                end
                metaData_struct.datasetElementName=['datasetElementName:',dsElName];

                metaData_struct.FileName=obj.FileName;
            end



            if isa(obj.Data,'Simulink.Timeseries')

                if isa(obj,'starepository.ioitem.NDimensionalTimeSeries')
                    dataFormatStr=[dataFormatStr,'simulinkndimtimeseries'];
                else
                    dataFormatStr=[dataFormatStr,'simulinktimeseries'];
                end

                metaData_struct.dataformat=dataFormatStr;
                metaData_struct.signalBlockPath=obj.Data.BlockPath;


                if~isempty(obj.Data.PortIndex)
                    metaData_struct.signalPortIndex=obj.Data.PortIndex;
                else
                    metaData_struct.signalPortIndex='';
                end

                metaData_struct.signalSignalName=obj.Data.SignalName;
                metaData_struct.signalParentName=obj.Data.ParentName;

                if isempty(obj.Data.Name)
                    obj.Data.Name='';
                end
                metaData_struct.Name=obj.Data.Name;
                metaData_struct.TSName=obj.Data.Name;

            elseif obj.isLogged

                if isa(obj,'starepository.ioitem.NDimensionalTimeSeries')
                    dataFormatStr=[dataFormatStr,'loggedsignal:ndimtimeseries'];
                else



                    dataFormatStr=[dataFormatStr,'loggedsignal:timeseries'];
                end


                metaData_struct.dataformat=dataFormatStr;

                if isempty(obj.Data.Name)
                    obj.Data.Name='';
                end

                metaData_struct.TSName=obj.Data.Name;
                metaData_struct.Name=obj.Name;
                metaData_struct.BlockPathLength=length(obj.BlockPath);

                if~isempty(obj.BlockPath)
                    metaData_struct.BlockPath=obj.BlockPath{1};
                    metaData_struct.BlockPathType=obj.BlockPathType;
                end

                for id=2:length(obj.BlockPath)
                    metaData_struct.(sprintf('BlockPath%d',id))=obj.BlockPath{id};
                end

                metaData_struct.SubPath=obj.SubPath;



                metaData_struct.BlockDataProperties=obj.BlockDataProperties;








            elseif isa(obj.Data,'timeseries')&&(~obj.isDataArrayColumn&&~obj.isStructSignal)

                if isa(obj,'starepository.ioitem.NDimensionalTimeSeries')
                    dataFormatStr=[dataFormatStr,'ndimtimeseries'];
                else
                    dataFormatStr=[dataFormatStr,'timeseries'];
                end

                metaData_struct.dataformat=dataFormatStr;


                if isempty(obj.Data.Name)
                    obj.Data.Name='';
                end

                metaData_struct.Name=obj.Data.Name;
                metaData_struct.TSName=obj.Data.Name;

            elseif obj.isStructSignal
                metaData_struct.BlockName=obj.BlockName;

                if isempty(obj.Name)
                    obj.Name='';
                end

                metaData_struct.label=obj.Name;

                if isa(obj,'starepository.ioitem.Signal')
                    metaData_struct.dataformat=['structElementIndex:',num2str(obj.OnFileIndex)];
                elseif isa(obj,'starepository.ioitem.MultiDimensionalTimeSeries')
                    metaData_struct.dataformat=['structElementIndexmultidimtimeseries:',num2str(obj.OnFileIndex)];
                end
            elseif obj.isDataArrayColumn
                metaData_struct.SignalName=obj.Name;
                metaData_struct.dataformat=['dataarray:col',num2str(obj.DataArrayColNum)];
            end


            if ischar(obj.Data.DataInfo.Units)
                metaData_struct.UnitsIsObject=false;

            elseif isa(obj.Data.DataInfo.Units,'Simulink.SimulationData.Unit')
                metaData_struct.UnitsIsObject=true;

            end


            if obj.isFixDT

                metaData_struct=appendFiDataToMetaDataStructImpl(obj,tsDataVals,metaData_struct);

            end

            metaData_struct.ParentID=obj.RepoParentID;
            metaData_struct.FileName=obj.FileName;
            metaData_struct.LastKnownFullFile=obj.LastKnownFullFile;
            metaData_struct.LastModifiedDate=obj.FileModifiedDate;
            metaData_struct.isEnum=obj.isEnum;
            metaData_struct.isString=obj.isString;
        end


        function interpMethod=getInterpolation(obj)

            if(obj.isEnum)||(obj.isBool)||(obj.isString)

                interpMethod='zoh';

            else

                if isa(obj.Data,'timeseries')
                    interpMethod=obj.Data.getinterpmethod;

                elseif isa(obj.Data,'Simulink.Timeseries')
                    interpMethod=obj.Data.getInterpMethod;
                end

                if(strcmp(interpMethod,''))

                    interpMethod='linear';
                end

            end

        end


        function unitStr=getUnit(obj)
            unitStr=getUnits(obj,obj.Data.DataInfo.Units);
        end


        function timeMetaMode=getTimeMetadataMode(~)
            timeMetaMode='';
        end


        function hierRef=getHierarchyReference(~)
            hierRef='';
        end


        function ret=getSampleTimeString(obj)
            ret='';
            if~strcmpi(getInterpolation(obj),'zoh')
                ret=message('simulation_data_repository:sdr:ContinuousSampleTime').getString();
            elseif ismethod(obj.Data.TimeInfo,'isUniform')&&obj.Data.TimeInfo.isUniform
                ret=num2str(obj.Data.TimeInfo.Increment);
            end
        end

    end

end

