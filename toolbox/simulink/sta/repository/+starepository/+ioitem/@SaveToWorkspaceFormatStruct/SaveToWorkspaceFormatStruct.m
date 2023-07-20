classdef SaveToWorkspaceFormatStruct<starepository.ioitem.Container



    properties




        StructureWithTime=false;

        isFromWorkspaceBlock=false;
        fromWorkspaceBlockSignalName='';
    end

    methods
        function obj=SaveToWorkspaceFormatStruct(ListItems,BusName)
            obj=obj@starepository.ioitem.Container(ListItems,BusName);

        end


        function metaData=getMetaData(obj)
            metaData=[];

            if obj.StructureWithTime
                metaData.dataformat='structwithtime';
            else
                metaData.dataformat='structwithouttime';
            end

            metaData.isFromWorkspaceBlock=obj.isFromWorkspaceBlock;
            metaData.fromWorkspaceBlockSignalName=obj.fromWorkspaceBlockSignalName;
            metaData.FileName=obj.FileName;
            metaData.LastKnownFullFile=obj.LastKnownFullFile;
            fileInfo=dir(obj.LastKnownFullFile);
            if~isempty(fileInfo)
                metaData.LastModifiedDate=fileInfo.date;
            else
                metaData.LastModifiedDate='';
            end
            metaData.FullName=getFullName(obj);
            metaData.ParentName=obj.ParentName;
        end

    end
end

