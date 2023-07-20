classdef DualScaledParameter<Simulink.AbstractDualScaledParameter&AUTOSAR.Parameter






    properties(PropertyType='char',Hidden=true)
        CompuMethodName='';
    end




    methods(Hidden=true,Static=true)

        function lstr=getHelpLink()


            lstr={fullfile(docroot,'autosar','helptargets.map'),'autosar_dualscaledparameter'};
        end
    end

end



