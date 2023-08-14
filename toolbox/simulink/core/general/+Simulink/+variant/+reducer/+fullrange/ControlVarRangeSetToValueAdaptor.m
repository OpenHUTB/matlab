classdef ControlVarRangeSetToValueAdaptor<handle





    properties(Access=private,Hidden)

        mAllAttainableRanges=[];
        mCtrlVarName;
        mSpecifiedVariableConfigurationCond=[];
        mFullRangeConditionsMap=[];
    end

    methods(Access=public,Hidden)
        function addRange(this,range)
            this.mAllAttainableRanges=[this.mAllAttainableRanges,range];
        end

        function this=ControlVarRangeSetToValueAdaptor(ctrlVarName,specifiedVariableConfigAndAnalysisInfo)
            this.mCtrlVarName=ctrlVarName;
            this.mSpecifiedVariableConfigurationCond=specifiedVariableConfigAndAnalysisInfo.SpecifiedVariableConfigurationCond;
            this.mFullRangeConditionsMap=specifiedVariableConfigAndAnalysisInfo.FullRangeConditionsMap;
        end



        function values=getValues(this,fullRangeConditionsMap)
            values=[];
            for i=1:numel(this.mAllAttainableRanges)
                if this.mAllAttainableRanges(i).getModifyRedModelRange()


                    rangeActiveCondition=...
                    Simulink.variant.reducer.fullrange.createExpressionForChoiceValidity(this.mCtrlVarName,...
                    this.mAllAttainableRanges(i).mEqualityValues,this.mAllAttainableRanges(i).mInequalityValues,...
                    this.mAllAttainableRanges(i).mNodeValidityConditions);


                    Simulink.variant.utils.i_addKeyValueWithDupsToMap(this.mFullRangeConditionsMap,...
                    this.mAllAttainableRanges(i).mBlockPathParentModelForCondModification,...
                    struct('CondOrig',this.mAllAttainableRanges(i).mOriginalCondition,...
                    'CondRed',[this.mSpecifiedVariableConfigurationCond,' && ',rangeActiveCondition]));
                end
                if~isempty(this.mAllAttainableRanges(i).mRangeActiveCondition)

                    Simulink.variant.utils.i_addKeyValueWithDupsToMap(fullRangeConditionsMap,...
                    this.mAllAttainableRanges(i).mBlockPathParentModel,...
                    struct('CondOrig',this.mAllAttainableRanges(i).mOriginalCondition,...
                    'CondRed',['(',this.mSpecifiedVariableConfigurationCond,') && (',this.mAllAttainableRanges(i).mRangeActiveCondition,')']));
                end
            end
            for i=1:numel(this.mAllAttainableRanges)

                if~isempty(this.mAllAttainableRanges(i).mEqualityValues)&&isempty(this.mAllAttainableRanges(i).mInequalityValues)
                    this.mAllAttainableRanges(i).setIsAttained();
                    values=[values,this.mAllAttainableRanges(i).mEqualityValues];%#ok<AGROW>
                end
            end
            values=unique(values);
            this.markRangesAsAttained(values);

            for i=1:numel(this.mAllAttainableRanges)

                if~this.mAllAttainableRanges(i).getIsAttained()&&~isempty(this.mAllAttainableRanges(i).mEqualityValues)
                    equalityValues=this.mAllAttainableRanges(i).mEqualityValues;


                    if(numel(unique(equalityValues))==1)&&...
                        (~isempty(equalityValues)&&all(this.mAllAttainableRanges(i).mInequalityValues~=unique(this.mAllAttainableRanges(i).mEqualityValues)))&&...
                        i_checkZAVC(this.mAllAttainableRanges(i).mConstrainedValuesForZAVC,equalityValues)&&...
                        i_checkMAVC(this.mAllAttainableRanges(i).mConstrainedValuesForMAVC,equalityValues)

                        this.mAllAttainableRanges(i).setIsAttained();
                        values=[values,this.mAllAttainableRanges(i).mEqualityValues];%#ok<AGROW>
                    else
                        this.mAllAttainableRanges(i).setIsUnattainable();
                    end
                end
            end
            values=unique(values);
            this.markRangesAsAttained(values);


            for i=1:numel(this.mAllAttainableRanges)
                if~this.mAllAttainableRanges(i).getIsAttained()&&~this.mAllAttainableRanges(i).getIsUnattainable()
                    value=this.mAllAttainableRanges(i).getValidValueFromRange();
                    if isempty(value)
                        this.mAllAttainableRanges(i).setIsUnattainable();
                    else
                        this.mAllAttainableRanges(i).setIsAttained();
                        values=[values,value];%#ok<AGROW>
                    end
                end
            end
            values=unique(values);
        end
    end

    methods(Access=private,Hidden)



        function markRangesAsAttained(this,values)
            for i=1:numel(this.mAllAttainableRanges)
                if~this.mAllAttainableRanges(i).getIsAttained()&&this.mAllAttainableRanges(i).getSatisfiesInqualityValue(values)
                    this.mAllAttainableRanges(i).setIsAttained();
                end
            end
        end
    end

    methods(Static,Hidden,Access=public)

        function isZAVCClear=checkZAVC(constrainedValues,equalityValues)
            isZAVCClear=false;
            for i=1:numel(constrainedValues)
                constrainedEqualityValues=constrainedValues(i).('ConstrainedEqualityValues');
                constrainedInequalityValues=constrainedValues(i).('ConstrainedInequalityValues');
                if~(i_checkIfAnyEqualityValuesWillSatisfy(constrainedEqualityValues,equalityValues)||...
                    i_checkIfAnyInequalityValuesWillSatisfy(constrainedInequalityValues,equalityValues))
                    return;
                end
            end
            isZAVCClear=true;
        end

        function isMAVCClear=checkMAVC(constrainedValues,equalityValues)
            isMAVCClear=false;
            for i=1:numel(constrainedValues)
                constrainedEqualityValues=constrainedValues(i).('ConstrainedEqualityValues');
                constrainedInequalityValues=constrainedValues(i).('ConstrainedInequalityValues');
                trueChoiceCount=constrainedValues(i).('TrueChoiceCount');
                if(i_getCountOfEqualityValuesSatisfied(constrainedEqualityValues,equalityValues)+...
                    i_getCountOfInequalityValuesSatisfied(constrainedInequalityValues,equalityValues))>(1-trueChoiceCount)
                    return;
                end
            end
            isMAVCClear=true;
        end
    end
