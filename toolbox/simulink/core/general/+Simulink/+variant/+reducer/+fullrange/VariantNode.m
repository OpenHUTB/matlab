classdef VariantNode<handle




    properties(Access=private,Hidden)
        mParentNode;
        mTopModelNode=[];
        mChildNodes=[];

        mAZVCParam=false;
        mHasDefaultChoice=false;
        mTrueChoiceCount=0;

        mVariants={};
        mCreatedRanges=[];

        mAllEqualityValues={};
        mAllInequalityValues={};

        mCtrlVarNames={};

        mFullRangeVarName='';
        mSpecifiedVariableConfigAndAnalysisInfo=[];
    end

    properties(Access=public,Hidden)
        mBlockPathParentModel;
        mBlockPathRootModel;
        mVariantBlockType;
        mBlockVariantConstraint;
        mSpecifiedVariableConfigurationCond;
    end

    methods(Access=private,Hidden)



        function isAcceptableRange=isAcceptableRangeForBlock(this,range)
            isAcceptableRange=this.isAcceptableRangeForBlockImpl(range);
            if isAcceptableRange
                for i=1:numel(this.mChildNodes)
                    isAcceptableRange=this.mChildNodes(i).isAcceptableRangeForBlock(range);
                    if~isAcceptableRange
                        return;
                    end
                end
            end
        end



        function isAcceptableRange=isAcceptableRangeForBlockImpl(this,range)

            if any(strcmp(this.mBlockPathRootModel,{this.mTopModelNode.mBlockPathRootModel,range.mBlockPathParentModel}))

                isAcceptableRange=true;return;
            end

            if(this.mTrueChoiceCount==0)&&(numel(this.mCreatedRanges)==0)




                isAcceptableRange=false;return;
            end

            if~isempty(range.mEqualityValues)

                if checkIntersecionsWithIneualityValues(this.mAllInequalityValues,range.mEqualityValues,true)>(1-this.mTrueChoiceCount)
                    isAcceptableRange=false;return;
                end

                numHits=(checkIntersecionsWithIneualityValues(this.mAllInequalityValues,range.mEqualityValues,true)+...
                checkIntersecionsWithIneualityValues(this.mAllEqualityValues,range.mEqualityValues,false));
                if((numHits+this.mTrueChoiceCount)==1)||((numHits==0)&&~this.getCanThrowZAVCError())
                    isAcceptableRange=true;return;
                end

                isAcceptableRange=false;return;
            end

            if~isempty(range.mInequalityValues)

                range.mInequalityValues=unique(range.mInequalityValues);
                if checkIntersecionsWithIneualityValues(this.mAllInequalityValues,range.mInequalityValues,false)>(1-this.mTrueChoiceCount)
                    isAcceptableRange=false;return;
                end

                range.addConstrainedValuesForMAVC(this.mAllEqualityValues,this.mAllInequalityValues,this.mTrueChoiceCount);

                if this.getCanThrowZAVCError()



                    range.addConstrainedValuesForZAVC(this.mAllEqualityValues,this.mAllInequalityValues);
                end
                if~range.mIsConstrainedFalse
                    range.addNodeValidityConditions(this.mBlockVariantConstraint);
                end
            end
            isAcceptableRange=true;
        end

        function computeCreatedRanges(this,specifiedVariableConfigAndAnalysisInfo)
            if this.mVariantBlockType.isModel()


                dependentSpecifiedVariableConfigurationConds={};
                dependentSpecifiedVariableConfiguration=[];

                if~isempty(specifiedVariableConfigAndAnalysisInfo.SpecifiedVariableConfiguration)
                    for i=1:2:numel(specifiedVariableConfigAndAnalysisInfo.SpecifiedVariableConfiguration)



                        if any(strcmp(specifiedVariableConfigAndAnalysisInfo.FullRangeVarsInfluentialVarsMap(this.mFullRangeVarName),...
                            specifiedVariableConfigAndAnalysisInfo.SpecifiedVariableConfiguration{i}))
                            varName=specifiedVariableConfigAndAnalysisInfo.SpecifiedVariableConfiguration{i};
                            varValue=specifiedVariableConfigAndAnalysisInfo.SpecifiedVariableConfiguration{i+1};
                            dependentSpecifiedVariableConfiguration.(varName)=varValue;
                            dependentSpecifiedVariableConfigurationConds{end+1}=[varName,' == ',num2str(varValue)];%#ok<AGROW>
                        end
                    end
                end

                this.mSpecifiedVariableConfigAndAnalysisInfo.SpecifiedVariableConfiguration=dependentSpecifiedVariableConfiguration;
                this.mSpecifiedVariableConfigAndAnalysisInfo.SpecifiedVariableConfigurationCond=...
                Simulink.variant.reducer.fullrange.combineByAND(dependentSpecifiedVariableConfigurationConds);

                return;
            end


            Simulink.variant.reducer.utils.assert(...
            this.mVariantBlockType.isVariantSubsystem()||this.mVariantBlockType.isVariantSource()||...
            this.mVariantBlockType.isVariantSink()||this.mVariantBlockType.isModelVariant()||...
            this.mVariantBlockType.isVariantIRTSubsystem()||this.mVariantBlockType.isVariantSimulinkFunction());

            if this.mVariantBlockType.isVariantSubsystem()||this.mVariantBlockType.isVariantSource()||...
                this.mVariantBlockType.isVariantSink()||this.mVariantBlockType.isModelVariant()||...
                this.mVariantBlockType.isVariantIRTSubsystem()||this.mVariantBlockType.isVariantSimulinkFunction()

                if this.mVariantBlockType.isVariantIRTSubsystem()||this.mVariantBlockType.isVariantSimulinkFunction()
                    blockPathParentModelParts=Simulink.variant.utils.splitPathInHierarchy(this.mBlockPathParentModel);
                    blockPathParentModelForCondModification=strjoin(blockPathParentModelParts(1:end-1),'/');
                else
                    blockPathParentModelForCondModification=this.mBlockPathParentModel;
                end
                specifiedVariableConfigAndAnalysisInfo.BlockPathParentModelForCondModification=blockPathParentModelForCondModification;
                [this.mCreatedRanges,this.mHasDefaultChoice,this.mTrueChoiceCount,errors]=...
                Simulink.variant.reducer.fullrange.ControlVarRangeFactory(this.mTopModelNode.mBlockPathParentModel,...
                this.mBlockPathParentModel,this.mVariants,this.mAZVCParam,specifiedVariableConfigAndAnalysisInfo);

                Simulink.variant.reducer.fullrange.ErrorHandler.handleErrors(this.mTopModelNode.mBlockPathParentModel,errors);
                this.validateSelfRange();
            end
        end

        function validateSelfRange(this)
            N=numel(this.mCreatedRanges);
            equalityValues={};inequalityValues={};

            for i=1:N
                range=this.mCreatedRanges(i);
                if range.getIsDerivedRange(),continue,end
                if~isempty(range.mEqualityValues)
                    equalityValues=[equalityValues,{range.mEqualityValues}];%#ok<AGROW>
                end
                if~isempty(range.mInequalityValues)
                    inequalityValues=[inequalityValues,{range.mInequalityValues}];%#ok<AGROW>
                end
            end

            this.mAllEqualityValues=equalityValues;this.mAllInequalityValues=inequalityValues;
            this.mBlockVariantConstraint=Simulink.variant.reducer.fullrange.createBlockVariantConstraint(this.mFullRangeVarName,...
            equalityValues,inequalityValues,(this.mAZVCParam||this.mHasDefaultChoice),(this.mTrueChoiceCount>0));
            for i=1:N
                range=this.mCreatedRanges(i);

                if this.mTrueChoiceCount>0


                    range.setIsConstrainedFalseRange();
                end

                if~isempty(range.mEqualityValues)
                    if numel(range.mEqualityValues)>1
                        range.setIsUnattainable();continue;
                    end
                    if checkIntersecionsWithIneualityValues(this.mAllEqualityValues,range.mEqualityValues,false)>1
                        range.setIsUnattainable();continue;
                    end
                    if checkIntersecionsWithIneualityValues(this.mAllInequalityValues,range.mEqualityValues,true)>0

                        range.setIsUnattainable();continue;
                    end
                end

                if~isempty(range.mInequalityValues)
                    range.addConstrainedValuesForMAVC(this.mAllEqualityValues,this.mAllInequalityValues,this.mTrueChoiceCount);

                    if checkIntersecionsWithIneualityValues(this.mAllInequalityValues,range.mInequalityValues,false)>1
                        range.setIsUnattainable();continue;
                    end

                    if checkIntersecionsWithIneualityValues(this.mAllInequalityValues,range.mInequalityValues,true)>1
                        range.setIsUnattainable();continue;
                    end
                end
            end
        end


        function addValidRangesToAdaptor(this,valueAdaptor)
            this.computeSelfInequalityValues();
            for i=1:numel(this.mCreatedRanges)
                if~this.mCreatedRanges(i).getIsUnattainable()
                    valueAdaptor.addRange(this.mCreatedRanges(i));
                end
            end

            for i=1:numel(this.mChildNodes)
                this.mChildNodes(i).addValidRangesToAdaptor(valueAdaptor);
            end
        end

        function setParentNode(this,parentNode)
            if isa(parentNode,'Simulink.variant.reducer.fullrange.VariantNode')
                this.mParentNode=parentNode;
                this.mTopModelNode=parentNode.mTopModelNode;
                parentNode.addChildNode(this);
            end
        end

        function addChildNode(this,row)
            this.mChildNodes=[this.mChildNodes,row];
        end
    end

    methods(Access=public,Hidden)
        function this=VariantNode(blockPathParentModel,blockPathRootModel,blockType,parentNode,variants,ctrlVarNames,specifiedVariableConfigAndAnalysisInfo)
            this.mBlockPathParentModel=blockPathParentModel;
            this.mBlockPathRootModel=blockPathRootModel;
            this.mVariantBlockType=blockType;
            this.mVariants=variants;
            this.mCtrlVarNames=ctrlVarNames;

            if isempty(parentNode)
                this.mTopModelNode=this;
            else
                this.setParentNode(parentNode);
            end

            if this.mVariantBlockType.isModel()
                this.mSpecifiedVariableConfigAndAnalysisInfo=specifiedVariableConfigAndAnalysisInfo;
            end

            if this.mVariantBlockType.isVariantSubsystem()||this.mVariantBlockType.isVariantSource()||this.mVariantBlockType.isVariantSink()
                this.mAZVCParam=strcmp(get_param(this.mBlockPathParentModel,'AllowZeroVariantControls'),'on');
            else


                this.mAZVCParam=this.mVariantBlockType.isVariantIRTSubsystem()||this.mVariantBlockType.isVariantSimulinkFunction();
            end
            if~specifiedVariableConfigAndAnalysisInfo.SkipComputingRanges
                this.mFullRangeVarName=specifiedVariableConfigAndAnalysisInfo.FullRangeCtrlVarName;
                this.computeCreatedRanges(specifiedVariableConfigAndAnalysisInfo);
            end
        end


        function fullRangeCareVars=computeControlVarValues(this)

            valueAdaptor=Simulink.variant.reducer.fullrange.ControlVarRangeSetToValueAdaptor(this.mCtrlVarNames,this.mSpecifiedVariableConfigAndAnalysisInfo);
            this.addValidRangesToAdaptor(valueAdaptor);
            fullRangeCareVars=valueAdaptor.getValues();
        end

        function netHierarchy=getCtrlVarHierarchy(this)
            hierarchy={};
            if~isempty(this.mCtrlVarNames)
                hierarchy={struct('VarName',{this.mCtrlVarNames},'BlockName',{this.mBlockPathRootModel})};
            end
            childHierarchies={};
            for i=1:numel(this.mChildNodes)
                childHierarchies=[childHierarchies,getCtrlVarHierarchy(this.mChildNodes(i))];%#ok<AGROW>
            end
            N=numel(childHierarchies);
            if N==0
                netHierarchy=hierarchy;
            elseif isempty(hierarchy)
                netHierarchy=childHierarchies;
            else
                netHierarchy={};
                for i=1:N
                    netHierarchy=[netHierarchy,[hierarchy{:};childHierarchies{i}]];%#ok<AGROW>
                end
            end
        end

        function validateRanges(this)

            for k=1:numel(this.mCreatedRanges)
                if~(this.mCreatedRanges(k).getIsUnattainable()||...
                    this.mTopModelNode.isAcceptableRangeForBlock(this.mCreatedRanges(k)))
                    this.mCreatedRanges(k).setIsUnattainable();
                end
            end
            for i=1:numel(this.mChildNodes)
                this.mChildNodes(i).validateRanges();
            end
        end




        function computeSelfInequalityValues(this)
            N=numel(this.mCreatedRanges);

            createdRangesCurrentState=arrayfun(@(x)(copy(x)),this.mCreatedRanges,'UniformOutput',false);
            for i=1:N
                range=this.mCreatedRanges(i);
                if range.getIsUnattainable()||range.getIsDerivedRange(),continue,end
                for j=1:N
                    if j==i,continue,end
                    siblingRange=createdRangesCurrentState{j};
                    if siblingRange.getIsDerivedRange(),continue,end

                    if~isempty(siblingRange.mInequalityValues)
                        if siblingRange.getIsConstrainedFalseRange()
                            range.addInequalityValue(siblingRange.mInequalityValues);
                        else
                            range.addEqualityValue(siblingRange.mInequalityValues);
                        end
                    end
                    if~isempty(siblingRange.mEqualityValues)
                        if siblingRange.getIsConstrainedFalseRange()
                            range.addEqualityValue(siblingRange.mEqualityValues);
                        else
                            range.addInequalityValue(siblingRange.mEqualityValues);
                        end
                    end
                end
            end
        end



        function throwsZAVCError=getCanThrowZAVCError(this)


            throwsZAVCError=(this.mTrueChoiceCount==0)&&~(this.mAZVCParam||this.mHasDefaultChoice);
        end
    end
end

function numIntersections=checkIntersecionsWithIneualityValues(inequalityValues,value,isEqualityValue)
    numIntersections=0;
    for i=1:numel(inequalityValues)
        inequalityValue=inequalityValues{i};
        if(isEqualityValue&&all(inequalityValue~=value))||(~isEqualityValue&&any(inequalityValue==value))
            numIntersections=numIntersections+1;
        end
    end
end


