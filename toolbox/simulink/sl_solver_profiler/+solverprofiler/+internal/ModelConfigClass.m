classdef ModelConfigClass<handle












    properties(SetAccess=private)
Model




OrigConfigSet
ConfigSetCopy




OrigSolverProfileInfoName
OrigSaveSolverProfileInfo
OrigSolverProfileInfoMaxSize
OrigSolverProfileInfoLevel


LogXout
LogZC
LogSimlog
LogJacobian


SscStiffString
SscStiffTimes


XoutFormat
XoutLocation
XoutName
TempDir


SpidataName


StartTime
FromTime
ToTime
NumPDEvents


IsConfigSetOriginal


        IsMdlDirtyOriginally;


IsFastRestart



        UserDataLogSetting=struct(...
        'toutName','',...
        'xoutName','',...
        'pdName','',...
        'simlogName','');
    end

    methods

        function obj=ModelConfigClass(mdl)
            obj.Model=mdl;

            obj.cacheAndCopyConfigSet();


            obj.IsFastRestart=strcmp(get_param(mdl,'FastRestart'),'on');
            set_param(mdl,'FastRestart','off');


            [~,obj.SpidataName]=fileparts(tempname);


            obj.LogSimlog=false;
            obj.LogXout=false;
            obj.LogZC=false;
            obj.LogJacobian=false;
            obj.SscStiffString='[]';
            obj.SscStiffTimes=[];


            obj.OrigSolverProfileInfoName=get_param(mdl,'SolverProfileInfoName');
            obj.OrigSaveSolverProfileInfo=get_param(mdl,'SaveSolverProfileInfo');
            obj.OrigSolverProfileInfoMaxSize=get_param(mdl,'SolverProfileInfoMaxSize');
            obj.OrigSolverProfileInfoLevel=get_param(mdl,'SolverProfileInfoLevel');


            tStart=obj.OrigConfigSet.get_param('StartTime');
            tStop=obj.OrigConfigSet.get_param('StopTime');
            obj.StartTime=tStart;
            obj.FromTime=tStart;
            obj.ToTime=tStop;
            obj.NumPDEvents='200000';
        end


        function delete(obj)
            obj.removeTempDir();
        end



        function updateModelConfig(obj)
            set_param(obj.Model,'FastRestart','off');
            obj.cacheAndCopyConfigSet();
        end


        function restoreConfig(obj)
            if bdIsLoaded(obj.Model)==0
                return;
            end

            if~obj.IsConfigSetOriginal

                obj.restoreOriginalConfigSet();

                set_param(obj.Model,'SolverProfileInfoName',obj.OrigSolverProfileInfoName);
                set_param(obj.Model,'SaveSolverProfileInfo',obj.OrigSaveSolverProfileInfo);
                set_param(obj.Model,'SolverProfileInfoMaxSize',obj.OrigSolverProfileInfoMaxSize);
                set_param(obj.Model,'SolverProfileInfoLevel',obj.OrigSolverProfileInfoLevel);

                try
                    simscape.internal.stiffness_times(obj.Model,[]);
                catch
                end


                if obj.IsFastRestart
                    set_param(obj.Model,'FastRestart','on');
                end


                set_param(obj.Model,'Dirty',obj.IsMdlDirtyOriginally);
            end
        end


        function configForProfiler(obj)
            obj.updateOriginalLoggingItems();


            set_param(obj.Model,'FastRestart','off');


            obj.modifyConfigSetCopyForProfiling();


            obj.configModelForZC();
            obj.configModelForXout();
            obj.configModelForSimlog();


            obj.attachModifiedConfigSetCopy();



            set_param(obj.Model,'SolverProfileInfoName','pd');
            set_param(obj.Model,'SaveSolverProfileInfo','yes');
            if ischar(obj.FromTime)
                obj.FromTime=solverprofiler.util.utilInterpretVal(obj.FromTime);
            end
            set_param(obj.Model,'SolverProfileInfoCollectionStartTime',obj.FromTime);
            set_param(obj.Model,'SolverProfileInfoMaxSize',obj.NumPDEvents);
            set_param(obj.Model,'SolverProfileInfoLevel',struct('base',0));

            if obj.LogJacobian
                set_param(obj.Model,'SolverProfileInfoLevel',struct('jacobian',1));
            else
                set_param(obj.Model,'SolverProfileInfoLevel',struct('jacobian',0));
            end

            try
                simscape.internal.stiffness_times(obj.Model,obj.SscStiffTimes);
            catch
            end
        end


        function restored_xout=restoreXout(~,spidata)
            import solverprofiler.util.*
            restored_xout=[];
            if ismember('pd',spidata.who)
                numSignal=length(spidata.pd.continuousStateValue);
                if isempty(spidata.pd.continuousStateValue(1).time)
                    return;
                end
                pd_temp=spidata.pd.continuousStateValue(1).time;
                isSPStartFromZero=pd_temp(1);

                if~isSPStartFromZero
                    spidata_tout=spidata.tout;
                else
                    [~,inds,~]=intersect(spidata.tout,pd_temp(1));
                    spidata_tout=spidata.tout(inds:end);
                end

                restored_xout=zeros(length(spidata_tout),numSignal);
                for i=1:numSignal
                    pd_csv=spidata.pd.continuousStateValue(i);
                    if~isempty(pd_csv.value)
                        restored_xout(:,i)=restoreStateExtrap(pd_csv.time,pd_csv.value,spidata_tout);
                    end
                end
            end
        end


        function parseUserDataToWorkSpace(obj,spidata,varargin)


            warnID='MATLAB:nonExistentField';
            os=warning('off',warnID);
            c=onCleanup(@()warning(os.state,warnID));

            if~strcmp(obj.OrigConfigSet.get_param('ReturnWorkspaceOutputs'),'on')

                xoutName=obj.UserDataLogSetting.xoutName;
                restored_xout=[];
                if~isempty(xoutName)&&~isempty(get(spidata,'pd'))
                    restored_xout=obj.restoreXout(spidata);
                    assignin('base',xoutName,restored_xout);
                end

                toutName=obj.UserDataLogSetting.toutName;
                if~isempty(toutName)&&~isempty(get(spidata,'tout'))
                    spidata_tout=get(spidata,'tout');
                    [row,~]=size(restored_xout);
                    if row>0&&row<length(spidata.tout)
                        spidata_tout=spidata.tout(end-row+1:end);
                    end
                    assignin('base',toutName,spidata_tout);
                end

                simlogName=obj.UserDataLogSetting.simlogName;
                simlogExists=spidata.isprop('simlog');
                if~isempty(simlogName)&&simlogExists&&~isempty(get(spidata,'simlog'))
                    assignin('base',simlogName,get(spidata,'simlog'));
                end


                spidataNames=spidata.who;
                fields={'pd','tout','simlog','xout'};
                for i=1:size(spidataNames,1)
                    if(~ismember(spidataNames{i},fields))
                        otherInfo=spidataNames{i};
                        assignin('base',otherInfo,get(spidata,otherInfo));
                    end
                end
            else

                xoutName=obj.UserDataLogSetting.xoutName;
                restored_xout=[];
                if~isempty(xoutName)&&...
                    ismember('pd',spidata.who)&&...
                    ~isempty(spidata.pd.continuousStateValue)

                    restored_xout=obj.restoreXout(spidata);
                    spidata_copy.(xoutName)=restored_xout;
                end

                toutName=obj.UserDataLogSetting.toutName;
                if~isempty(toutName)
                    spidata_tout=get(spidata,'tout');
                    [row,~]=size(restored_xout);
                    if row>0&&row<length(spidata.tout)
                        spidata_tout=spidata.tout(end-row+1:end);
                    end
                    spidata_copy.(toutName)=spidata_tout;
                end

                simlogName=obj.UserDataLogSetting.simlogName;
                simlogExists=spidata.isprop('simlog');
                if~isempty(simlogName)&&simlogExists&&~isempty(get(spidata,'simlog'))
                    spidata_copy.(simlogName)=spidata.simlog;
                end

                spidataNames=spidata.who;
                fields={'pd','simlog','tout'};
                for i=1:length(spidataNames)
                    if(~ismember(spidataNames{i},fields))
                        spidata_copy.(spidataNames{i})=spidata.(spidataNames{i});
                    end
                end

                spidata_copy.SimulationMetadata=spidata.SimulationMetadata;
                spidata_copy.ErrorMessage=spidata.ErrorMessage;










                if(nargin>2&&varargin{1}==1)
                    assignin('base','ans',spidata_copy);
                else
                    assignin('base',obj.OrigConfigSet.get_param('ReturnWorkspaceOutputsName'),spidata_copy);
                end
            end
        end

        function varName=getSimulationOutputVarName(obj)
            varName=obj.SpidataName;
        end

        function flag=isXoutLogged(obj)
            flag=obj.LogXout;
        end

        function flag=isXoutStreamedIfLogged(obj)
            if strcmp(obj.XoutFormat,'disk')
                flag=true;
            else
                flag=false;
            end
        end

        function filePath=getXoutFilePath(obj)
            if isempty(obj.XoutLocation)||isempty(obj.XoutName)
                filePath=[];
            else
                filePath=fullfile(obj.XoutLocation,obj.XoutName);
            end
        end

        function setPDLength(obj,lengthStr)
            obj.NumPDEvents=lengthStr;
        end

        function setFromTime(obj,fromTimeStr)
            obj.FromTime=fromTimeStr;
            if str2double(obj.StartTime)>str2double(obj.FromTime)
                obj.StartTime=obj.FromTime;
            end
        end

        function setToTime(obj,toTimeStr)
            obj.ToTime=toTimeStr;
        end

        function enableZCLogging(obj)
            obj.LogZC=true;
        end

        function disableZCLogging(obj)
            obj.LogZC=false;
        end

        function enableStateLogging(obj)
            obj.LogXout=true;
        end

        function disableStateLogging(obj)
            obj.LogXout=false;
        end

        function enableSimscapeStateLogging(obj)
            obj.LogSimlog=true;
        end

        function disableSimscapeStateLogging(obj)
            obj.LogSimlog=false;
        end

        function enableJacobianLogging(obj)
            obj.LogJacobian=true;
        end

        function disableJacobianLogging(obj)
            obj.LogJacobian=false;
        end

        function times=getSscStiffTimes(obj)
            times=obj.SscStiffString;
        end

        function setSscStiffTimes(obj,times)
            obj.SscStiffString=times;

            if isempty(times)
                ts=[];
            else
                if ischar(obj.FromTime)
                    fromTime=solverprofiler.util.utilInterpretVal(obj.FromTime);
                else
                    fromTime=obj.FromTime;
                end

                if ischar(obj.ToTime)
                    toTime=solverprofiler.util.utilInterpretVal(obj.ToTime);
                else
                    toTime=obj.ToTime;
                end

                ts=eval(times);
                ts=unique(ts);
                ts=ts(ts>=fromTime&ts<=toTime);
                [m,n]=size(ts);%#ok
                if n>1
                    ts=ts';
                end
            end

            obj.SscStiffTimes=ts;
        end
    end



    methods(Access=private)


        function dir=getTempDir(obj)
            dir=obj.TempDir;
        end


        function setTempDir(obj,dir)
            obj.TempDir=dir;
        end


        function createTempDir(obj)
            dirname=tempname;
            mkdir(dirname);
            obj.setTempDir(dirname);
        end


        function removeTempDir(obj)
            if~isempty(obj.getTempDir())
                rmdir(obj.getTempDir(),'s');
                obj.setTempDir([]);
            end
        end








        function determineStatesLoggingMode(obj)
            load_system(obj.Model);
            if strcmp(get_param(obj.Model,'LoggingToFile'),'on')&&...
                strcmp(get_param(obj.Model,'SaveFormat'),'Dataset')
                obj.XoutFormat='disk';
            else
                obj.XoutFormat='memory';
            end
        end


        function modifyConfigSetCopyForProfiling(obj)
            obj.ConfigSetCopy.set_param('StartTime',obj.StartTime);
            obj.ConfigSetCopy.set_param('StopTime',obj.ToTime);
            obj.ConfigSetCopy.set_param('LimitDataPoints','off');
            obj.ConfigSetCopy.set_param('Decimation','1');
            obj.ConfigSetCopy.set_param('SaveTime','On');
            obj.ConfigSetCopy.set_param('TimeSaveName','tout');
            if strcmp(get_param(obj.Model,'SolverType'),'Variable-step')
                obj.ConfigSetCopy.set_param('OutputOption','RefineOutputTimes');
            end
            obj.ConfigSetCopy.set_param('ReturnWorkspaceOutputs','on');
            obj.ConfigSetCopy.set_param('ReturnWorkspaceOutputsName',obj.SpidataName);
        end


        function configModelForSimlog(obj)
            try
                if(obj.LogSimlog)
                    obj.ConfigSetCopy.set_param('SimscapeLogSimulationStatistics','on');
                    obj.ConfigSetCopy.set_param('SimscapeLogName','simlog');
                    if(strcmp(obj.ConfigSetCopy.get_param('SimscapeLogType'),'none'))
                        obj.ConfigSetCopy.set_param('SimscapeLogType','all');
                    end
                else
                    obj.ConfigSetCopy.set_param('SimscapeLogType','none');
                end
            catch
            end
        end


        function configModelForZC(obj)
            if obj.LogZC
                set_param(obj.Model,'SolverProfileInfoLevel',struct('zcsig',1));
            else
                set_param(obj.Model,'SolverProfileInfoLevel',struct('zcsig',0));
            end
        end


        function configModelForXout(obj)
            if obj.LogXout
                obj.determineStatesLoggingMode();
                obj.removeTempDir();

                if obj.isXoutStreamedIfLogged()


                    obj.ConfigSetCopy.set_param('InspectSignalLogs','off');



                    obj.ConfigSetCopy.set_param('SaveState','on');
                    obj.ConfigSetCopy.set_param('StateSaveName','xout');
                    set_param(obj.Model,'SolverProfileInfoLevel',struct('cstate',0));



                    obj.createTempDir();
                    obj.XoutLocation=obj.getTempDir();
                    obj.XoutName=[obj.Model,'_xout.mat'];
                    obj.ConfigSetCopy.set_param('LoggingFileName',fullfile(obj.XoutLocation,obj.XoutName));
                else


                    obj.ConfigSetCopy.set_param('SaveState','off');
                    set_param(obj.Model,'SolverProfileInfoLevel',struct('cstate',1));
                end
            else
                obj.ConfigSetCopy.set_param('SaveState','off');
                set_param(obj.Model,'SolverProfileInfoLevel',struct('cstate',0));

            end
        end



        function updateOriginalLoggingItems(obj)
            saveTout=obj.OrigConfigSet.get_param('SaveTime');
            saveXout=obj.OrigConfigSet.get_param('SaveState');
            savePd=get_param(obj.Model,'SaveSolverProfileInfo');
            try
                if strcmp(obj.ConfigSetCopy.get_param('SimscapeLogType'),'none')
                    saveSimlog='off';
                else
                    saveSimlog='on';
                end
            catch
                saveSimlog='off';
            end
            obj.UserDataLogSetting.toutName='';
            obj.UserDataLogSetting.xoutName='';
            obj.UserDataLogSetting.pdName='';
            obj.UserDataLogSetting.simlogName='';

            if strcmp(saveTout,'on')
                obj.UserDataLogSetting.toutName=obj.OrigConfigSet.get_param('TimeSaveName');
            end

            if strcmp(saveXout,'on')
                obj.UserDataLogSetting.xoutName=obj.OrigConfigSet.get_param('StateSaveName');
            end

            if strcmp(savePd,'on')
                obj.UserDataLogSetting.pdName=get_param(obj.Model,'SolverProfileInfoName');
            end

            if strcmp(saveSimlog,'on')
                obj.UserDataLogSetting.simlogName=obj.OrigConfigSet.get_param('SimscapeLogName');
            end
        end


        function cacheAndCopyConfigSet(obj)

            obj.IsMdlDirtyOriginally=get_param(obj.Model,'Dirty');


            [obj.OrigConfigSet,obj.ConfigSetCopy]=obj.getConfigSet(obj.Model);
        end


        function attachModifiedConfigSetCopy(obj)
            attachConfigSet(obj.Model,obj.ConfigSetCopy);
            setActiveConfigSet(obj.Model,obj.ConfigSetCopy.Name);
            obj.IsConfigSetOriginal=false;
        end



        function restoreOriginalConfigSet(obj)

            currentConfigSet=getActiveConfigSet(obj.Model);
            if strcmp(currentConfigSet.Name,obj.ConfigSetCopy.Name)
                setActiveConfigSet(obj.Model,obj.OrigConfigSet.Name);
                detachConfigSet(obj.Model,obj.ConfigSetCopy.Name);
            end
            obj.IsConfigSetOriginal=true;
        end

    end



    methods(Static)


        function[origConfigSet,configSetCopy]=getConfigSet(mdl)
            load_system(mdl);
            origConfigSet=getActiveConfigSet(mdl);


            names=getConfigSets(mdl);
            for i=1:length(names)
                csName=names{i};
                index=regexp(csName,'SPI_TEMP_');






                if~isempty(index)&&index(1)==1&&~strcmp(origConfigSet.Name,csName)
                    detachConfigSet(mdl,csName);
                end
            end


            if isa(origConfigSet,'Simulink.ConfigSetRef')
                trueOrigConfigSet=origConfigSet.getRefConfigSet;
                configSetCopy=trueOrigConfigSet.copy;
            else
                configSetCopy=origConfigSet.copy;
            end

            newName=['SPI_TEMP_',origConfigSet.Name];
            configSetCopy.set_param('Name',newName);
        end

    end

end
