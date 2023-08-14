








classdef LVIOSource<handle

    properties(Abstract,Constant)

IOSourceName
    end

    properties

DataName


DataParams


DataPath


TimeVector


Scalars
    end

    events
ExternalTrigger
    end

    properties(Dependent)

IsTemporalData

NumFrames
    end




    methods(Abstract)

        configureImportPanel(this,panel)



        [dataPath,dataParams,dataName]=getLoadPanelData(this)



    end




    methods(Abstract)
        loadData(this,dataName,dataParams,dataPath)










    end




    methods(Abstract)
        data=readData(this,index)



    end

    methods(Access=protected)




        function[isSuccess,message]=writeData(this,dataArray,timeVector,destDir)








            isSuccess=false;
            message=[];

            if~isfolder(destDir)
                message='Destination directory does not exist';
                return;
            end

            this.showProgressBar(0);

            k=numel(dataArray);
            for i=1:k









                ptCld=dataArray{i}.PointCloud;





                if isprop(this,'FileDataStore')
                    destPath=this.FileDataStore.Files{i};
                    [~,name,ext]=fileparts(destPath);
                    destPath=fullfile(destDir,strcat(name,ext));
                else
                    name=strcat(int2str(i),'.pcd');
                    destPath=fullfile(destDir,name);
                end

                try
                    pcwrite(ptCld,destPath);
                catch ME
                    message=ME.message;
                    isSuccess=false;
                    close(h);
                    break;
                end

                if(mod(i,int8(k/10))==0)

                    this.showProgressBar(i/k);
                end
            end

            this.showProgressBar(1);

            if isempty(message)

                isSuccess=true;
            end
        end
    end




    methods(Static)
        function TF=hasTimeInfo()


            TF=false;



        end
    end




    methods
        function isTemporalData=get.IsTemporalData(this)



            if isempty(this.TimeVector)
                isTemporalData=false;
            elseif numel(this.TimeVector)==1
                isTemporalData=false;
            else
                isTemporalData=true;
            end

        end


        function numFrames=get.NumFrames(this)

            if this.IsTemporalData
                numFrames=numel(this.TimeVector);
            else
                numFrames=1;
            end
        end


        function frameDataStruct=createDataStruct(this)



            frameDataStruct=...
            lidar.internal.lidarViewer.lidarViewerIO.createFrameDataStruct([],[]);
        end
    end




    methods(Hidden)
        function validName=getUniqueName(this,dataName)
            if~isvarname(dataName)
                dataName=matlab.lang.makeValidName(dataName);
            end
            validName=strcat(this.IOSourceName,'_',dataName);
        end


        function[isSuccess,message]=accessWriteFunc(this,dataArray,timeVector,destDir)
            [isSuccess,message]=writeData(this,dataArray,timeVector,destDir);
        end


        function accessLoadFunc(this,dataName,dataParams,dataPath)
            this.loadData(dataName,dataParams,dataPath);
            if isempty(this.TimeVector)
                this.TimeVector=seconds(1);
            end
        end


        function bringToFront(this)


            lidar.internal.lidarViewer.createAndNotifyExtTrigger(...
            this,'bringToFront');
        end


        function showProgressBar(this,progress)

            lidar.internal.lidarViewer.createAndNotifyExtTrigger(...
            this,'progressBar',getString(message('lidar:lidarViewer:ExportDataMsg')),...
            getString(message('lidar:lidarViewer:ExportDataTitle')),progress);
        end
    end
end