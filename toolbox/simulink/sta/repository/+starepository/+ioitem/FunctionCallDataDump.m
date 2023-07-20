classdef FunctionCallDataDump<starepository.ioitem.DataDump



    methods


        function metaData_struct=getMetaData(obj)

            if~obj.isDataSetElement
                metaData_struct.dataformat='functioncall';
            else
                metaData_struct.dataformat='datasetElement:functioncall';
            end

            metaData_struct.DataType=obj.Properties.DataType;




            metaData_struct.SignalType=getString(message('sl_sta_general:common:Real'));
            metaData_struct.SampleTime='-1';
            metaData_struct.Dimension='1';
            metaData_struct.Min='[]';
            metaData_struct.Max='[]';
            metaData_struct.FileName=obj.FileName;
            metaData_struct.LastKnownFullFile=obj.LastKnownFullFile;
            fileInfo=dir(obj.LastKnownFullFile);
            if~isempty(fileInfo)
                metaData_struct.LastModifiedDate=fileInfo.date;
            else
                metaData_struct.LastModifiedDate='';
            end
            metaData_struct.FullName=getFullName(obj);

            if~isempty(obj.ParentName)
                metaData_struct.ParentName=obj.ParentName;
            else
                metaData_struct.ParentName='';
            end
        end


        function timeDims=getTimeDim(obj)

            timeDims=1;

        end


        function sampleDims=getSampleDims(obj)
            sampleDims=1;
        end


        function timeVals=getTimeValues(obj)
            timeVals=obj.Data;
        end


        function dataVals=getDataValues(obj)
            dataVals=obj.Data;
        end


        function interpVal=getInterpolation(~)
            interpVal='linear';
        end
    end


end
