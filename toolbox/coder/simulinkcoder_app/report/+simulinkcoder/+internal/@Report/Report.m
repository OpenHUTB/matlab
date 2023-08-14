classdef Report<handle




    events
Click
MouseEnter
MouseLeave
CodeReady
CodeViewEvent
    end

    properties
        id='CodeView'
        title=message('SimulinkCoderApp:report:CodePanelName').getString()
        comp='GLUE2:DDG Component'
        tag='Tag_CodeView'
        channel='/report'
    end

    properties(Access=private)
        subscribe={}
    end

    properties(Hidden)
        debugMode=false
        cef=true
        features=[]
    end


    methods(Static)
        obj=getInstance()
    end
    methods(Access=protected)
        function obj=Report()

            obj.init();
        end
    end
    methods
        function delete(obj)

            obj.destroy();
        end
    end


    methods
        url=getUrl(obj,top,mdl,cid)

        show(obj,varargin)
        hide(obj,varargin)
        showFullReport(obj,varargin)
        chrome(obj)

        refresh(obj,varargin)
        lock(obj,varargin)
        unlock(obj,varargin)
        focus(obj,varargin)

        onClick(obj,msg)
        onMouseEnter(obj,msg)
        onMouseLeave(obj,msg)

        saveAnnotation(obj,msg)

        publish(obj,mdl,action,data,uid)

        out=checkoutLicense(obj)
    end


    methods(Access=private)
        init(obj)
        destroy(obj)
        actionDispatcher(obj,msg)
    end


    methods(Static)
        [codeFile,annotationFile,covFile,ref]=getCodeDataFile(mdl,ref)
        data=getCodeData(mdl,isRef,top,reportV2Gen)
        data=genCodeData(mdl,file,isRef,reportV2Gen)

        msg(json)
    end
end

