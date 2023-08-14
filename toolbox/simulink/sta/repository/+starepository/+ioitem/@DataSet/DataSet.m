classdef DataSet<starepository.ioitem.Container



    properties
        DatasetName=''
    end

    methods
        function obj=DataSet(ListItems,BusName)
            obj=obj@starepository.ioitem.Container(ListItems,BusName);

        end


        function metaData_struct=getMetaData(obj)
            metaData_struct.dataformat='dataset';
            metaData_struct.FileName=obj.FileName;
            metaData_struct.LastKnownFullFile=obj.LastKnownFullFile;


            tempWhich=which(obj.LastKnownFullFile);

            fileInfo=dir(tempWhich);
            if~isempty(fileInfo)
                metaData_struct.LastModifiedDate=fileInfo.date;
            else
                metaData_struct.LastModifiedDate='';
            end
            metaData_struct.DatasetName=obj.DatasetName;

            metaData_struct.FullName=getFullName(obj);
        end

    end

end

