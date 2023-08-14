classdef Multimodal<images.internal.app.registration.model.IterativeIntensityProperty



    properties





    end

    methods
        function self=Multimodal(varargin)

            [optimizer,metric]=imregconfig('multimodal');
            self.metric=metric;
            self.optimizer=optimizer;
        end
    end

end