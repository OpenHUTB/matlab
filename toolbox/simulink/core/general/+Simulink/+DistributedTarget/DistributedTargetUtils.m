


classdef DistributedTargetUtils<handle
    methods(Static=true)

        function ret=getIndexOfHardwareNode(obj)
            assert(isa(obj,'Simulink.DistributedTarget.HardwareNode'));
            arch=obj.ParentArchitecture;
            assert(~isempty(arch));
            ret=0;
            for idx=1:length(arch.Nodes)
                node=arch.Nodes(idx);
                if isequal(node,obj)
                    return;
                elseif isa(node,'Simulink.DistributedTarget.HardwareNode')
                    ret=ret+1;
                end
            end
        end

        function generateCode(modelName,codeFormat,mdlRefTargetType)


            isSFcnOrAcceleratorOrModelrefSimTarget=...
            ~isempty(strfind(codeFormat,'S-Function'))||...
            strcmpi(mdlRefTargetType,'SIM');

            stf=get_param(modelName,'SystemTargetFile');

            if~strcmp(stf,'rsim.tlc')&&~strcmp(stf,'raccel.tlc')&&...
                ~isSFcnOrAcceleratorOrModelrefSimTarget



                Simulink.DistributedTarget.generateHDLForNode(modelName);
            end
        end

        function retVal=requiresRTWBuild(refModel,topModel,mdlRefTargetType)
            retVal=true;



            retVal=~(Simulink.DistributedTarget.isMappedToHardwareNode(refModel,topModel)&&...
            strcmp(mdlRefTargetType,'RTW')&&...
            strcmp(get_param(topModel,'RapidAcceleratorSimStatus'),'inactive')&&...
            ~strcmp(get_param(topModel,'SystemTargetFile'),'rsim.tlc'));

            if~retVal
                mdlsToClose=slprivate('load_model',refModel);


                retVal=~isempty(find_system(...
                refModel,'FindAll','on','FollowLinks','on','IncludeCommented','off',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'LookUnderMasks','all','regexp','on',...
                'SFBlockType','Chart|MATLAB Function|Truth Table|State Transition Table|Test Sequence'));
                slprivate('close_models',mdlsToClose);
            end
        end

        function[hasMultipleSW,nodeToBuild]=hasMultipleSoftwareNodes(topMdl)
            hasMultipleSW=false;
            nodeToBuild='';
            if~isempty(topMdl)&&isempty(strfind(topMdl,':'))
                if~bdIsLoaded(topMdl)
                    return;
                end

                if strcmp(get_param(topMdl,'EnableConcurrentExecution'),'off')||...
                    strcmp(get_param(topMdl,'ExplicitPartitioning'),'off')||...
                    strcmp(get_param(topMdl,'SimulationMode')','Accelerator')||...
                    (strcmp(get_param(topMdl,'EnableConcurrentExecution'),'on')&&...
                    strcmp(get_param(topMdl,'ConcurrentTasks'),'off'))
                    return;
                end

                stf=get_param(topMdl,'SystemTargetFile');
                if strcmp(stf,'accel.tlc')||strcmp(stf,'raccel.tlc')
                    return;
                end

                mgr=get_param(topMdl,'MappingManager');
                if isempty(mgr)
                    return;
                end

                mapping=mgr.getActiveMappingFor('DistributedTarget');
                if isempty(mapping)
                    return;
                end

                arch=mapping.Architecture;
                if isempty(arch)
                    return;
                end

                if arch.hasMultipleSoftwareNodes()
                    hasMultipleSW=true;
                    nodeToBuild=arch.getSoftwareNodeForBuild();
                end
            end
        end

        function attr=getArchAttribute(xmlNode,name)


            attr='';
            if isfield(xmlNode,[name,'__Attribute'])
                potentialAttr=xmlNode.([name,'__Attribute']);
                if~isa(potentialAttr,'missing')
                    attr=num2str(potentialAttr);
                end
            end
        end

    end
end


