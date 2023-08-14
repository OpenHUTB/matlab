classdef Network<rf.internal.circuit.Element


    properties(Abstract,SetAccess=protected)
Nodes
Elements
    end


    properties(Abstract,Hidden,SetAccess=protected)
TerminalNodes
    end


    methods
        function obj=Network(varargin)
            obj=obj@rf.internal.circuit.Element(varargin{:});
        end
    end

end