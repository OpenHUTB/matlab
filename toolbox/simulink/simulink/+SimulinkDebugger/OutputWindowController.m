
classdef OutputWindowController<handle



    methods(Abstract)
        printToWindow(this,str)
        appendToWindow(this,str)
    end
end
