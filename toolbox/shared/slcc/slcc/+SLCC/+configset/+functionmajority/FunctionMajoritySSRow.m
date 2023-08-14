


classdef FunctionMajoritySSRow<handle
    properties(Access=private)
        fcnName;
        majorityEnum;
        parentSS;
    end

    properties(Access=private,Constant=true)
        fcnNameCol=getString(message('Simulink:CustomCode:MajorityDlgSSFcnNameColHeader'));
        majorityCol=getString(message('Simulink:CustomCode:MajorityDlgSSSettingColHeader'));
        validProps={getString(message('Simulink:CustomCode:MajorityDlgSSFcnNameColHeader')),...
        getString(message('Simulink:CustomCode:MajorityDlgSSSettingColHeader'))};
    end


    methods
        function this=FunctionMajoritySSRow(parentSS,aMajorityEntry)
            import SLCC.configset.functionmajority.MajorityUIOpts;
            import SLCC.configset.functionmajority.utils.*;

            this.fcnName=aMajorityEntry.FunctionName;

            arrayLayoutOptsEnglish=getFunctionArrayLayoutOptsEnglish();
            [~,idx]=ismember(aMajorityEntry.ArrayLayout,arrayLayoutOptsEnglish);
            assert(idx>0&&idx<4);

            this.majorityEnum=MajorityUIOpts(idx);
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

        function[aPropValue]=getPropValue(this,aPropName)
            switch(aPropName)
            case this.fcnNameCol
                aPropValue=this.fcnName;
            case this.majorityCol
                aPropValue=this.getCurrentMajorityAsString();
            otherwise
                aPropValue='';
            end
        end

        function setPropValue(this,aPropName,aPropValue)
            switch(aPropName)
            case this.fcnNameCol
                this.fcnName=aPropValue;
                this.parentSS.dlgSrc.enableApplyOnParentUponApply=true;
            case this.majorityCol
                this.setMajorityEnumFromUIString(aPropValue);
                this.parentSS.dlgSrc.enableApplyOnParentUponApply=true;
            end
        end

        function[aPropType]=getPropDataType(this,aPropName)
            switch(aPropName)
            case this.fcnNameCol
                aPropType='string';
            case this.majorityCol
                aPropType='enum';
            otherwise
                aPropType='';

            end
        end

        function[allowValues]=getPropAllowedValues(this,aPropName)
            import SLCC.configset.functionmajority.utils.*;
            switch(aPropName)
            case{this.fcnNameCol}
                allowValues=this.parentSS.dlgSrc.getSuggestedFunctionList();
            case{this.majorityCol}
                allowValues=getFunctionArrayLayoutOpts();
            otherwise
                allowValues={};
            end
        end
    end

    methods
        function[fcnMajorityEntry]=getFuncionMajorityEntry(this)
            fcnMajorityEntry=struct('FunctionName',this.fcnName,...
            'ArrayLayout',this.getCurrentMajorityAsEnglishString());
        end
    end


    methods(Access=private)
        function[majorityStr]=getCurrentMajorityAsString(this)
            import SLCC.configset.functionmajority.utils.*;
            options=getFunctionArrayLayoutOpts();
            majorityStr=options{int32(this.majorityEnum)};
        end

        function[majorityStr]=getCurrentMajorityAsEnglishString(this)
            import SLCC.configset.functionmajority.utils.*;
            options=getFunctionArrayLayoutOptsEnglish();
            majorityStr=options{int32(this.majorityEnum)};
        end

        function setMajorityEnumFromUIString(this,majorityString)
            import SLCC.configset.functionmajority.MajorityUIOpts;
            import SLCC.configset.functionmajority.utils.*;
            options=getFunctionArrayLayoutOpts();
            [~,idx]=ismember(majorityString,options);
            this.majorityEnum=MajorityUIOpts(idx);
        end
    end
end


