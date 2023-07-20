classdef(Hidden)VariantChoiceInformation<handle







    properties(Access=private,Hidden)
        mVariantControl="";
        mVariantCondition="";
        mIsVariantControlSimulinkVariantObject=false;
        mChoiceError="";
    end

    properties(Access=public)
        mChoiceType=char(Simulink.internal.vmgr.ValidationResultType.None);
    end

    methods(Access=public,Hidden)
        function obj=VariantChoiceInformation(variantControl,variantCondition,isVariantControlSimulinkVariantObject,choiceType,choiceError)
            Simulink.variant.utils.assert(nargin==0||nargin==5);
            if nargin==5
                obj.mVariantControl=variantControl;
                obj.mVariantCondition=variantCondition;
                obj.mIsVariantControlSimulinkVariantObject=isVariantControlSimulinkVariantObject;

                if Simulink.internal.vmgr.ValidationResultType.isValidValidationResultType(choiceType)
                    obj.mChoiceType=choiceType;
                end
                obj.mChoiceError=choiceError;
                if~isempty(obj.mChoiceError)

                    obj.mChoiceError=matlab.internal.display.printWrapped(obj.mChoiceError,75);
                end
            end
        end


        function javaObj=toJava(obj)
            javaObj=java.util.HashMap;
            javaObj.put('VariantControl',java.lang.String(obj.mVariantControl));
            javaObj.put('VariantCondition',java.lang.String(obj.mVariantCondition));
            javaObj.put('IsVariantControlSimulinkVariantObject',obj.mIsVariantControlSimulinkVariantObject);
            javaObj.put('ChoiceType',java.lang.String(obj.mChoiceType));
            javaObj.put('ChoiceError',java.lang.String(obj.mChoiceError));
        end
    end
end


