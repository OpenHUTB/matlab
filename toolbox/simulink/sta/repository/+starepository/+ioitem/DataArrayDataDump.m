classdef DataArrayDataDump<starepository.ioitem.DataDump



    properties
    end

    methods


        function[timeDims,sampleDims]=getTimeAndSampleDims(obj)

            timeDims=getTimeDim(obj);
            sampleDims=getSampleDims(obj);

        end


        function timeDims=getTimeDim(obj)
            timeDims=1;

        end


        function sampleDims=getSampleDims(obj)

            theDims=size(obj.Data);

            sampleDims=theDims(2)-1;
        end


        function timeAndDataVals=getTimeAndDataVals(obj)
            timeAndDataVals.Time=obj.Data(:,1);
            timeAndDataVals.Data=obj.Data(:,2:end);
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


        function signalLable=getSignalLabel(obj)
            signalLable=obj.Name;

            if isempty(signalLable)
                signalLable='';
            end
        end


        function modelSource=getModelSource(obj)
            modelSource='';
        end


        function sID=getSID(obj)
            sID='';
        end


        function metaData=getMetaData(obj)
            metaData=[];

            if obj.isDataSetElement
                metaData.dataformat='datasetElement:dataarray';
            else
                metaData.dataformat='dataarray';
            end
            metaData.FullName=getFullName(obj);
            metaData.FileName=obj.FileName;
            metaData.LastKnownFullFile=obj.LastKnownFullFile;

            tempWhich=which(obj.LastKnownFullFile);
            fileInfo=dir(tempWhich);
            if~isempty(fileInfo)
                metaData.LastModifiedDate=fileInfo.date;
            else
                metaData.LastModifiedDate='';
            end

            metaData.ParentName=obj.ParentName;
            metaData.isEnum=0;
            metaData.isString=0;

            metaData.MinTime=obj.Data(1,1);
            metaData.MaxTime=obj.Data(end,1);
            metaData.Min=double(min(obj.Data(:,2:end)));
            metaData.Max=double(max(obj.Data(:,2:end)));

            metaData.SignalType=getString(message('sl_sta_general:common:Real'));
            metaData.Dimension=mat2str(getSampleDims(obj));
            metaData.DataType='double';
        end


        function interpMethod=getInterpolation(obj)
            interpMethod='linear';


        end


        function unitStr=getUnit(obj)
            unitStr='';
        end


        function timeMetaMode=getTimeMetadataMode(~)
            timeMetaMode='';
        end


        function hierRef=getHierarchyReference(~)
            hierRef='';
        end


        function ret=getSampleTimeString(obj)
            ret='';

        end

    end

end

