






classdef LVIOModel<handle

    properties(Access=private)

DataInfoTable



SourceObjList



NameMap
    end

    properties(Hidden,Constant)

        DataInfoFields={'SourceName','DataName','DataPath',...
        'IsTemporalData','TimeVectors','HasTimingInfo','IsDataEdited',...
        'ToExportData','Data','GlobalLimits'};
    end

    events

ExternalTrigger
    end

    properties(Dependent)
NumData
    end




    methods
        function this=LVIOModel()

            this.DataInfoTable=table({},{},{},logical([]),{},logical([]),logical([]),...
            logical([]),{},[],'VariableNames',this.DataInfoFields);

        end
    end




    methods
        function isSuccess=addData(this,srcObj,dataInfo)




            [dataArray,globalLimits,isSuccess]=this.loadData(srcObj,dataInfo);

            if isSuccess

                rowEntry=...
                {srcObj.IOSourceName,dataInfo.DataName,...
                dataInfo.DataPath,srcObj.IsTemporalData,{srcObj.TimeVector},...
                srcObj.hasTimeInfo(),false,false...
                ,{},[]};

                this.DataInfoTable=[this.DataInfoTable;rowEntry];

                this.DataInfoTable.GlobalLimits{end}=globalLimits;
                this.DataInfoTable.Data{end}=dataArray;

                this.SourceObjList{end+1,1}=srcObj;
                this.setUpMap();
            end
        end


        function deleteData(this,dataName)


            try
                dataIdx=this.NameMap(dataName);
            catch

                return;
            end

            this.DataInfoTable(dataIdx,:)=[];
            this.SourceObjList(dataIdx,:)=[];
            this.setUpMap();
        end


        function data=readData(this,dataName,frameIndex)


            if isa(frameIndex,'duration')
                frameIndex=getDataIndexFromTimestamp(...
                this,dataName,frameIndex);
            end

            dataIdx=getIndexFromName(this,dataName);
            if~isempty(dataIdx)



                data=this.DataInfoTable.Data{dataIdx}{frameIndex};

            else
                data=[];
            end

        end


        function clear(this)

            this.DataInfoTable=[];
            this.NameMap=containers.Map.empty;
            this.SourceObjList=[];
        end
    end




    methods
        function numData=get.NumData(this)

            numData=height(this.DataInfoTable);
        end


        function dataId=getDataIdFromName(this,dataName)

            dataId=this.getIndexFromName(dataName);
        end


        function editStatus=getEditStatus(this)

            editStatus=this.DataInfoTable.IsDataEdited;
        end


        function editStatus=getExportStatus(this)

            editStatus=this.DataInfoTable.ToExportData;
        end


        function markDataAsEdited(this,dataIdx)


            this.DataInfoTable.IsDataEdited(dataIdx)=true;



            this.DataInfoTable.ToExportData(dataIdx)=true;
        end


        function markDataAsExported(this,dataIdx)

            this.DataInfoTable.ToExportData(dataIdx)=false;
        end


        function scalars=getListOfScalars(this,dataIdx)


            scalars=this.SourceObjList{dataIdx,1}.Scalars;
        end


        function data=getDataInfo(this,dataIdx)

            data=this.DataInfoTable(dataIdx,:);
        end


        function timeVector=getTimeVectors(this,dataId)

            timeVector=this.DataInfoTable.TimeVectors{dataId};
        end


        function TF=getHasTimingInfoFlag(this,dataId)

            TF=this.DataInfoTable.HasTimingInfo(dataId);
        end


        function index=getDataIndexFromTimestamp(this,dataName,ts)





            dataIdx=this.NameMap(dataName);
            timeVector=this.DataInfoTable.TimeVectors{dataIdx};

            if isempty(timeVector)

                index=[];
                return;
            end



            idx=find(timeVector>=ts,1);
            if isempty(idx)



                index=numel(timeVector);
            else
                value=timeVector(idx);
                if value~=ts
                    index=max(1,idx-1);
                else
                    index=idx;
                end
            end
        end


        function dataInfo=getLoadedInfoForExport(this)


            dataInfo=this.DataInfoTable;
            dataInfo=removevars(dataInfo,{'SourceName',...
            'DataPath','IsTemporalData','TimeVectors',...
            'Data','GlobalLimits','HasTimingInfo',...
            'IsDataEdited','ToExportData'});
        end


        function isSuccess=exportData(this,destinationFolder,toExport)





            isSuccess=true;
            toExportIdx=find(toExport(:)==1);

            for idx=1:numel(toExportIdx)
                i=toExportIdx(idx);

                srcObj=this.SourceObjList{i};

                dataArray=this.DataInfoTable.Data{i};
                timeVector=this.DataInfoTable.TimeVectors{i};

                destDir=fullfile(destinationFolder,this.DataInfoTable.DataName{i});

                [~,msg,~]=mkdir(destDir);
                isSuccess=isempty(msg);

                if~isSuccess
                    break;
                end

                [TF,~]=...
                srcObj.accessWriteFunc(dataArray,timeVector,destDir);

                isSuccess=isSuccess&&TF;


                this.markDataAsExported(i);
            end

            if~isSuccess

                lidar.internal.lidarViewer.createAndNotifyExtTrigger(...
                this,'warningDialog',getString(message('lidar:lidarViewer:ExportFailMsg')),...
                getString(message('lidar:lidarViewer:Error')));
            end
        end



        function dataArray=getPtCldData(this,dataName)


            dataIdx=this.getDataIdFromName(dataName);
            dataArray=this.DataInfoTable.Data{dataIdx};
        end


        function updateData(this,dataIdx,dataArray)


            this.DataInfoTable.Data{dataIdx}=dataArray;
        end
    end




    methods(Access=private)
        function[dataArray,globalLimits,isSuccess]=loadData(this,srcObj,dataInfo)



            isSuccess=false;


            if~isempty(this.NameMap)&&any(strcmp(this.NameMap.keys,dataInfo.DataName))

                warningMessage=getString(message('lidar:lidarViewer:DuplicateError'));
                warningTitle=getString(message('lidar:lidarViewer:Warning'));
                lidar.internal.lidarViewer.createAndNotifyExtTrigger(...
                this,'warningDialog',warningMessage,warningTitle);
                dataArray={};
                globalLimits=[];
                return;
            end


            try
                srcObj.accessLoadFunc(dataInfo.DataName,dataInfo.DataParams,dataInfo.DataPath);
                [dataArray,globalLimits]=this.setUpData(srcObj);
                isSuccess=~isempty(globalLimits);
            catch ME
                dataArray={};
                globalLimits=[];
                warningMessage=ME.message;
                warningTitle=getString(message('lidar:lidarViewer:Warning'));


                lidar.internal.lidarViewer.createAndNotifyExtTrigger(...
                this,'warningDialog',warningMessage,warningTitle);
            end
        end


        function setUpMap(this)



            if this.NumData==0
                this.NameMap=containers.Map.empty;
                return;
            end

            signalName=this.DataInfoTable.DataName;
            this.NameMap=containers.Map(signalName,(1:numel(signalName)));
        end


        function dataIdx=getIndexFromName(this,dataName)

            try
                dataIdx=this.NameMap(dataName);
            catch

                dataIdx=[];
            end
        end


        function[dataArray,axisLim]=setUpData(this,srcObj)





            numFrames=srcObj.NumFrames;
            dataArray=cell(numFrames,1);
            ptCldLim=zeros(numFrames,6);


            lidar.internal.lidarViewer.createAndNotifyExtTrigger(...
            this,'progressBar',getString(message('lidar:lidarViewer:DataSetUpMsg')),...
            getString(message('lidar:lidarViewer:DataSetUpTitle')),0);

            for i=1:numFrames
                try
                    dataArray{i}=srcObj.readData(i);
                    ptCldLim(i,:)=[dataArray{i}.PointCloud.XLimits(:)'...
                    ,dataArray{i}.PointCloud.YLimits(:)'...
                    ,dataArray{i}.PointCloud.ZLimits(:)'];
                catch ME

                    lidar.internal.lidarViewer.createAndNotifyExtTrigger(...
                    this,'progressBar',getString(message('lidar:lidarViewer:DataSetUpMsg')),...
                    getString(message('lidar:lidarViewer:DataSetUpTitle')),1);

                    axisLim=[];
                    warningTitle=getString(message('lidar:lidarViewer:Warning'));


                    lidar.internal.lidarViewer.createAndNotifyExtTrigger(...
                    this,'warningDialog',ME.message,warningTitle);
                    return;
                end

                if(mod(i,int8(numFrames/10))==0)

                    lidar.internal.lidarViewer.createAndNotifyExtTrigger(...
                    this,'progressBar',getString(message('lidar:lidarViewer:DataSetUpMsg')),...
                    getString(message('lidar:lidarViewer:DataSetUpTitle')),i/numFrames);
                end
            end

            axisMinLim=min(ptCldLim(:,[1,3,5]),[],1);
            axisMaxLim=max(ptCldLim(:,[2,4,6]),[],1);
            axisLim=[axisMinLim(1),axisMaxLim(1)...
            ,axisMinLim(2),axisMaxLim(2)...
            ,axisMinLim(3),axisMaxLim(3)];


            lidar.internal.lidarViewer.createAndNotifyExtTrigger(...
            this,'progressBar',getString(message('lidar:lidarViewer:DataSetUpMsg')),...
            getString(message('lidar:lidarViewer:DataSetUpTitle')),1);
        end
    end
end