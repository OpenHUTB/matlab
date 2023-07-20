classdef ExternalIOInterface<handle



    methods
        function obj=ExternalIOInterface(kind,varargin)
            obj.Kind=kind;
            obj.Name=matlab.lang.makeValidName(varargin{1});
            obj.PortWidth=varargin{2};
            obj.FPGAPins=varargin{3};
            obj.IOPadConstraints=varargin{4};
            if nargin==6
                obj.Polarity=varargin{5};


            else
                obj.Polarity='active_high';
            end
        end
    end
    properties(SetAccess=private)
Kind
Name
PortWidth
FPGAPins
IOPadConstraints
Polarity
    end
end