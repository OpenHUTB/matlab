classdef Monomodal<images.internal.app.registration.model.IterativeIntensityProperty



    properties





    end

    methods
        function self=Monomodal(varargin)

            [optimizer,metric]=imregconfig('monomodal');
            self.metric=metric;
            self.optimizer=optimizer;
        end
    end

end