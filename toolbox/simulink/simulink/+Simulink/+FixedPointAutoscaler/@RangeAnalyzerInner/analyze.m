function fileNames=analyze(obj)





    cleanupObj=obj.enterTracePoint('Invoke Polyspace-based range analysis');%#ok<NASGU>

    setupForAnalysis(obj);
    [sldvstatus,fileNames,sldvmessages]=runDesignVerifier(obj);
    processSLDVStatus(obj,sldvstatus,sldvmessages);

    function processSLDVStatus(obj,sldvstatus,sldvmessages)


        cleanupObj=obj.enterTracePoint('Process Design Verifier Status');%#ok<NASGU>

        if sldvstatus~=1
            if ischar(sldvmessages)

                ME=fxptui.FPTMException('SimulinkFixedPoint:autoscale:RangeAnalysisIncompatible',...
                strrep(sldvmessages,'\','\\'),...
                get_param(obj.model,'Handle'));
            else

                ME=fxptui.FPTMException('Fixpt:RangeAnalysisIncompatible',...
                message('FixedPointTool:fixedPointTool:msgDeriveFailed').getString(),...
                get_param(obj.model,'Handle'));
                for i=1:numel(sldvmessages)

                    if isempty(sldvmessages(i).msgid)
                        sldvmessages(i).msgid='SimulinkFixedPoint:autoscale:Generic';
                    end
                    cause=fxptui.FPTMException(['FixedPointTool:fixedPointTool:',sldvmessages(i).msgid],...
                    strrep(sldvmessages(i).msg,'\','\\'),...
                    sldvmessages(i).objH);
                    ME=addCause(ME,cause);
                end
            end
            throw(ME);
        end

        function setupForAnalysis(obj)



            cleanupObj=obj.enterTracePoint('Setup for Analysis');%#ok<NASGU>


            [refMdls,~]=SimulinkFixedPoint.AutoscalerUtils.getMdlRefs(obj.model);
            cellfun(@load_system,refMdls);



            obj.status.oldOpenSystems=find_system('type','block_diagram');


            set_param(obj.model,'InRangeAnalysisMode','on');

            function[sldvstatus,fileNames,sldvmessages]=runDesignVerifier(obj)



                cleanupObj=obj.enterTracePoint('Run Design Verifier');%#ok<NASGU>

                options=sldvdefaultoptions;
                options.Mode='DesignErrorDetection';
                options=Sldv.utils.disableDedChecks(options);
                options.DesignMinMaxCheck='on';
                options.ReduceRationalApprox='off';
                options.MakeOutputFilesUnique='off';
                options.OutputDir='fixpt_output/$ModelName$';
                options.DataFileName='$ModelName$_fixptdata';
                options.Parameters='off';
                options.MaxProcessTime=realmax/2;
                if slsvTestingHook('RADisableSFunSupport')>0
                    options.SFcnSupport='off';
                end

                if obj.compatCheckOnly
                    fileNames=[];
                    if isempty(obj.subsystem)
                        [sldvstatus,sldvmessages]=sldvcompat(obj.model,options);
                    else
                        [sldvstatus,sldvmessages]=sldvcompat(obj.subsystem,options);
                    end
                else
                    if isempty(obj.subsystem)
                        [sldvstatus,fileNames,~,sldvmessages]=sldvrun(obj.model,options);
                    else
                        [sldvstatus,fileNames,~,sldvmessages]=sldvrun(obj.subsystem,options);
                    end
                end



