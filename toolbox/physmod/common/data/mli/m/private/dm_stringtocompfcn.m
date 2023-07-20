function fcn=dm_stringtocompfcn(fcn,varargin)
















    persistent MAP;

    if~ischar(fcn)
        pm_error('network_engine:ne_stringtocmpfcn:InvalidInputType');
    end

    includeMsgText=false;%#ok
    fcnText=fcn;

    if nargin==2&&strcmpi(varargin,'-message')
        includeMsgText=true;%#ok
    end




    if isempty(MAP)
        MAP={'==',@eq,'equal to';
        '~=',@ne,'not be equal to';
        '<',@lt,'less than';
        '>',@gt,'greater than';
        '<=',@le,'less than or equal to';
        '>=',@ge,'greater than or equal to'};
    end




    idx=strcmp(MAP(:,1),fcn);





    if any(idx)
        fcn=MAP{idx,2};
    else
        fcn=str2func(fcn);
    end

    if nargin==2&&strcmpi(varargin,'-message')
        if any(idx)
            fcn={fcn,MAP{idx,3}};
        else
            fcn={fcn,fcnText};
        end
    end
end
