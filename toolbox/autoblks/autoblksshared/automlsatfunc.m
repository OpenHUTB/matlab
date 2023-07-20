function y_sat=automlsatfunc(u,varargin)
%#codegen
    coder.allowpcode('plain')





    if nargin<3
        u_min=varargin{1};
        y_sat=u;
        tempInds=u<u_min;
        y_sat(tempInds)=u_min;
        return
    elseif nargin==3
        u_min=varargin{1};
        u_max=varargin{2};
        y_sat=u;
        if~isempty(u_min)
            tempInds=u<u_min;
            y_sat(tempInds)=u_min;
        end
        tempInds=u>u_max;
        y_sat(tempInds)=u_max;
    else
        error(getString(message('autoblks_shared:autoblksharedErrorMsg:UnexpectedInput')));
    end
