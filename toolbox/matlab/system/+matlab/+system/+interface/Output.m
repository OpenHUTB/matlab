classdef Output<matlab.system.interface.ElementBase



%#codegen



    properties(Access=public)
SignalType
    end

    methods
        function obj=Output(name,varargin)

            coder.allowpcode('plain');

            if(~isstring(name)&&~ischar(name))||strlength(name)==0
                error('Error in parsing argument #1: must be nonempty string or char array.');
            end
            obj=obj@matlab.system.interface.ElementBase(name);

            for i=1:length(varargin)
                if~isa(varargin{i},'matlab.system.interface.AttributeBase')
                    error(['Error in parsing argument #',num2str(i+1),': must be one of the attribute classes.']);
                end

                if isa(varargin{i},'matlab.system.interface.SignalTypeBase')
                    obj.SignalType=varargin{i};
                else
                    assert(false,'Cannot recognize attribute class type.');
                end
            end

        end
    end

    methods(Access=protected)
        function processInputArguments(obj,configs)
        end
    end
end

