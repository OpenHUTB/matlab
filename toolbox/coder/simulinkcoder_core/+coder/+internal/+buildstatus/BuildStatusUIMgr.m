classdef BuildStatusUIMgr<handle




    properties
TopMdlName
BuildStatusDB
BuildStatusDialog
IsToolstripInitialized

RequestInitializeChannel
OpenBuildStatusChannel
UpdateToolstripChannel
ReactToToolstripChannel

RequestInitializeChannelSub
ReactToToolstripChannelSub
    end

    methods

        function obj=BuildStatusUIMgr(topMdlName,buildStatusDB)
            obj.TopMdlName=topMdlName;
            obj.BuildStatusDB=buildStatusDB;
            obj.BuildStatusDialog=[];


            obj.IsToolstripInitialized=false;

            channelPrefix=['/BuildStatusUI/',obj.TopMdlName];
            obj.RequestInitializeChannel=[channelPrefix,'/initialize'];
            obj.OpenBuildStatusChannel=[channelPrefix,'/openBuildStatus'];
            obj.UpdateToolstripChannel=[channelPrefix,'/updateToolstrip'];
            obj.ReactToToolstripChannel=[channelPrefix,'/reactToToolstrip'];

            obj.ReactToToolstripChannelSub=[];
            obj.RequestInitializeChannelSub=[];
        end

        function setBuildStatusDB(obj,buildStatusDB,varargin)
            obj.BuildStatusDB=buildStatusDB;
        end

        function setBuildStatusDialog(obj,buildStatusDlg)
            obj.BuildStatusDialog=buildStatusDlg;
        end

        function openBuildStatusDialog(obj)

            obj.checkoutLicense();



            dlgs=coder.internal.buildstatus.getBuildStatusDialog();

            if~isempty(dlgs)&&ismember(obj.TopMdlName,{dlgs.modelName})

                theDlg=dlgs(ismember({dlgs.modelName},obj.TopMdlName));
                theDlg.cleanup;
                obj.BuildStatusDialog=[];
            end

            connector.ensureServiceOn;


            fhl=@(x)obj.toolstripHandler(x);
            obj.ReactToToolstripChannelSub=message.subscribe(obj.ReactToToolstripChannel,fhl);


            fhl=@(x)obj.initializeUIHandler(x);
            obj.RequestInitializeChannelSub=message.subscribe(obj.RequestInitializeChannel,fhl);


            debug=false;
            obj.BuildStatusDialog=coder.internal.buildstatus.getBuildStatusDialog(...
            obj.TopMdlName,[],debug,...
            {obj.ReactToToolstripChannelSub,obj.RequestInitializeChannelSub});
            obj.BuildStatusDialog.show;
            obj.IsToolstripInitialized=true;


            obj.hClientReady(@obj.hNOP);
        end

        function initializeUIHandler(obj,msg)



            msgOut=getInitialInfo(obj,msg);
            msgOut.option='openUI';
            message.publish(obj.OpenBuildStatusChannel,msgOut);
        end

        function initializeUI(obj)
            msgOut=getInitialInfo(obj,'reset');
            msgOut.option='openUI';


            obj.hClientReady(@message.publish,{obj.OpenBuildStatusChannel,msgOut});
        end

        function openBuildStatusTab(obj,action)
            msgOut=getInitialInfo(obj,action);
            msgOut.option='openTab';


            obj.hClientReady(@message.publish,{obj.OpenBuildStatusChannel,msgOut});
        end

        function msgOut=getInitialInfo(obj,action)
            if isempty(obj.BuildStatusDB.StatusTable)
                mdlNames={};
            else
                mdlNames=obj.BuildStatusDB.StatusTable.keys;
            end

            f1='mdlRefName';f2='status';f3='progress';f4='buildTime';

            switch action
            case 'reset'

                v1=mdlNames;v2=DAStudio.message('RTW:buildStatus:Blocked');v3=0;v4='-';
                initialTableData=struct(f1,v1,f2,v2,f3,v3,f4,v4);

                msgOut.numWkInUse=0;
                msgOut.topPBVal=0;
            case 'load'

                initialTableData=struct(f1,{},f2,{},f3,{},f4,{});
                if~isempty(obj.BuildStatusDB.StatusTable)
                    k=obj.BuildStatusDB.StatusTable.keys;
                    val=obj.BuildStatusDB.StatusTable.values;
                    for n=1:length(obj.BuildStatusDB.StatusTable)
                        tmpData=val{n};
                        if~ischar(tmpData.buildTime)
                            tmpData.buildTime=datestr(tmpData.buildTime/(24*60*60),'HH:MM:SS');
                        end
                        tmpData.mdlRefName=k{n};
                        initialTableData(n)=tmpData;
                    end
                end

                msgOut.numWkInUse=obj.BuildStatusDB.NumWkInUse;
                msgOut.topPBVal=obj.BuildStatusDB.TopProgressBarValue;
            end

            msgOut.tableData=initialTableData;
            msgOut.numWks=obj.BuildStatusDB.NumWks;
            msgOut.numTotalMdls=length(mdlNames);
            msgOut.isRunning=slprivate('checkBuildState','isintermediatestate');
            msgOut.targetType=obj.BuildStatusDB.TargetType;
            msgOut.optNumWorkers=obj.BuildStatusDB.OptNumWorkers;
            msgOut.totalElapsedTime=...
            datestr(obj.BuildStatusDB.TotalElapsedTime/(24*60*60),'HH:MM:SS');
        end

        function toolstripHandler(obj,msg)
            switch msg.action
            case 'cancelBuild'
                slprivate('checkBuildState','setstate',coder.internal.BuildState.CANCELING);
            case 'openPA'
                performanceadvisor(obj.TopMdlName);
            case 'help'
                helpview(fullfile(docroot,'toolbox','rtw','helptargets.map'),...
                'Tag_Build_RTW_ERT_status_viewer');
            end
        end

        function updateToolstrip(obj,action,varargin)
            switch action
            case 'cancelBuildButton'

                if nargin>2
                    msgOut.isRunning=varargin{1};
                else


                    msgOut.isRunning=(slprivate('checkBuildState','getstate')==...
                    coder.internal.BuildState.BUILDING);
                end
                msgOut.option='cancelBuildButton';
            case 'openPAButton'


                if nargin>2
                    msgOut.isRunning=varargin{1};
                else
                    msgOut.isRunning=slprivate('checkBuildState','isintermediatestate');
                end
                msgOut.option='openPAButton';
            end

            message.publish(obj.UpdateToolstripChannel,msgOut);
        end

        function outputArg=hClientReady(obj,functionHandle,inputArgs,numOutputArgs,...
            maxNumTries,pauseLength)







            narginchk(2,6);
            if nargin<3;inputArgs={};end
            if nargin<4;numOutputArgs=0;end
            if nargin<5;maxNumTries=100;end
            if nargin<6;pauseLength=0.1;end

            ready=false;
            channel=['/BuildStatusUI/',obj.TopMdlName,'/',...
            obj.BuildStatusDB.TargetType,'/informReady'];
            if~isempty(obj.BuildStatusDialog)&&...
                isa(obj.BuildStatusDialog,'coder.internal.buildstatus.BuildStatusDialog')
                sub=message.subscribe(channel,@locCheckReadyHandler);
                obj.BuildStatusDialog.addSubNeedToClean({sub});
            else


                sub=[];
            end

            if numOutputArgs==0
                functionHandle(inputArgs{:});
            else
                outputArg=functionHandle(inputArgs{:});
            end

            if isempty(sub)
                return;
            end

            idx=1;
            while(~ready&&(idx<maxNumTries))

                pause(pauseLength);
                idx=idx+1;
            end


            message.unsubscribe(sub);

            allSubs=obj.BuildStatusDialog.getSubNeedToClean;
            idx=ismember([allSubs{:}],sub);
            obj.BuildStatusDialog.setSubNeedToClean(allSubs(~idx));














            function locCheckReadyHandler(msg)
                if strcmp(msg,'ready')
                    ready=true;
                end
            end
        end

        function hNOP(varargin)



        end

        function updateWithFinalState(obj,tMdl,targetType,tHErr,varargin)












            if nargin>=7
                tStatus=varargin{1};
                tBuildTime=varargin{2};
                nCompletedMdls=varargin{3};
            elseif~tHErr


                DAStudio.error('RTW:utility:invalidArgCount',...
                'When there is no build error, locUpdateUIwithFinalState','at least seven');
            end

            buildStatusDB=obj.BuildStatusDB;
            if tHErr
                buildStatusDB.updateBuildStatusTable({tMdl},...
                'status',DAStudio.message('RTW:buildStatus:Error'));
                obj.updateToolstrip('cancelBuildButton',false);
                obj.updateToolstrip('openPAButton',false);
            else

                if tStatus
                    buildStatusLastMsg=DAStudio.message('RTW:buildStatus:Completed');
                else
                    buildStatusLastMsg=DAStudio.message('RTW:buildStatus:WasUpToDate');
                end

                buildStatusDB.updateBuildStatusTable({tMdl},...
                'status',buildStatusLastMsg,...
                'buildTime',tBuildTime);
                buildStatusDB.updateTopProgressBar(nCompletedMdls);
                obj.updateToolstrip('cancelBuildButton');
                obj.updateToolstrip('openPAButton');
            end

            buildStatusDB.ctrlTotalElapsedTimer('stopTimer');
            topMdl=buildStatusDB.TopMdlName;
            if strcmp(targetType,'SIM')
                dir=RTW.getBuildDir(topMdl).ModelRefRelativeRootSimDir;
            else
                dir=RTW.getBuildDir(topMdl).ModelRefRelativeRootTgtDir;
            end
            save(fullfile(dir,['buildStatusDB_',topMdl,'.mat']),'buildStatusDB');
        end
    end

    methods(Static)
        function checkoutLicense()
            lics={'Real-Time_Workshop','Matlab_Coder'};
            for i=1:length(lics)
                [lic,~]=builtin('license','checkout',lics{i});
                if~lic
                    DAStudio.error('RTW:buildStatus:MissingLicense');
                end
            end
        end
    end

end




