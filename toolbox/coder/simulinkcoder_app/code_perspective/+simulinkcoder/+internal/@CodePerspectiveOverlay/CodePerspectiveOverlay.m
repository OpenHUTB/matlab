classdef CodePerspectiveOverlay<handle


    properties(Constant)
        id='CodePerspectiveOverlay'
        title='Code Perspective Overlay'
        tag='Tag_CodePerspective_Overlay'
        channel='code_perspective_overlay'
    end

    properties(Hidden)
        debugMode=false
src
subscribe
dlg
fg
    end

    events
DialogClosed
    end

    methods(Access=?simulinkcoder.internal.CodePerspectiveHelp)
        function obj=CodePerspectiveOverlay()
            obj.init();
        end
    end

    methods
        function delete(obj)
            obj.destroy();
        end

        init(obj)
        destroy(obj)
        dlg=getDialogSchema(obj)
        dlg=show(obj,varargin)
        onClose(obj)
        data=export(obj,varargin)
        sendData(obj,varargin)
        url=generateUrl(obj)
    end
end

