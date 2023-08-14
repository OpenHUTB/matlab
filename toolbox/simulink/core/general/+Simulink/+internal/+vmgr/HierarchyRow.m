classdef(Hidden,Sealed)HierarchyRow<handle







    properties(SetAccess=private,Hidden=true)

        mParentRow=[];
        mChildRows={};

        mRowName=[];
        mBlockOrIOType=[];
        mVMBlockType=[];
        mObjectPath=[];

        mVariantChoiceInformation=[];
        mRefModelName=[];
        mStateFlowData=[];
        mVariantSimscapeBlockInfo=[];
        mSubsystemInformation=[];

        mVariantType=[];
        mModelValidationType=[];
        mVariantError=[];
        mIsInsideIgnoredBranch=[];
        mBlockParamCells={};
    end

    methods(Access=public,Hidden=true)
        function this=HierarchyRow(parentRow,rootModelOrBlockName,vmBlockType,variantChoiceInformation,objectPath)
            if isa(parentRow,'Simulink.internal.vmgr.HierarchyRow')
                parentRow.addChildRow(this);
            end

            this.mRowName=rootModelOrBlockName;
            this.setVMBlockType(vmBlockType);
            this.mObjectPath=objectPath;

            if isa(variantChoiceInformation,'Simulink.internal.vmgr.VariantChoiceInformation')
                this.mVariantChoiceInformation=variantChoiceInformation;
            else
                this.mVariantChoiceInformation=Simulink.internal.vmgr.VariantChoiceInformation();
            end
        end


        function isOrInsideIgnoredBranch=getIsOrInsideIgnoredBranch(this)
            isOrInsideIgnoredBranch=this.getIsStartOfIgnorableBranch()||this.getIsInsideIgnoredBranch();
        end



        function setVariantProperties(this,variantRowType,variantError)
            if Simulink.internal.vmgr.ValidationResultType.isValidValidationResultType(variantRowType)
                this.mVariantType=variantRowType;
            end
            this.mVariantError=variantError;
        end



        function setBlockParamInfo(this,blockParameterStruct)


            blockParamNames=fieldnames(blockParameterStruct);










            for idx=1:numel(blockParamNames)
                blockParamName=blockParamNames{idx};
                this.mBlockParamCells=[this.mBlockParamCells,{{blockParamName,blockParameterStruct.(blockParamName)}}];
            end
        end

        function setFlagonModelWideErrors(this)



            this.setIgnoredFlagonModel();
            this.mVariantType='Error';
        end

        function setIgnoredFlagonModel(this)
            this.mModelValidationType='Error';
        end



        function javaRowTreeSet=getJavaRow(this)

            this.computeBlockOrIOType();
            this.computeSpecialBlockInfo();

            HRowFcn=@com.mathworks.toolbox.simulink.variantmanager.HierarchyRow;
            LHRowFcn=@com.mathworks.toolbox.simulink.variantmanager.LazyHierarchyRow;

            HRowTreeSetFcn=@com.mathworks.toolbox.simulink.variantmanager.HierarchyRowTreeSet;


            if isequal(this.mVMBlockType,Simulink.variant.manager.VariantManagerBlockType.ModelReference)
                javaRow=LHRowFcn(this.mRowName,char(this.mBlockOrIOType),this.mRefModelName,this.getIsInsideIgnoredBranch(),this.mVariantChoiceInformation.toJava());
            else
                javaRow=HRowFcn(this.mRowName,char(this.mBlockOrIOType),this.mVariantChoiceInformation.toJava(),...
                this.mVariantType,this.mVariantError,this.mBlockParamCells,this.getSpecialBlockInfo(),this.getIsInsideIgnoredBranch());
            end
            javaRowTreeSet=HRowTreeSetFcn(javaRow);

            for i=1:numel(this.mChildRows)
                javaRowTreeSet.addChild(this.mChildRows{i}.getJavaRow());
            end
        end

        function setVMBlockType(this,vmBlockType)
            if isa(vmBlockType,'Simulink.variant.manager.VariantManagerBlockType')
                this.mVMBlockType=vmBlockType;
            end
        end
    end

    methods(Access=private,Hidden=true)
        function addChildRow(this,childRow)
            this.mChildRows{end+1}=childRow;
            childRow.setParentRow(this);
        end

        function setParentRow(this,parentRow)
            this.mParentRow=parentRow;
        end

        function isInsideIgnoredBranch=getIsInsideIgnoredBranch(this)
            if isempty(this.mIsInsideIgnoredBranch)

                if isa(this.mParentRow,'Simulink.internal.vmgr.HierarchyRow')
                    parentRow=this.mParentRow;
                    this.mIsInsideIgnoredBranch=parentRow.getIsStartOfIgnorableBranch()||parentRow.getIsInsideIgnoredBranch();
                elseif isempty(this.mParentRow)
                    this.mIsInsideIgnoredBranch=false;
                else
                    Simulink.variant.utils.assert(false,'Internal error: Invalid parent row for ''%s''.',this.mRowName);
                end
            end
            isInsideIgnoredBranch=this.mIsInsideIgnoredBranch;
        end

        function isStartOfIgnorableBranch=getIsStartOfIgnorableBranch(this)
            if this.getChoiceType()~=Simulink.internal.vmgr.ValidationResultType.None
                isStartOfIgnorableBranch=~((this.getChoiceType()==Simulink.internal.vmgr.ValidationResultType.Active)||(this.getChoiceType()==Simulink.internal.vmgr.ValidationResultType.Analyzed));
            else
                isStartOfIgnorableBranch=false;
            end

            if~(isStartOfIgnorableBranch||isempty(this.mModelValidationType))&&isempty(this.mParentRow)
                isStartOfIgnorableBranch=(this.mModelValidationType==Simulink.internal.vmgr.ValidationResultType.Error);
            end
        end

        function choiceType=getChoiceType(this)
            choiceType=this.mVariantChoiceInformation.mChoiceType;
        end

        function idx=getChildVariantTransitionRowIdx(this)
            parentRow=this.mParentRow;
            idx=0;
            for i=1:numel(parentRow.mChildRows)
                if isequal(parentRow.mChildRows{i}.mBlockOrIOType,Simulink.internal.vmgr.BlockOrIOType.VariantSFTransition)
                    idx=idx+1;
                    if parentRow.mChildRows{i}==this
                        return;
                    end
                end
            end
            idx=-1;
        end


        function specialBlockInfo=getSpecialBlockInfo(this)
            specialBlockInfo=java.util.HashMap;

            if~isempty(this.mSubsystemInformation)

                specialBlockInfo.put('SubsystemInformation',this.mSubsystemInformation.toJava());
            end


            if~isempty(this.mVariantSimscapeBlockInfo)
                javaObj=java.util.HashMap;
                variantSimscapeBlockInfos=fieldnames(this.mVariantSimscapeBlockInfo);
                for i=1:numel(variantSimscapeBlockInfos)
                    key=java.lang.String(['VariantSimscapeBlockInfo_',variantSimscapeBlockInfos{i}]);
                    value=java.lang.String(this.mVariantSimscapeBlockInfo.(variantSimscapeBlockInfos{i}));
                    javaObj.put(key,value);
                end
                specialBlockInfo.put('VariantSimscapeBlockInfo',javaObj);
            end

            if~isempty(this.mStateFlowData)
                javaObj=java.util.HashMap;
                stateFlowDataNames=fieldnames(this.mStateFlowData);
                for i=1:numel(stateFlowDataNames)
                    key=java.lang.String(['StateFlowData_',stateFlowDataNames{i}]);
                    value=java.lang.String(this.mStateFlowData.(stateFlowDataNames{i}));
                    javaObj.put(key,value);
                end
                specialBlockInfo.put('StateFlowData',javaObj);
            end
        end

        function setupStateFlowData(this,stateflowId,actionLanguage)
            this.mStateFlowData.StateflowId=num2str(stateflowId);
            if~isempty(actionLanguage)
                this.mStateFlowData.ActionLanguage=actionLanguage;
            end
        end

        function computeBlockOrIOType(this)
            if isempty(this.mVMBlockType)
                this.mBlockOrIOType=this.getBlockOrIOTypeChildNode();
            else
                this.mBlockOrIOType=this.getBlockOrIOTypeParentNode();
            end
        end

        function computeSpecialBlockInfo(this)

            if isequal(this.mVMBlockType,Simulink.variant.manager.VariantManagerBlockType.VariantPMConnector)

                this.mVariantSimscapeBlockInfo.Tag=get_param(this.mObjectPath,'ConnectorTag');
            end


            this.mSubsystemInformation=Simulink.internal.vmgr.SSInformation(this.mObjectPath);

            if this.mSubsystemInformation.getIsSubsystemReference()
                this.mBlockOrIOType=Simulink.internal.vmgr.BlockOrIOType.SubSystemReference;
            end

            if isequal(this.mVMBlockType,Simulink.variant.manager.VariantManagerBlockType.ModelReference)



                isProtected=strcmp(get_param(this.mObjectPath,'ProtectedModel'),'on');
                if isProtected
                    refModelName=get_param(this.mObjectPath,'ModelFile');
                    refModelName=strtok(refModelName,'.');
                else
                    refModelName=get_param(this.mObjectPath,'ModelName');
                end
                this.mRefModelName=refModelName;
            end

            if isequal(this.mVMBlockType,Simulink.variant.manager.VariantManagerBlockType.SFChart)

                chartId=[];
                chartInfo=Simulink.variant.utils.getSFObj(this.mObjectPath,Simulink.variant.utils.StateflowObjectType.CHART);
                chartActionLanguage='MATLAB';
                if~isempty(chartInfo)
                    chartId=chartInfo.Id;
                    chartActionLanguage=chartInfo.ActionLanguage;
                end
                gpcFlag=false;
                if~isempty(chartId)
                    gpcFlag=sf('get',chartId,'.variant.generatePreprocessorConditionals');
                    gpcFlag=gpcFlag==1;
                end

                if this.mParentRow.mBlockOrIOType==Simulink.internal.vmgr.BlockOrIOType.SFChart


                    atomicSubchartInfo=Simulink.variant.utils.getSFObj(this.mObjectPath,Simulink.variant.utils.StateflowObjectType.ATOMIC_SUBCHART);
                    if~isempty(atomicSubchartInfo)
                        chartId=atomicSubchartInfo.Id;
                    end
                end
                chartBlockParameters=struct('GeneratePreprocessor',gpcFlag);
                this.setBlockParamInfo(chartBlockParameters);
                this.setupStateFlowData(chartId,chartActionLanguage);
            end


            if~isempty(this.mParentRow)&&isequal(this.mParentRow.mVMBlockType,Simulink.variant.manager.VariantManagerBlockType.SFChart)


                slsfObjInfo=Simulink.variant.utils.getSFObj(this.mObjectPath,Simulink.variant.utils.StateflowObjectType.SIMULINK_FUNCTION);
                if isempty(slsfObjInfo)


                    slsfObjInfo=Simulink.variant.utils.getSFObj(this.mObjectPath,...
                    Simulink.variant.utils.StateflowObjectType.SIMULINK_STATE);
                end
                if~isempty(slsfObjInfo)
                    chartId=slsfObjInfo.Id;
                    this.setupStateFlowData(chartId,[]);
                end


                chartId=[];
                chartInfo=Simulink.variant.utils.getSFObj(this.mParentRow.mObjectPath,Simulink.variant.utils.StateflowObjectType.CHART);
                if~isempty(chartInfo)
                    chartId=chartInfo.Id;
                end

                varTransInfo=Stateflow.Variants.VariantMgr.getAllVariantConditionsInChart(chartId);
                if~isempty(varTransInfo)
                    idx=this.getChildVariantTransitionRowIdx();
                    if idx>-1

                        this.setupStateFlowData(varTransInfo(idx).TransitionId,varTransInfo(idx).ActionLanguage);
                    end
                end
            end
        end

        function blockOrIOType=getBlockOrIOTypeParentNode(this)
            blockOrIOType=[];
            switch this.mVMBlockType
            case{Simulink.variant.manager.VariantManagerBlockType.SubSystem,...
                Simulink.variant.manager.VariantManagerBlockType.ModelReference,...
                Simulink.variant.manager.VariantManagerBlockType.SFChart,...
                Simulink.variant.manager.VariantManagerBlockType.VariantSubsystem}
                blockOrIOType=Simulink.internal.vmgr.BlockOrIOType.(char(this.mVMBlockType));

            case Simulink.variant.manager.VariantManagerBlockType.VariantSimFcn
                blockOrIOType=Simulink.internal.vmgr.BlockOrIOType.VariantSimFcnSubsystem;

            case Simulink.variant.manager.VariantManagerBlockType.VariantIRTSystem

                findOpts=Simulink.FindOptions('IncludeCommented',false,'SearchDepth',1,'LookInsideSubsystemReference',true);
                eventListenerBlkH=Simulink.findBlocksOfType(this.mObjectPath,'EventListener',findOpts);
                eventType=get_param(eventListenerBlkH,'EventType');


                switch eventType
                case 'Initialize'
                    blockOrIOType=Simulink.internal.vmgr.BlockOrIOType.VariantIRTSubsystem_Init;
                case 'Reset'
                    blockOrIOType=Simulink.internal.vmgr.BlockOrIOType.VariantIRTSubsystem_Reset;
                case 'Terminate'
                    blockOrIOType=Simulink.internal.vmgr.BlockOrIOType.VariantIRTSubsystem_Term;
                end
            case Simulink.variant.manager.VariantManagerBlockType.VariantSourceSink

                [isManualIVBlock,manualIVBlockType]=Simulink.variant.utils.isManualIVBlock(this.mObjectPath);
                if isManualIVBlock


                    blockType=manualIVBlockType;
                else
                    blockType=get_param(this.mObjectPath,'BlockType');
                end
                blockOrIOType=Simulink.internal.vmgr.BlockOrIOType.(blockType);

            case Simulink.variant.manager.VariantManagerBlockType.VariantPMConnector


                connectorType=get_param(this.mObjectPath,'ConnectorBlkType');
                if strcmp(connectorType,'Primary')
                    blockOrIOType=Simulink.internal.vmgr.BlockOrIOType.VariantPMConnector_Primary;
                elseif strcmp(connectorType,'Nonprimary')
                    blockOrIOType=Simulink.internal.vmgr.BlockOrIOType.VariantPMConnector_Non_Primary;
                else



                    blockOrIOType=Simulink.internal.vmgr.BlockOrIOType.VariantPMConnector_Leaf;
                end
            end
        end

        function blockOrIOType=getBlockOrIOTypeChildNode(this)
            blockOrIOType=[];
            switch(this.mParentRow.mVMBlockType)
            case Simulink.variant.manager.VariantManagerBlockType.VariantSourceSink
                switch this.mParentRow.mBlockOrIOType
                case{Simulink.internal.vmgr.BlockOrIOType.VariantSource,...
                    Simulink.internal.vmgr.BlockOrIOType.ManualVariantSource}
                    blockOrIOType=Simulink.internal.vmgr.BlockOrIOType.VariantSourceInput;

                case{Simulink.internal.vmgr.BlockOrIOType.VariantSink,...
                    Simulink.internal.vmgr.BlockOrIOType.ManualVariantSink}
                    blockOrIOType=Simulink.internal.vmgr.BlockOrIOType.VariantSinkOutput;
                end

            case Simulink.variant.manager.VariantManagerBlockType.VariantSubsystem
                blockOrIOType=Simulink.internal.vmgr.BlockOrIOType.SubSystem;

            case Simulink.variant.manager.VariantManagerBlockType.VariantSimFcn
                blockOrIOType=Simulink.internal.vmgr.BlockOrIOType.TriggerPort;

            case Simulink.variant.manager.VariantManagerBlockType.SFChart
                blockOrIOType=Simulink.internal.vmgr.BlockOrIOType.VariantSFTransition;

            case Simulink.variant.manager.VariantManagerBlockType.VariantPMConnector
                blockOrIOType=Simulink.internal.vmgr.BlockOrIOType.VariantPMConnectorPort;

            case Simulink.variant.manager.VariantManagerBlockType.VariantIRTSystem
                switch this.mParentRow.mBlockOrIOType
                case Simulink.internal.vmgr.BlockOrIOType.VariantIRTSubsystem_Init
                    blockOrIOType=Simulink.internal.vmgr.BlockOrIOType.VariantEventListenerBlock_Init;

                case Simulink.internal.vmgr.BlockOrIOType.VariantIRTSubsystem_Reset
                    blockOrIOType=Simulink.internal.vmgr.BlockOrIOType.VariantEventListenerBlock_Reset;

                case Simulink.internal.vmgr.BlockOrIOType.VariantIRTSubsystem_Term
                    blockOrIOType=Simulink.internal.vmgr.BlockOrIOType.VariantEventListenerBlock_Term;
                end
            end
        end
    end
end

