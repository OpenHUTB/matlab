classdef(HandleCompatible=true)Interface

    properties(Abstract,Constant,Hidden)
NetworkParameterNarginchkInputs

    end


    methods(Abstract,Access=protected)
        [str,data,freq,z0]=networkParameterInfo(obj,varargin)

    end

end