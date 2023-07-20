classdef Dechirp<handle


    methods(Access=protected,Hidden)
        function p=makeInputParser(self)
            p=inputParser;
            p.CaseSensitive=false;
            addParameter(p,'Process',self.DefaultProcessType);
        end
    end
    methods
        function self=Dechirp(varargin)
            narginchk(0,20)
            p=makeInputParser(self);
            parse(p,varargin{:});
        end
    end
    properties(Constant,Access=protected)
        DefaultProcessType='Dechirp';
    end
end
