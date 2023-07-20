


classdef CodePerspective<handle

    events
CodePerspectiveChange
    end

    properties(Hidden)
        disableModelHs;
        tasks={}
        st={}
code
        listeners={}
        debugMode=false;
        initialized=false;
    end

    properties(Constant,Hidden)
        iconPathOn=fullfile(matlabroot,'toolbox','coder','simulinkcoder_app',...
        'code_perspective','icons','code_perspective_on.png');
        iconPathOff=fullfile(matlabroot,'toolbox','coder','simulinkcoder_app',...
        'code_perspective','icons','code_perspective_off.png');
    end

    methods(Static)
        obj=getInstance
register
        bool=isInPerspective(mdl)
        bool=isAvailable(mdl)
        dlgstruct=customizePropertyInspector(mdl,dlgstruct)
    end

    methods(Access=private)

        function obj=CodePerspective()
            obj.registerPerspective();
        end

        out=addInFlag(obj,mdl,studio)
        removeFlag(obj,mdl,studio)

        updateBdListener(obj,mdl)
        onModelChange(obj,bd,event)
    end

    methods

        init(obj)
        registerPerspective(obj)


        bool=getStatus(obj,editor)
        modelH=target2ModelHandle(~,editor)
        task=getTask(obj,id)
        [varargout]=getInfo(obj,mdl)
        enableForModel(obj,mdl)


        onClickHandler(obj,callbackInfo)
        togglePerspective(obj,editor)
        onStudioClose(ojb,varargin)
        turnOnPerspective(obj,varargin)
        turnOffPerspective(obj,input)


        refresh(obj,studio)
        reset(obj,studio)


        cleanupFlags(obj,mdl)
        flag=getFlag(obj,mdl,studio)
        out=getPerModelInstances(obj,mdl)


        bool=checkCompatibility(obj,src)
    end

    methods(Hidden)
        open(obj,studio)
        close(obj,studio)
    end
end
