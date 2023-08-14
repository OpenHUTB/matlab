classdef ImportOrUpdateProgressTracker<handle




    properties(SetAccess=private)
        NumComponents{mustBeInteger}=0;
        CompCounter{mustBeInteger}=0;
    end

    methods(Access=public)
        function this=ImportOrUpdateProgressTracker(numComponents,compCounter)
            this.NumComponents=numComponents;
            this.CompCounter=compCounter;
        end
    end

    methods(Access=protected)
        function msg=getDisplayMessage(this,msgId,modelName,compQName)
            componentStr=message('autosarstandard:importer:Component').getString();
            msg=message(msgId,modelName,componentStr,...
            int2str(this.CompCounter),int2str(this.NumComponents),compQName).getString();
        end

        function incrementCounter(this)
            this.CompCounter=this.CompCounter+1;
        end
    end

    methods(Abstract)
        displayAndIncrementProgress()
    end
end


