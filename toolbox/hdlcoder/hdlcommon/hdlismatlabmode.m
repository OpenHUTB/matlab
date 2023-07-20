function varargout=hdlismatlabmode(varargin)




    mlock;

    persistent matlabMode matlabConfig;

    if isempty(matlabMode)
        matlabMode=0;
    end

    if nargin==1
        matlabMode=varargin{1};
        varargout={};
    elseif nargin==2
        matlabMode=varargin{1};
        matlabConfig=varargin{2};
        varargout={};
    else
        varargout={matlabMode,matlabConfig};
    end

