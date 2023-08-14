classdef ToAsyncQueueAppSvc<coder.internal.connectivity.TgtConnAppSvc







    properties(Access=public)


        isRapidAccel;




        buildDirPath;
        topModelName;







        streamingClients;
    end



    methods(Access={?coder.internal.connectivity.TgtConnMgr})
        function obj=ToAsyncQueueAppSvc()
            [topMdlName,topMdlBuildArgs]=coder.internal.connectivity.TgtConnMgr.getTopModelAndBuildArgs();


            obj.isRapidAccel=topMdlBuildArgs.IsRapidAccelerator;



            try
                buildDirStruct=RTW.getBuildDir(topMdlName);
                obj.buildDirPath=buildDirStruct.BuildDirectory;

            catch ME %#ok
                obj.buildDirPath=[];
            end
            obj.topModelName=topMdlName;



            obj.streamingClients=get_param(topMdlName,'StreamingClients');
            if isempty(obj.streamingClients)
                obj.streamingClients=Simulink.HMI.StreamingClients(topMdlName);
            end
        end
    end

    methods(Access=public)
        function isNeeded=isNeeded(obj)%#ok
            [topMdlName,~]=coder.internal.connectivity.TgtConnMgr.getTopModelAndBuildArgs();
            isNeeded=coder.internal.connectivity.ToAsyncQueueAppSvc.isToAsyncQueueBlockInsertionNeeded(topMdlName);
        end

        function setupBeforeTLC(obj,mdl)%#ok
            if ishandle(mdl)
                mdl=getfullname(mdl);
            end




            [topMdlName,topMdlBuildArgs]=coder.internal.connectivity.TgtConnMgr.getTopModelAndBuildArgs();
            if isempty(topMdlBuildArgs)
                isMdlRef=false;
            else
                isTopMdl=strcmp(mdl,topMdlName);
                isMdlRef=~isTopMdl||(isTopMdl&&~strcmp(topMdlBuildArgs.ModelReferenceTargetType,'NONE'));
            end
            if(isMdlRef)
                mdlRefInstSigs=get_param(mdl,'InstrumentedSignals');
                mdlRefHasTAQBlocks=~isempty(mdlRefInstSigs)&&mdlRefInstSigs.Count>0;
                if mdlRefHasTAQBlocks


                    if~strcmp(get_param(mdl,'ModelReferenceNumInstancesAllowed'),'Single')
                        errid='Simulink:HMI:TAQAppSvcNoMultiInstMRSupport';
                        errmsg=DAStudio.message(errid,mdl);
                        err=MException(errid,errmsg);
                        throwAsCaller(err);
                    end
                end
            end
        end

        function cleanupAfterTLC(obj,mdl)%#ok
        end

        function codeStr=getIncludesAndDefinesCode(obj)%#ok
            codeStr='';
        end

        function codeStr=getBackgroundTaskCode(obj)%#ok
            codeStr='';
        end

        function codeStr=getMdlInitCode(obj)%#ok
            codeStr=[...
'if (startToAsyncQueueTgtAppSvc()) {'...
            ,'    result = "Could not start ToAsyncQueue app service";'...
            ,'    return(result);'...
            ,'}'
            ];
        end

        function codeStr=getMdlTermCode(obj)%#ok
            codeStr='terminateToAsyncQueueTgtAppSvc();';
        end

        function codeStr=getPreStepCode(obj)%#ok
            codeStr='';
        end

        function codeStr=getPostStepCode(obj)%#ok
            codeStr='';
        end

        function start(obj,argMap)%#ok
            coder.internal.connectivity.ConnectToAsyncQueueAppSvc(...
            obj.tgtConnMgr.getTargetConnection(),...
            obj.topModelName,...
            obj.buildDirPath,...
            obj.isRapidAccel,...
            obj.streamingClients);
        end

        function stop(obj)%#ok
        end
    end
















    methods(Access=public,Static)
        function val=isToAsyncQueueBlockInsertionNeeded(mdl)

















            if ishandle(mdl)
                mdl=getfullname(mdl);
            end

            stf=get_param(mdl,'SystemTargetFile');
            isSLDRT=slfeature('ToAsyncQueueAppSvcForSLDRT')&&...
            (strcmp(stf,'sldrt.tlc')||...
            strcmp(stf,'sldrtert.tlc'));

            isCoderTarget=slfeature('ToAsyncQueueAppSvcForCoderTarget')&&...
            codertarget.attributes.supportTargetServicesFeature(mdl,'ToAsyncQueueAppSvc','CheckIfToAsynqBlocksPresent');

            val=isSLDRT||isCoderTarget;
        end

        function errorStatus=startSDIVisualizations(modelName)




            errorStatus=[];
            try
                hmiOpts.RecordOn=slprivate('onoff',get_param(modelName,'InspectSignalLogs'));
                hmiOpts.VisualizeOn=slprivate('onoff',get_param(modelName,'VisualizeSimOutput'));
                hmiOpts.CommandLine=false;
                hmiOpts.StartTime=get_param(modelName,'SimulationTime');
                hmiOpts.StopTime=inf;
                try
                    hmiOpts.StopTime=evalin('base',get_param(modelName,'StopTime'));
                catch
                    hmiOpts.StopTime=inf;
                end
                hmiOpts.EnableRollback=slprivate('onoff',get_param(modelName,'EnableRollback'));
                hmiOpts.SnapshotInterval=get_param(modelName,'SnapshotInterval');
                hmiOpts.NumberOfSteps=get_param(modelName,'NumberOfSteps');
                Simulink.HMI.slhmi('sim_start',modelName,hmiOpts);
            catch errorStatus
            end
        end
    end
end
