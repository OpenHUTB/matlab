classdef DualScaledParameter<Simulink.AbstractDualScaledParameter&Simulink.Parameter









    methods(Hidden=true,Static=true)

        function lstr=getHelpLink()


            lstr={fullfile(docroot,'mapfiles','simulink.map'),'simulink_dualscaledparameter'};
        end
    end

end

