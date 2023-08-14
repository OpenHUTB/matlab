






classdef LVIOController<handle

    properties(Access=private)

        Model lidar.internal.lidarViewer.lidarViewerIO.LVIOModel

    end

    properties(Access=private)



LidarViewerIOObj


Map

    end

    events
DataAdded

ExternalTrigger
    end

    methods



        function this=LVIOController(modelObj)


            this.Model=modelObj;

            addlistener(this.Model,'ExternalTrigger',@(~,evt)notify(this,'ExternalTrigger',evt));

            this.initialise();
        end




        function importData(this,srcType,evt)




            try
                srcIdx=this.Map(srcType);
            catch


                return;
            end
            srcObj=this.LidarViewerIOObj{srcIdx};



            if strcmp(srcType,getString(message('lidar:lidarViewer:FromWorkspace')))
                srcObj.SignalIndex=this.Model.NumData+1;
            end

            [isSuccess,info]=this.import(srcObj);

            evt.IsImportSuccess=false;
            if isSuccess

                this.addDataInModel(srcObj,info);


                if~isempty(info.DataPath)
                    evt.IsImportSuccess=isSuccess;
                end
            end

            this.resetSourcrObject(srcIdx);
        end




        function anyFiletoBeExported=exportData(this)




            dataInfo=this.Model.getLoadedInfoForExport();


            [isSuccess,info]=this.export(dataInfo);

            if~isSuccess
                anyFiletoBeExported=[];
                return;
            end







            anyFiletoBeExported=~all(info.ToExportSignal(this.Model.getExportStatus));


            isSuccess=this.exportDataInModel(info.DestinationFolder,info.ToExportSignal);

            if~isSuccess

                anyFiletoBeExported=any(this.Model.getExportStatus);
            end
        end




        function deleteData(this,signalName)


            this.Model.deleteData(signalName);


        end




        function data=readData(this,dataName,timeStamp)


            data=this.Model.readData(dataName,timeStamp);
        end




        function resetSourceList(this)


            this.initialise();






        end




        function addDataInModel(this,srcObj,info)

            isSuccess=this.Model.addData(srcObj,info);
            if isSuccess
                notify(this,'DataAdded');
            end
        end


        function isSuccess=exportDataInModel(this,destFolder,toExport)

            isSuccess=this.Model.exportData(destFolder,toExport);
        end
    end




    methods(Access=private)



        function initialise(this)





            IOSrcName={};


            packageInfo=meta.package.fromName('lidar.internal.lidarViewer.lidarViewerIO.source');

            for i=1:numel(packageInfo.ClassList)
                srcObj=eval(packageInfo.ClassList(i).Name);
                addlistener(srcObj,'ExternalTrigger',@(~,evt)notify(this,'ExternalTrigger',evt));
                IOSrcName{end+1}=srcObj.IOSourceName;
                this.LidarViewerIOObj{end+1}=srcObj;
            end



            this.Map=containers.Map(IOSrcName,(1:numel(IOSrcName)));
        end


        function resetSourcrObject(this,srcIdx)



            this.LidarViewerIOObj{srcIdx}=...
            eval(class(this.LidarViewerIOObj{srcIdx}));
            addlistener(this.LidarViewerIOObj{srcIdx},'ExternalTrigger',@(~,evt)notify(this,'ExternalTrigger',evt));
        end
    end




    methods(Access=private)



        function[isSuccess,info]=import(this,srcObj)


            importHelper=lidar.internal.lidarViewer.lidarViewerIO.LVImport(...
            getString(message('lidar:lidarViewer:ImportSrcObj',srcObj.IOSourceName)));
            try
                importHelper.open(srcObj);
            catch ME
                info=[];
                isSuccess=false;
                warningMessage=ME.message;
                warningTitle=getString(message('lidar:lidarViewer:Warning'));
                lidar.internal.lidarViewer.createAndNotifyExtTrigger(...
                this,'warningDialog',warningMessage,warningTitle);
                importHelper.close();
                return;
            end
            wait(importHelper);

            userInfo=importHelper.getUserInfo();
            isSuccess=userInfo.isSuccess;
            info=userInfo.info;

        end




        function[isSuccess,userInfo]=export(this,dataInfo)

            exportHelper=lidar.internal.lidarViewer.lidarViewerIO.LVExport();
            addlistener(exportHelper,'ExternalTrigger',@(~,evt)notify(this,'ExternalTrigger',evt));
            exportHelper.open(dataInfo);
            wait(exportHelper);

            userInfo=exportHelper.getUserInfo();
            isSuccess=userInfo.ToExport;
        end
    end
end