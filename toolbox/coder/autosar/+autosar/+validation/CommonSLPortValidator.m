classdef CommonSLPortValidator<autosar.validation.PhasedValidator





    methods(Access=public)
        function this=CommonSLPortValidator(modelHandle)
            this@autosar.validation.PhasedValidator('ModelHandle',modelHandle);
        end
    end

    methods(Access=protected)

        function verifyPostProp(this,hModel)
            assert(isscalar(hModel)&&ishandle(hModel),'hModel is not a handle');
            this.verifyServerSubsystemArg(hModel);
        end

    end

    methods(Access=private)

        function verifyServerSubsystemArg(this,hModel)
            if Simulink.internal.useFindSystemVariantsMatchFilter()
                allSubSystemsH=find_system(hModel,'MatchFilter',@Simulink.match.activeVariants,...
                'Type','block','BlockType','SubSystem');
            else
                allSubSystemsH=find_system(hModel,'Type','block','BlockType','SubSystem');
            end
            for i=1:length(allSubSystemsH)
                if autosar.validation.ExportFcnValidator.isServerSubSys(allSubSystemsH(i))
                    this.checkSubsystemArgDataType(...
                    hModel,get_param(allSubSystemsH(i),'Handle'));
                end
            end
        end

        function checkSubsystemArgDataType(this,hModel,ssBlock)
            cs=getActiveConfigSet(hModel);
            maxShortNameLength=get_param(cs,'AutosarMaxShortNameLength');
            if Simulink.CodeMapping.isAutosarAdaptiveSTF(hModel)
                supportMatrixIO=true;
            else
                supportMatrixIO=strcmpi(...
                get_param(cs,'AutosarMatrixIOAsArray'),'on');
            end


            inArgs=find_system(ssBlock,'SearchDepth',1,...
            'BlockType','ArgIn');
            outArgs=find_system(ssBlock,'SearchDepth',1,...
            'BlockType','ArgOut');
            allSSinout=[inArgs;outArgs];
            for ii=1:length(allSSinout)
                blkObj=get_param(allSSinout(ii),'Object');
                blkType=blkObj.BlockType;
                blkPortH=blkObj.PortHandles;
                blkPath=blkObj.getFullName;
                if strcmp(blkType,'ArgIn')
                    thePort=blkPortH.Outport;
                else
                    thePort=blkPortH.Inport;
                end
                dataTypeName=get_param(thePort,'CompiledPortDataType');
                if autosar.validation.AutosarUtils.isErrorArgument(hModel,blkPath)
                    autosar.validation.AutosarUtils.checkDataTypeForErrArg(hModel,...
                    blkPath,dataTypeName,maxShortNameLength);
                else
                    this.AutosarUtilsValidator.checkDataType(blkPath,dataTypeName,maxShortNameLength,...
                    supportMatrixIO);
                end
            end

        end
    end

end


