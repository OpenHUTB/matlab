classdef(ConstructOnLoad=true)Processor<eda.internal.component.WhiteBox







    properties
PROCESSOR_PART
minDCMFreq
maxDCMFreq
    end

    methods
        function this=Processor(varargin)
            if~isempty(varargin)
                arg=this.componentArg(varargin);
                componentSet(this,arg);
            end
        end
    end

end

