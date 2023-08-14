classdef MultiDimensionalTimeSeries<starepository.ioitem.Container&starepository.ioitem.DataSetChild



    properties

        isLogged=false;
BlockPath
BlockPathType
SubPath
PortType
PortIndex
LoggedName
SignalName
SLParentName
        isSLTimeseries=false;
        TSName='';
        TimeseriesName='';
        TSUnits='';
        Interpolation='';
        isDataArrayColumn=0;
    end

    methods
        function obj=MultiDimensionalTimeSeries(ListItems,BusName)
            obj=obj@starepository.ioitem.Container(ListItems,BusName);

            if~isempty(obj.ListItems)
                tsDataVals=obj.ListItems{1}.Data.Data;
                obj.isEnum=isenum(tsDataVals);
                obj.isBool=islogical(tsDataVals);
                obj.isString=isstring(tsDataVals);
            end
        end


        function itemstruct=ioitem2Structure(obj)


            if~isempty(obj.ListItems)
                tsDataVals=obj.ListItems{1}.Data.Data;
                obj.isEnum=isenum(tsDataVals);
                obj.isBool=islogical(tsDataVals);
                obj.isString=isstring(tsDataVals);
                setFixedPointProperties(obj);
            end

            itemstruct=ioitem2Structure@starepository.ioitem.Item(obj);



            if~isempty(obj.TSUnits)
                outStr=getUnits(obj,obj.TSUnits);
                itemstruct{1}.Units=outStr;

            else

                itemstruct{1}.Units='';
            end

            interpolation='';
            if(obj.isEnum)||(obj.isBool)||(obj.isString)

                interpolation='zoh';

            else

                if~isempty(obj.ListItems)
                    if isa(obj.ListItems{1}.Data,'timeseries')
                        interpolation=obj.ListItems{1}.Data.getinterpmethod;

                    elseif isa(obj.ListItems{1}.Data,'Simulink.Timeseries')
                        interpolation=obj.ListItems{1}.Data.getInterpMethod;
                    end
                end

                if(strcmp(interpolation,''))

                    interpolation='linear';
                end

            end
            itemstruct{1}.isEnum=obj.isEnum;
            itemstruct{1}.isString=obj.isString;
            itemstruct{1}.DataType=obj.Properties.DataType;
            itemstruct{1}.Interpolation=interpolation;
            itemstruct{1}.TreeOrder=1;
            obj.Interpolation=interpolation;

        end


        function metaData_struct=getMetaData(obj)

            metaData_struct.DataType=obj.Properties.DataType;
            metaData_struct.SignalType=obj.Properties.SignalType;
            metaData_struct.Dimension=obj.Properties.Dimension;
            metaData_struct.SampleTime=obj.Properties.SampleTime;
            metaData_struct.Min=obj.Properties.Min;
            metaData_struct.Max=obj.Properties.Max;

            if obj.isEnum
                metaData_struct.EnumName=obj.Properties.DataType;
            end

            if~isempty(obj.ParentName)
                metaData_struct.ParentName=obj.ParentName;
            else
                metaData_struct.ParentName='';
            end

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



            if obj.isSLTimeseries
                dataFormatStr=[dataFormatStr,'simulinkmultidimtimeseries'];
                metaData_struct.dataformat=dataFormatStr;
                metaData_struct.signalBlockPath=obj.BlockPath;


                if~isempty(obj.PortIndex)
                    metaData_struct.signalPortIndex=obj.PortIndex;
                else
                    metaData_struct.signalPortIndex='';
                end

                metaData_struct.signalSignalName=obj.SignalName;
                metaData_struct.signalParentName=obj.SLParentName;

                if isempty(obj.ListItems{1}.Data.Name)
                    obj.ListItems{1}.Data.Name='';
                end
                metaData_struct.Name=obj.Name;
                metaData_struct.TSName=obj.TSName;
                metaData_struct.TimeseriesName=obj.TimeseriesName;

            elseif obj.isLogged




                dataFormatStr=[dataFormatStr,'loggedsignal:multidimtimeseries'];
                metaData_struct.dataformat=dataFormatStr;

                metaData_struct.TSName=obj.SignalName;
                metaData_struct.TimeseriesName=obj.TimeseriesName;
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
                metaData_struct.PortType=obj.PortType;








            elseif isa(obj.ListItems{1}.Data,'timeseries')

                dataFormatStr=[dataFormatStr,'multidimtimeseries'];
                metaData_struct.dataformat=dataFormatStr;


                if isempty(obj.ListItems{1}.Data.Name)
                    obj.ListItems{1}.Data.Name='';
                end

                metaData_struct.Name=obj.Name;
                metaData_struct.TSName=obj.TSName;
                metaData_struct.TimeseriesName=obj.TimeseriesName;
            elseif obj.isStructSignal
                metaData_struct.BlockName=obj.BlockName;
            end


            metaData_struct.isEnum=obj.isEnum;
            metaData_struct.isString=obj.isString;


            if obj.isFixDT

                metaData_struct=starepository.ioitem.DataDump.appendFiDataToMetaDataStruct(obj.ListItems{1}.Data.Data,metaData_struct);


            end

            metaData_struct.ParentID=obj.RepoParentID;
            metaData_struct.FileName=obj.FileName;
            metaData_struct.LastKnownFullFile=obj.LastKnownFullFile;
            tempWhich=which(obj.LastKnownFullFile);

            fileInfo=dir(tempWhich);
            if~isempty(fileInfo)
                metaData_struct.LastModifiedDate=fileInfo.date;
            else
                metaData_struct.LastModifiedDate='';
            end

            metaData_struct.FullName=getFullName(obj);
        end


        function setFixedPointProperties(obj)

            obj.isFixDT=false;
            if~isempty(strfind(obj.Properties.DataType,'fixdt'))
                obj.isFixDT=true;
            end
        end


        function interpMethod=getInterpolation(obj)

            if(obj.isEnum)||(obj.isBool)||(obj.isString)

                interpMethod='zoh';

            else

                if isa(obj.ListItems{1}.Data,'timeseries')
                    interpMethod=obj.ListItems{1}.Data.getinterpmethod;

                elseif isa(obj.ListItems{1}.Data,'Simulink.Timeseries')
                    interpMethod=obj.ListItems{1}.Data.getInterpMethod;
                end

                if(strcmp(interpMethod,''))

                    interpMethod='linear';
                end

            end

        end


        function unitStr=getUnit(obj)
            unitStr=getUnits(obj,obj.ListItems{1}.Data.DataInfo.Units);
        end

    end

end

