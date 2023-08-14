classdef handleWarningForFindMdlrefsVariants<handle




    methods

        function obj=handleWarningForFindMdlrefsVariants()

            obj.m_findsysWarnThrown=false;
        end

        function result=process(this,msgObject)



            warnId=msgObject.MessageId;
            if strcmp(warnId,'Simulink:Commands:FindSystemVariantsOptionRemoval')||...
                strcmp(warnId,'Simulink:Commands:FindSystemDefaultVariantsOptionWithVariantModel')||...
                strcmp(warnId,'Simulink:Commands:FindSystemAllVariantsRemoval')
                if this.m_findsysWarnThrown

                    result='';
                else

                    result=msgObject;
                    this.m_findsysWarnThrown=true;
                end
            else

                result=msgObject;
            end
        end

    end
    properties
        m_findsysWarnThrown;
    end
end