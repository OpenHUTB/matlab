

classdef DebugSession<handle



    properties

        outputWindowController_;




    end

    methods
        function this=DebugSession()
            this.outputWindowController_=[];
        end

        function setOuputWindowController(this,outputWindowController)
            this.outputWindowController_=outputWindowController;
        end

        function outwin=outputWindowController(this)
            outwin=this.outputWindowController_;
        end
    end
end
