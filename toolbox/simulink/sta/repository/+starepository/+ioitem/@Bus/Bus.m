classdef Bus<starepository.ioitem.Container&starepository.ioitem.DataSetChild



    properties
        isLogged=false
BlockPath
BlockPathType
SubPath
PortType
PortIndex
LoggedName
    end

    methods
        function obj=Bus(ListItems,BusName)

            if isStringScalar(BusName)
                BusName=char(BusName);
            end

            obj=obj@starepository.ioitem.Container(ListItems,BusName);
            obj=obj@starepository.ioitem.DataSetChild;

        end


        function metaData=getMetaData(obj)
            metaData=[];

            dataFormatStr='';

            if obj.isDataSetElement
                dataFormatStr='datasetElement:';

                metaData.datasetElementIndex=['datasetElementIndex:',num2str(obj.DataSetIdx)];

                dsElName=obj.Name;
                if isempty(obj.Name)&&~ischar(obj.Name)
                    dsElName='';
                end
                metaData.datasetElementName=['datasetElementName:',dsElName];

                metaData.FileName=obj.FileName;
            end

            if obj.isLogged
                dataFormatStr=[dataFormatStr,'loggedsignal:busstructure'];
                metaData.dataformat=dataFormatStr;
                metaData.Name=obj.Name;
                metaData.BlockPathLength=length(obj.BlockPath);
                if~isempty(obj.BlockPath)
                    metaData.BlockPath=obj.BlockPath{1};
                end

                for id=2:length(obj.BlockPath)
                    metaData.(sprintf('BlockPath%d',id))=obj.BlockPath{id};
                end

                metaData.SubPath=obj.SubPath;
                metaData.BlockDataProperties=obj.BlockDataProperties;

            else

                dataFormatStr=[dataFormatStr,'busstructure'];

                metaData.dataformat=dataFormatStr;


            end
            metaData.FileName=obj.FileName;
            metaData.LastKnownFullFile=obj.LastKnownFullFile;
            tempWhich=which(obj.LastKnownFullFile);

            fileInfo=dir(tempWhich);

            if~isempty(fileInfo)
                metaData.LastModifiedDate=fileInfo.date;
            else
                metaData.LastModifiedDate='';
            end

            metaData.ParentID=obj.RepoParentID;

            metaData.FullName=getFullName(obj);
            metaData.ParentName=obj.ParentName;

        end

    end
end

