function varargout=sblibdrv(blk,varargin)







    if(nargin==0)
        blk='Unknown';
    end



    switch(blk)
    case 'Integrator'
        varargout=cell(1,2);
        [varargout{:}]=mblkint(varargin{:});
    case 'NumDen'
        varargout=cell(1,4);
        [varargout{:}]=mblktf(varargin{:});
    case 'CmplxZP'
        varargout=cell(1,4);
        [varargout{:}]=mblkczp(varargin{:});
    case 'MultiLin'
        varargout=mblkmdl(varargin{:});
    case 'DataStore'
        varargout=cell(1,2);
        [varargout{:}]=mblkds(varargin{:});
    case 'pidControl'
        varargout=cell(1,2);
        [varargout{:}]=mblkpid(varargin{:});
    case 'AlgebraicExp'
        varargout=mblkalg(varargin{:});
    case 'LogicalExp'
        varargout=cell(1,5);
        [varargout{:}]=mblklog(varargin{:});
    case 'dDelay'
        varargout=cell(1,4);
        [varargout{:}]=mblkdel(varargin{:});
    otherwise
    end
    return
