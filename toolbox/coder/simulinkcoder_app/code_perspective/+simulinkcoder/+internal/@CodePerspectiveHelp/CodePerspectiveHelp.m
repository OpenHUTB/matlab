classdef CodePerspectiveHelp<handle


    properties(Constant)
        id='CodePerspective'
        title=message('SimulinkCoderApp:codeperspective:HelpDialogTitle').getString
        comp='GLUE2:DDG Component'
        tag='Tag_CodePerspective'
        channel='code_perspective'
    end

    properties
Url
debugUrl
overlay
    end

    properties(Hidden)
        debugMode=false
studio
subscribe
    end

    methods(Access=?simulinkcoder.internal.CodePerspective)
        function obj=CodePerspectiveHelp()

            obj.init();
        end
    end

    methods
        function delete(obj)
            obj.destroy();
        end

        init(obj)
        destroy(obj)
        callback(obj,varargin)
        refresh(obj,mdlH,target)

        dlg=getDialogSchema(obj)
        show(obj,varargin)
        url=generateUrl(obj)
        target=getTarget(obj,varargin)

        onOverlayClosed(obj,varargin)
    end
end

