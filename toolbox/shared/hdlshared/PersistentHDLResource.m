function varargout=PersistentHDLResource(varargin)




    mlock;

    persistent hdl_parameters;

    if nargin==1
        hdl_parameters=varargin{1};
        varargout={};
    else
        varargout={hdl_parameters};
    end



