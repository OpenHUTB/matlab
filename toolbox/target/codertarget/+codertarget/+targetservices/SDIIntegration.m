classdef(Sealed,Hidden)SDIIntegration<handle


    properties(SetAccess='private',GetAccess='public')
ModelName
ConfigSet
TgtConnMgr
        SupportsTargetServices=false;
TransportType
    end
    methods(Access='private')
        function hObj=SDIIntegration(model,hCS)
            hObj.ModelName=model;
            hObj.ConfigSet=hCS;
            hObj.TransportType=codertarget.attributes.getExtModeData('TransportType',hCS);
            hObj.SupportsTargetServices=codertarget.targetservices.needsCommService(hCS);
        end
        function delete(hObj)
            hObj.stopSDI;
        end
    end
    methods
        function lStartSDI=startSDI(hObj)
            lStartSDI=false(1,numel(hObj));
            for ii=1:numel(hObj)
                obj=hObj(ii);
                if obj.SupportsTargetServices
                    model=obj.ModelName;
                    lStartSDI(ii)=false;
                    try
                        buildDirStruct=RTW.getBuildDir(model);
                        if codertarget.targetservices.needsCommService(obj.ConfigSet)
                            obj.TgtConnMgr=coder.internal.connectivity.TgtConnMgr.load(model,buildDirStruct.BuildDirectory);
                            if~isempty(obj.TgtConnMgr)
                                switch(obj.TransportType)
                                case 'serial'
                                    serialport=regexprep(codertarget.attributes.getExtModeData('COMPort',obj.ConfigSet),'\''','');
                                    if ispc
                                        serialport=strcat('COM',serialport);
                                    end
                                    baudrate=str2double(codertarget.attributes.getExtModeData('Baudrate',obj.ConfigSet));
                                    obj.TgtConnMgr.start('transport','serial','serialport',serialport,'baudrate',baudrate);
                                case 'tcp/ip'
                                    host=regexprep(codertarget.attributes.getExtModeData('IPAddress',obj.ConfigSet),'\''','');
                                    port=codertarget.targetservices.getTargetServiceArgs(obj.ConfigSet);
                                    obj.TgtConnMgr.start('transport','tcpip','host',host,'port',str2double(port));
                                case 'custom'
                                    assert(false,DAStudio.message('codertarget:build:SDINotSupportForThisTransport'));
                                end
                                lStartSDI(ii)=true;
                            end
                        end
                    catch e
                        MSLDiagnostic('codertarget:build:ExternalModeCallbackError','Connect',char([10,e.message])).reportAsWarning;
                        obj.TgtConnMgr=[];
                        lStartSDI(ii)=false;
                    end
                    if lStartSDI(ii)
                        if codertarget.targetservices.needsCommService(obj.ConfigSet)
                            e=coder.internal.connectivity.ToAsyncQueueAppSvc.startSDIVisualizations(obj.ModelName);
                            if~isempty(e)
                                MSLDiagnostic('codertarget:build:ExternalModeCallbackError','StartSDI',char([10,e.message])).reportAsWarning;
                                obj.TgtConnMgr.stop();
                                obj.TgtConnMgr=[];
                            end
                            isStreamingProfilerSupported=codertarget.attributes.supportTargetServicesFeature(obj.ModelName,'StreamingProfilerAppSvc');
                            isTaskProfilingEnabled=isequal(get_param(obj.ModelName,'CodeExecutionProfiling'),'on');
                            if isStreamingProfilerSupported&&isTaskProfilingEnabled
                                try
                                    hmiOpts.RecordOn=1;
                                    hmiOpts.VisualizeOn=1;
                                    hmiOpts.CommandLine=false;
                                    hmiOpts.StartTime=get_param(obj.ModelName,'SimulationTime');
                                    hmiOpts.StopTime=inf;
                                    try
                                        hmiOpts.StopTime=evalin('base',get_param(obj.ModelName,'StopTime'));
                                    catch
                                        hmiOpts.StopTime=inf;
                                    end
                                    try

                                        isESBEnabled=codertarget.utils.isESBEnabled(obj.ModelName);
                                        if isESBEnabled
                                            hmiOpts.StopTime=inf;
                                        end
                                    catch
                                    end
                                    hmiOpts.EnableRollback=slprivate('onoff',get_param(obj.ModelName,'EnableRollback'));
                                    hmiOpts.SnapshotInterval=get_param(obj.ModelName,'SnapshotInterval');
                                    hmiOpts.NumberOfSteps=get_param(obj.ModelName,'NumberOfSteps');
                                    Simulink.HMI.slhmi('sim_start',obj.ModelName,hmiOpts);
                                catch
                                end
                            end
                        end
                    end
                end
            end
        end
        function stopSDI(hObj)
            for ii=1:numel(hObj)
                obj=hObj(ii);
                if~isempty(obj.TgtConnMgr)&&obj.SupportsTargetServices
                    try
                        obj.TgtConnMgr.stop();
                    catch e
                        MSLDiagnostic('codertarget:build:ExternalModeCallbackError','StopSDI',char([10,e.message])).reportAsWarning;
                    end
                    obj.TgtConnMgr=[];
                end
            end
        end
    end
    methods(Static)
        function out=manageInstance(action,in)
            mlock;
            out=[];
            persistent LocalStaticObject;
            if isempty(LocalStaticObject)
                LocalStaticObject=containers.Map;
            end
            if isequal(action,'clearAll')
                lVals=LocalStaticObject.values;
                for ii=1:LocalStaticObject.length
                    lVals{ii}.stopSDI;
                end
                LocalStaticObject.remove(LocalStaticObject.keys);
            else
                validateattributes(in,{'double','char','Simulink.ConfigSet'},{'nonempty'});
                if ischar(in)||isnumeric(in)
                    modelName=get_param(in,'FileName');
                    hCS=getActiveConfigSet(in);
                elseif isa(in,'Simulink.ConfigSet')
                    hCS=in;
                    modelName=get_param(hCS.getModel,'FileName');
                end
                switch action
                case{'get','create'}
                    if~LocalStaticObject.isKey(modelName)
                        LocalStaticObject(modelName)=codertarget.targetservices.SDIIntegration(get_param(hCS.getModel,'Name'),hCS);
                    end
                    out=LocalStaticObject(modelName);
                case 'clear'
                    if LocalStaticObject.isKey(modelName)
                        lVal=LocalStaticObject(modelName);
                        lVal.stopSDI;
                        LocalStaticObject.remove(modelName);
                    end
                end
            end
        end
    end
end