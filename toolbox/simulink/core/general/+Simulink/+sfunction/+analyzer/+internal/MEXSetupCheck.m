classdef MEXSetupCheck<Simulink.sfunction.analyzer.internal.ComplianceCheck


    properties
Description
Category
    end

    methods
        function obj=MEXSetupCheck(description,category)
            obj@Simulink.sfunction.analyzer.internal.ComplianceCheck(description,category);
        end

        function input=constructInput(obj,target)
            input=target;
        end

        function[description,result,details]=execute(obj,input)
            description=obj.Description;
            ll=mex.getCompilerConfigurations(input.SrcType,'Selected');
            result=Simulink.sfunction.analyzer.internal.ComplianceCheck.PASS;

            details={DAStudio.message('Simulink:SFunctions:ComplianceCheckMEXCompilerSetupCorrect',input.SrcType)};
            if isempty(ll)
                result=Simulink.sfunction.analyzer.internal.ComplianceCheck.FAIL;

                details={DAStudio.message('Simulink:SFunctions:ComplianceCheckMEXCompilerSetupIncorrect',input.SrcType)};
            end
        end
    end
end

