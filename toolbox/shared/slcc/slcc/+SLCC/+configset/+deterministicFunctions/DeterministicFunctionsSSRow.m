


classdef DeterministicFunctionsSSRow<handle
    properties(Access=private)
        fcnName;
        parentSS;
    end

    properties(Access=private,Constant=true)
        fcnNameCol=getString(message('Simulink:CustomCode:DeterministicFunctionsDlgSSFcnNameColHeader'));
        validProps={getString(message('Simulink:CustomCode:DeterministicFunctionsDlgSSFcnNameColHeader'))};
    end


    methods
        function this=DeterministicFunctionsSSRow(parentSS,aFcnName)
            import SLCC.configset.deterministicFunctions.utils.*;

            this.fcnName=aFcnName;
            this.parentSS=parentSS;
        end

        function[bIsValid]=isValidProperty(this,aPropName)
            switch(aPropName)
            case this.validProps
                bIsValid=true;
            otherwise
                bIsValid=false;
            end
        end

        function[bIsReadOnly]=isReadonlyProperty(~,~)
            bIsReadOnly=false;
        end

        function[aPropValue]=getPropValue(this,~)
            aPropValue=this.fcnName;
        end

        function setPropValue(this,~,aPropValue)
            this.fcnName=aPropValue;
            this.parentSS.dlgSrc.enableApplyOnParentUponApply=true;
        end

        function[aPropType]=getPropDataType(~,~)
            aPropType='string';
        end

        function[allowValues]=getPropAllowedValues(this,~)
            allowValues=this.parentSS.dlgSrc.getSuggestedFunctionList();
        end
    end

    methods
        function[fcnEntry]=getDeterministicFunctionsEntry(this)
            fcnEntry=this.fcnName;
        end
    end
end


