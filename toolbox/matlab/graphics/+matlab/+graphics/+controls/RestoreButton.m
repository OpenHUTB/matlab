classdef(ConstructOnLoad)RestoreButton<matlab.graphics.controls.PushButton





    methods
        function obj=RestoreButton()
            obj@matlab.graphics.controls.PushButton();


            obj.Image=fullfile(matlabroot,...
            'toolbox','matlab','graphics','+matlab','+graphics','+controls','icons','expand.png');

        end
    end
end
