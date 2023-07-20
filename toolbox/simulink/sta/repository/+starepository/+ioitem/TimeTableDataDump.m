classdef TimeTableDataDump<starepository.ioitem.DataDump



    properties



        SIGNAL_INDEX=1;

        format_str='sl_timetable';

    end

    methods


        function[timeDims,sampleDims]=getTimeAndSampleDims(obj)
            timeDims=getTimeDim(obj);
            sampleDims=getSampleDims(obj);

        end


        function timeDims=getTimeDim(~)

            timeDims=1;
        end


        function sampleDims=getSampleDims(obj)

            dataVals=obj.Data.(1);


            tssize=size(dataVals);
            sampleDims=tssize(2:end);

        end


        function timeAndDataVals=getTimeAndDataVals(obj)



            time_varName=obj.Data.Properties.DimensionNames{1};
            timeVar=obj.Data.(time_varName);
            durationTypeString=getDurationString(obj,timeVar);
            fcnH=str2func(durationTypeString);
            timeAndDataVals.Time=double(fcnH(timeVar));
            timeAndDataVals.Data=obj.Data.(1);
        end


        function durationTypeString=getDurationString(~,Time)


            IS_YEARS=strcmp('y',Time.Format);
            IS_HOURS=strcmp('h',Time.Format);
            IS_MINUTES=strcmp('m',Time.Format);
            IS_SECONDS=strcmp('s',Time.Format);

            if IS_YEARS
                durationTypeString='years';
            elseif IS_HOURS
                durationTypeString='hours';
            elseif IS_MINUTES
                durationTypeString='minutes';
            elseif IS_SECONDS
                durationTypeString='seconds';
            else

                durationTypeString='seconds';
            end
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

            dimNamesOf1=obj.Data.(obj.Data.Properties.DimensionNames{1});

            durationTypeString=getDurationString(obj,dimNamesOf1);
            fcnH=str2func(durationTypeString);

            metaData_struct.MinTime=min(double(fcnH(dimNamesOf1)));
            metaData_struct.MaxTime=max(double(fcnH(dimNamesOf1)));
            metaData_struct.Min=obj.Properties.Min;
            metaData_struct.Max=obj.Properties.Max;

            metaData_struct.DimensionNames=obj.Data.Properties.DimensionNames;

            if~strcmp(metaData_struct.Dimension,'1')
                obj.format_str=['non_scalar_',obj.format_str];
            end



            durationTypeString=getDurationString(obj,obj.Data.(metaData_struct.DimensionNames{1}));
            metaData_struct.TimeObjectClass=durationTypeString;


            metaData_struct.VariableNames=obj.Data.Properties.VariableNames;
            metaData_struct.VariableUnits=obj.Data.Properties.VariableUnits;

            if obj.isEnum
                metaData_struct.EnumName=obj.Properties.DataType;
            end
            metaData_struct.isEnum=obj.isEnum;
            metaData_struct.isString=obj.isString;

            metaData_struct.FullName=getFullName(obj);

            metaData_struct.FullDimensions=num2str(size(obj.Data.(metaData_struct.VariableNames{obj.SIGNAL_INDEX})));

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



            if obj.isLogged


                dataFormatStr=[dataFormatStr,'loggedsignal:',obj.format_str];
                metaData_struct.dataformat=dataFormatStr;

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

            else
                dataFormatStr=[dataFormatStr,obj.format_str];
                metaData_struct.dataformat=dataFormatStr;

            end











            if obj.isFixDT

                dataVals=obj.Data.(1);
                metaData_struct=appendFiDataToMetaDataStructImpl(obj,dataVals,metaData_struct);
            end

            metaData_struct.ParentID=obj.RepoParentID;
            metaData_struct.FileName=obj.FileName;
            metaData_struct.LastKnownFullFile=obj.LastKnownFullFile;
            metaData_struct.LastModifiedDate=obj.FileModifiedDate;


            metaData_struct.Description=obj.Data.Properties.Description;

            metaData_struct.VariableDescriptions=obj.Data.Properties.VariableDescriptions;
            metaData_struct.VariableContinuity=obj.Data.Properties.VariableContinuity;
            metaData_struct.UserData=obj.Data.Properties.UserData;
        end


        function interpMethod=getInterpolation(obj)

            if(obj.isEnum)||(obj.isBool)||obj.isString

                interpMethod='zoh';

            else


                interpMethod='linear';

                if isStringScalar(obj.Data.Properties.VariableContinuity)
                    switch obj.Data.Properties.VariableContinuity
                    case "continuous"
                        interpMethod='linear';
                    case "step"
                        interpMethod='zoh';
                    end
                elseif iscellstr(obj.Data.Properties.VariableContinuity)
                    switch obj.Data.Properties.VariableContinuity{1}
                    case 'continuous'
                        interpMethod='linear';
                    case 'step'
                        interpMethod='zoh';
                    end
                elseif isa(obj.Data.Properties.VariableContinuity,'matlab.tabular.Continuity')
                    switch obj.Data.Properties.VariableContinuity
                    case matlab.tabular.Continuity.continuous
                        interpMethod='linear';
                    case matlab.tabular.Continuity.step
                        interpMethod='zoh';
                    end

                end



            end

        end


        function unitStr=getUnit(obj)
            unitStr='';

            if~isempty(obj.Data.Properties.VariableUnits)
                unitStr=obj.Data.Properties.VariableUnits{obj.SIGNAL_INDEX};
            end
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
            end
        end




        function[ret,idxStr]=locGetChannelData(~,dataVals,sampleDims,channelIdx)
            dimIdx=cell(size(sampleDims));
            [dimIdx{:}]=ind2sub(sampleDims,channelIdx);
            channel=cell2mat(dimIdx);
            numDims=length(channel);
            S.type='()';
            if numDims==1
                S.subs=[':',dimIdx];
                idxStr=sprintf('(:,%d)',channel);
            else
                S.subs=[':',dimIdx];
                idxStr=sprintf('%d,',channel);
                idxStr=sprintf(':,%s',idxStr(1:end-1));
                idxStr=sprintf('(%s)',idxStr);



            end

            ret=squeeze(subsref(dataVals,S));


            if~isreal(dataVals)&&isreal(ret)
                complexPart_FcnH=str2func(class(ret));
                ret=complex(ret,complexPart_FcnH(zeros(length(ret),1)));
            end
        end
    end

end

