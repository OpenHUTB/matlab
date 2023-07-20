classdef DataArray<starepository.ioitem.Container&starepository.ioitem.DataSetChild&starepository.ioitem.DataArrayDataDump



    properties

Data
        rowMajorNotation=false;
    end

    methods


        function obj=DataArray(ListItems,BusName,Data)
            obj=obj@starepository.ioitem.Container(ListItems,BusName);
            obj=obj@starepository.ioitem.DataSetChild;
            obj.Data=Data;

        end


        function jsonStruct=initializeRepository(obj,fileName,onFileIndex,runID,parentSigID,...
            runTimeRange)

            obj.isEnum=false;
            obj.isBool=false;
            if parentSigID==0
                obj.ParentID='input';
            else
                obj.ParentID=parentSigID;
            end

            [~,dataSourceName,ext]=fileparts(fileName);

            obj.FileName=[dataSourceName,ext];
            obj.LastKnownFullFile=fileName;
            obj.OnFileIndex=onFileIndex;


            jsonStruct=ioitem2Structure(obj);


            [sigID,leafSigs,runTimeRange]=staCreateSignal(obj,...
            runID,parentSigID,runTimeRange);
            jsonStruct{1}.ID=sigID;

            kids=obj.sdiRepo.getSignalChildren(sigID);

            for k=1:length(kids)
                jsonStruct{k+1}.ID=kids(k);
                jsonStruct{k+1}.isEnum=obj.isEnum;
                jsonStruct{k+1}.ParentID=sigID;
                jsonStruct{k+1}.ParentName=[];
                jsonStruct{k+1}.DataSource=jsonStruct{1}.DataSource;
                jsonStruct{k+1}.FullDataSource=jsonStruct{1}.FullDataSource;
                jsonStruct{k+1}.TreeOrder=jsonStruct{1}.TreeOrder+k;
                jsonStruct{k+1}.DataType=obj.Properties.DataType;

                meta_struct.SignalName=jsonStruct{k+1}.Name;
                meta_struct.DataType=obj.Properties.DataType;
                meta_struct.SignalType=obj.Properties.SignalType;
                meta_struct.SampleTime=obj.Properties.SampleTime;
                meta_struct.Dimension='1';
                meta_struct.Min='[]';
                meta_struct.Max='[]';
                meta_struct.dataformat=['dataarray:col',num2str(k)];
                meta_struct.FileName=obj.FileName;

                sig=Simulink.sdi.getSignal(kids(k));
                sig.setMetaData(meta_struct);




                obj.staRepoUtil.setParent(kids(k),jsonStruct{1}.ID,k);
            end
        end


        function numSignals=getNumSignals(obj)

            numSignals=1;

        end


        function itemstruct=ioitem2Structure(obj)
            itemstruct=ioitem2Structure@starepository.ioitem.Item(obj);

            dims=size(obj.Data);
            childStruct{(dims(2)-1)}=[];
            [~,name,ext]=fileparts(starepository.ioitemproperty.SignalUIProperties.NormalIcon);
            theIconFile=[name,ext];
            for kKid=1:(dims(2)-1)


                if~obj.rowMajorNotation

                    staLabel=sprintf('%s(:,%d)',obj.Name,kKid+1);
                else



                    staLabel=sprintf('%s(%d,:)',obj.Name,kKid+1);
                end

                tempStruct.Name=staLabel;

                tempStruct.ParentName=obj.Name;
                tempStruct.ParentID=[];



                tempStruct.Icon=theIconFile;
                if obj.RepoSignalType

                    tempStruct.Type='Complex Signal';
                else

                    tempStruct.Type='Signal';

                end


                tempStruct.ID=[];

                tempStruct.isEnum=0;
                tempStruct.isString=false;
                tempStruct.DataType=obj.Properties.DataType;
                tempStruct.TreeOrder=1;


                childStruct{kKid}=tempStruct;

            end

            itemstruct=[itemstruct,childStruct];
            obj.itemstruct=itemstruct;

        end

    end

end

