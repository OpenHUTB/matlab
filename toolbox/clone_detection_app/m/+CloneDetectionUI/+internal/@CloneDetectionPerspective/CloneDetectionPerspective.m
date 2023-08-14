


classdef CloneDetectionPerspective<handle

    properties(Constant,Hidden)
        iconPathOn=fullfile(matlabroot,'toolbox','clone_detection_app','m',...
        'ui','images','detect_48_on.png');
        iconPathOff=fullfile(matlabroot,'toolbox','clone_detection_app','m',...
        'ui','images','detect_48_off.png');
    end

    methods(Static)
        obj=getInstance
register
        bool=isAvailable();
        bool=getStatus(editor);
        turnOnPerspective(input);
        turnOffPerspective(input);
    end

    methods(Access=private)

        function obj=CloneDetectionPerspective()
            obj.registerPerspective();
        end
    end

    methods

        registerPerspective(obj)


        onClickHandler(obj,callbackInfo)
        togglePerspective(obj,editor);
    end
end
