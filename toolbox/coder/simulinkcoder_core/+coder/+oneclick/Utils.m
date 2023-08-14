classdef Utils<handle




    properties(Constant)
        OneClickFeatureName='OnTargetOneClick';
        OneClickCustomHWFeatureName='OnTargetOneClickCustomHW';
    end

    methods(Static)
        function retVal=isModelRTT(modelOrCS)
            retVal=strcmp(get_param(modelOrCS,'SystemTargetFile'),...
            'realtime.tlc');
        end

        function retVal=isCustomHardwareBoard(modelOrCS)
            hardwareBoard=get_param(modelOrCS,'HardwareBoard');
            retVal=strcmp(hardwareBoard,'None')||...
            codertarget.utils.isTargetFrameworkTarget(hardwareBoard);
        end

        function[isEnabled,useDeployTerms]=isOneClickWorkflowEnabled(modelOrConfigSet,varargin)




            narginchk(1,3);

            p=inputParser;
            p.addParameter('SuppressExceptions',false,...
            @(x)validateattributes(x,{'logical'},{},...
            'isOneClickWorkflowEnabled','SuppressExceptions'));

            p.parse(varargin{:});

            suppressExceptions=p.Results.SuppressExceptions;

            isOneClickFeaturedOn=coder.oneclick.Utils.isFeaturedOn||...
            coder.oneclick.Utils.isCustomHWFeaturedOn;
            if~isOneClickFeaturedOn
                isEnabled=false;
                useDeployTerms=false;
                return;
            end

            try
                if ischar(modelOrConfigSet)
                    cs=getActiveConfigSet(modelOrConfigSet);
                else
                    cs=modelOrConfigSet;
                end
                simulinkCoderAvailable=coder.oneclick.Utils.isSimulinkCoderInstalledAndLicensed;
                [isEnabled,useDeployTerms]=coder.oneclick.Utils.isOnTargetOneClickEnabled(cs,simulinkCoderAvailable);
            catch ME
                isEnabled=false;
                useDeployTerms=false;
                if~suppressExceptions
                    rethrow(ME);
                end
            end
        end

        function isEnabled=isExtModeOneClickEnabled(model)
            isEnabled=strcmp(get_param(model,'ExtMode'),'on')&&...
            coder.oneclick.Utils.isOneClickWorkflowEnabled(model);
        end

        function val=isExtModeOneClickSim(model)

            modelCodegenMgr=coder.internal.ModelCodegenMgr.getInstance(model);
            assert(~isempty(modelCodegenMgr),...
            'isExtModeOneClickBuild can only be called during a build.');
            val=modelCodegenMgr.MdlRefBuildArgs.IsExtModeOneClickSim;
        end

        function featureOn
            slfeature(coder.oneclick.Utils.OneClickFeatureName,1);
            slfeature(coder.oneclick.Utils.OneClickCustomHWFeatureName,1);
        end

        function featureoff
            slfeature(coder.oneclick.Utils.OneClickFeatureName,0);
            slfeature(coder.oneclick.Utils.OneClickCustomHWFeatureName,0);
        end

        function val=isFeaturedOn
            val=isequal(...
            slfeature(coder.oneclick.Utils.OneClickFeatureName),1);
        end

        function val=isCustomHWFeaturedOn
            val=true;
        end

        function val=isRTTInstalledOriginal


            val=coder.oneclick.Utils.isFeaturedOn&&...
            ~isempty(which('realtime.getRegisteredTargets'))&&...
            ~isempty(realtime.getRegisteredTargets);
        end

        function val=isRTTInstalled


            val=coder.oneclick.Utils.isRTTInstalledOriginal;
            if slfeature('UnifiedTargetHardwareSelection')
                val=val||coder.oneclick.Utils.isAnySimulinkTargetInstalled;
            end
        end

        function val=isAnySimulinkTargetInstalled



            val=~isempty(which('codertarget.targethardware.getRegisteredSimulinkTargetHardwareNames'))&&...
            ~isempty(codertarget.targethardware.getRegisteredSimulinkTargetHardwareNames);
        end

        function simulinkCoderAvailable=isSimulinkCoderInstalledAndLicensed




            simulinkCoderAvailable=dig.isProductInstalled('Simulink Coder');
        end

        function[isEnabled,useDeployTerms]=isOnTargetOneClickEnabled(cs,isSimulinkCoderInstalledAndLicensed)




            assert(ismember(class(cs),{'Simulink.ConfigSet','Simulink.ConfigSetRef'}),...
            'cs was expected to be of type Simulink.ConfigSet, but got %s',...
            class(cs));


            if isa(cs,'Simulink.ConfigSetRef')
                cs=cs.getRefConfigSet;
            end


            if~isSimulinkCoderInstalledAndLicensed&&...
                coder.oneclick.Utils.isRTTInstalled&&...
                ~isequal(get_param(cs,'SystemTargetFile'),'raccel.tlc')&&...
                ~isequal(get_param(cs,'IsSLRTTarget'),'on')&&...
                ~isequal(get_param(cs,'SystemTargetFile'),'rsim.tlc')&&...
                ~coder.oneclick.Utils.isCustomHardwareBoard(cs)





                isEnabled=true;
                useDeployTerms=true;
            elseif strcmp(get_param(cs,'SystemTargetFile'),...
                'realtime.tlc')

                isEnabled=true;
                useDeployTerms=true;
            elseif any(strcmp(get_param(cs,'SystemTargetFile'),...
                {'sldrt.tlc','sldrtert.tlc','rtwin.tlc','rtwinert.tlc'}))

                isEnabled=true;
                useDeployTerms=true;
            elseif(isSimulinkCoderInstalledAndLicensed&&...
                ~isequal(get_param(cs,'SystemTargetFile'),'raccel.tlc')&&...
                codertarget.target.isCoderTarget(cs))


                isEnabled=codertarget.target.getIsOneClickEnabled(cs);
                useDeployTerms=isEnabled;
            elseif(isSimulinkCoderInstalledAndLicensed&&...
                coder.oneclick.Utils.isCustomHWFeaturedOn&&coder.oneclick.Utils.isGRTERT(cs))&&...
                ~isequal(get_param(cs,'IsSLRTTarget'),'on')


                isEnabled=true;
                useDeployTerms=false;
            elseif(strcmp(get_param(cs,'SystemTargetFile'),...
                'idelink_ert.tlc')||strcmp(get_param(cs,'SystemTargetFile'),...
                'idelink_grt.tlc'))




                isEnabled=false;
                useDeployTerms=false;
                if~isempty(cs.getModel)
                    codertarget.tools.deprecationNotification(get_param(cs.getModel,'Name'));
                end
            else

                isEnabled=false;
                useDeployTerms=false;
            end
        end

        function ret=isGRTERT(cs)
            if isobject(cs)
                ret=true;
                return;
            end
            isGRTTarget=cs.getComponent('Code Generation').getComponent('Target').isGRTTarget;
            isERTTarget=strcmp(get_param(cs,'IsERTTarget'),'on');
            ret=isGRTTarget||isERTTarget;
        end
    end
end




