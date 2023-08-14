classdef(Abstract)SourceElements<rf.internal.rfengine.elements.Elements
    methods
        function self=SourceElements(ckt,label,varargin)
            self=self@rf.internal.rfengine.elements.Elements(ckt,label,varargin{:});
            ckt.SourceElements{end+1}=self;
        end
    end
end
