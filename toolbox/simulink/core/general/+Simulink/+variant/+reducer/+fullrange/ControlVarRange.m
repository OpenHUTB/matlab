classdef ControlVarRange<matlab.mixin.Copyable







    properties(Access=private,Hidden)
        mIsUnattainable=false;
        mIsAttained=false;


        mIsDerived=false;
    end

    properties(Access=public,Hidden)
        mEqualityValues=[];
        mInequalityValues=[];

        mBlockPathParentModel;

        mBlockPathParentModelForCondModification;



        mConstrainedValuesForZAVC;
        mConstrainedValuesForMAVC;



        mIsConstrainedFalse=false;

        mNodeValidityConditions={};

        mIsTrueChoice=false;

        mOriginalCondition='';

        mRangeActiveCondition;
    end

    methods(Access=public,Hidden)

        function this=ControlVarRange(blockPathParentModel,blockPathParentModelForCondModification,equalityValues,inequalityValues,isDerived,isTrueChoice,originalCondition)

            this.mBlockPathParentModel=blockPathParentModel;
            this.mBlockPathParentModelForCondModification=blockPathParentModelForCondModification;

            if~isempty(equalityValues)
                this.mEqualityValues=equalityValues;
            end
            if~isempty(inequalityValues)
                this.mInequalityValues=inequalityValues;
            end

            this.mIsTrueChoice=isTrueChoice;
            this.mIsAttained=isTrueChoice;
            this.mIsDerived=isDerived;

            this.mOriginalCondition=originalCondition;
        end


        function modifyRedModelRange=getModifyRedModelRange(this)



            modifyRedModelRange=~this.mIsConstrainedFalse;
        end

        function addConstrainedValuesForZAVC(this,equalityValues,inEqualityValues)
            this.mConstrainedValuesForZAVC=[this.mConstrainedValuesForZAVC...
            ,struct('ConstrainedEqualityValues',{equalityValues},'ConstrainedInequalityValues',{inEqualityValues})];
        end

        function addNodeValidityConditions(this,nodeValidityCondition)
            this.mNodeValidityConditions=[this.mNodeValidityConditions,nodeValidityCondition];
        end

        function addConstrainedValuesForMAVC(this,equalityValues,inEqualityValues,trueChoiceCount)
            this.mConstrainedValuesForMAVC=[this.mConstrainedValuesForMAVC...
            ,struct('ConstrainedEqualityValues',{equalityValues},...
            'ConstrainedInequalityValues',{inEqualityValues},...
            'TrueChoiceCount',trueChoiceCount)];
        end

        function addEqualityValue(this,equalityValues)
            this.mEqualityValues=[this.mEqualityValues,equalityValues];
        end

        function addInequalityValue(this,inequalityValues)
            this.mInequalityValues=[this.mInequalityValues,inequalityValues];
        end

        function setIsUnattainable(this)
            if this.mIsTrueChoice
                return;
            end
            this.mIsUnattainable=true;
        end

        function isValid=getIsUnattainable(this)
            isValid=this.mIsUnattainable;
        end

        function setIsAttained(this)
            this.mIsAttained=true;
        end

        function isAttained=getIsAttained(this)
            isAttained=this.mIsAttained;
        end

        function setIsConstrainedFalseRange(this)
            if this.mIsTrueChoice
                return;
            end
            if~this.mIsConstrainedFalse
                tmpEqualityValues=this.mEqualityValues;
                this.mEqualityValues=this.mInequalityValues;
                this.mInequalityValues=tmpEqualityValues;
            end
            this.mIsConstrainedFalse=true;
        end

        function isConstrainedFalseRange=getIsConstrainedFalseRange(this)
            isConstrainedFalseRange=this.mIsConstrainedFalse;
        end

        function isDerived=getIsDerivedRange(this)
            isDerived=this.mIsDerived;
        end



        function value=getValidValueFromRange(this)

            value=[];
            constrainedValues=this.mConstrainedValuesForZAVC();


            possibleEqualityValues=this.mEqualityValues;
            if~isempty(constrainedValues)
                purelyConstrainedValuesIdxs=arrayfun(@(X)(isempty(X.ConstrainedInequalityValues)),constrainedValues);
                constrainedEqualityValues=[constrainedValues(purelyConstrainedValuesIdxs).ConstrainedEqualityValues];
                if~isempty(constrainedEqualityValues)
                    possibleEqualityValues=[possibleEqualityValues,unique([constrainedEqualityValues{:}])];
                end
            end
            if~isempty(possibleEqualityValues)
                possibleEqualityValues=setdiff(possibleEqualityValues,this.mInequalityValues);
                for i=1:numel(possibleEqualityValues)
                    value=possibleEqualityValues(i);
                    isAttainable=i_isZAVCClear(this.mConstrainedValuesForZAVC,value)&&...
                    i_isMAVCClear(this.mConstrainedValuesForMAVC,value);
                    if isAttainable
                        return;
                    end
                end

                value=[];return;
            end

            constrainedValues=this.mConstrainedValuesForMAVC();
            if~isempty(constrainedValues)
                if any(arrayfun(@(X)((numel(X.ConstrainedInequalityValues))>2),constrainedValues))

                    value=[];return;
                end
                possibleEqualityValues=this.mEqualityValues;

                purelyConstrainedValuesIdxs=arrayfun(@(X)((numel(X.ConstrainedInequalityValues))==2),constrainedValues);

                constrainedEqualityValues=[constrainedValues(purelyConstrainedValuesIdxs).ConstrainedInequalityValues];
                if~isempty(constrainedEqualityValues)
                    possibleEqualityValues=setdiff([possibleEqualityValues,unique([constrainedEqualityValues{:}])],this.mInequalityValues);
                    for i=1:numel(possibleEqualityValues)
                        value=possibleEqualityValues(i);
                        isAttainable=i_isZAVCClear(this.mConstrainedValuesForZAVC,value)&&...
                        i_isMAVCClear(this.mConstrainedValuesForMAVC,value);
                        if isAttainable
                            return;
                        end
                    end
                    value=[];return;
                end
            end
            i=0;
            while(true)
                if(isempty(this.mInequalityValues)||all(i~=this.mInequalityValues))&&...
                    i_isZAVCClear(this.mConstrainedValuesForZAVC,i)&&...
                    i_isMAVCClear(this.mConstrainedValuesForMAVC,i)
                    value=i;return;
                end

                if i>0
                    i=-i;
                else
                    i=(-i+1);
                end
            end
        end

        function satisfiesInqualityValue=getSatisfiesInqualityValue(this,equalityValues)
            satisfiesInqualityValue=false;
            for i=1:numel(equalityValues)
                satisfiesInqualityValue=all(this.mInequalityValues~=equalityValues(i));
                if satisfiesInqualityValue&&~isempty(this.mEqualityValues)
                    satisfiesInqualityValue=all(this.mEqualityValues==equalityValues(i));
                end
                if satisfiesInqualityValue
                    return;
                end
            end
        end
    end
end

function isZAVCClear=i_isZAVCClear(constrainedValuesForZAVC,value)
    isZAVCClear=Simulink.variant.reducer.fullrange.ControlVarRangeSetToValueAdaptor.checkZAVC(constrainedValuesForZAVC,value);
end

function isMAVCClear=i_isMAVCClear(constrainedValuesForMAVC,value)
    isMAVCClear=Simulink.variant.reducer.fullrange.ControlVarRangeSetToValueAdaptor.checkMAVC(constrainedValuesForMAVC,value);
end