end

function satisfiesEqualityValue=i_checkIfAnyEqualityValuesWillSatisfy(constrainedEqualityValues,equalityValues)
    satisfiesEqualityValue=~isempty(constrainedEqualityValues)&&any(cellfun(@(x)(x==equalityValues),constrainedEqualityValues));
end

function satisfiesInequalityValue=i_checkIfAnyInequalityValuesWillSatisfy(constrainedInequalityValues,equalityValues)
    satisfiesInequalityValue=~isempty(constrainedInequalityValues)&&any(cellfun(@(x)(x~=equalityValues),constrainedInequalityValues));
end

function count=i_getCountOfEqualityValuesSatisfied(constrainedEqualityValues,equalityValues)
    count=0;
    if isempty(constrainedEqualityValues),return;end
    count=nnz(cellfun(@(x)(x==equalityValues),constrainedEqualityValues));
end

function count=i_getCountOfInequalityValuesSatisfied(constrainedInequalityValues,equalityValues)
    count=0;
    if isempty(constrainedInequalityValues),return;end
    count=nnz((cellfun(@(x)(x~=equalityValues),constrainedInequalityValues)));
end

function isZAVCClear=i_checkZAVC(constrainedValues,equalityValues)
    isZAVCClear=Simulink.variant.reducer.fullrange.ControlVarRangeSetToValueAdaptor.checkZAVC(constrainedValues,equalityValues);
end

function isMAVCClear=i_checkMAVC(constrainedValues,equalityValues)
    isMAVCClear=Simulink.variant.reducer.fullrange.ControlVarRangeSetToValueAdaptor.checkMAVC(constrainedValues,equalityValues);
end


