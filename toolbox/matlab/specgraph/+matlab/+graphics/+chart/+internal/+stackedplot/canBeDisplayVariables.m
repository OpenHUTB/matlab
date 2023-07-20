function tf=canBeDisplayVariables(tbl,isInner,ind)




    if isInner
        fh=@isInnerVariablePlottable;
    else
        fh=@isVariablePlottable;
    end
    if nargin<3
        tf=varfun(fh,tbl,'OutputFormat','uniform');
    elseif iscell(ind)
        tf=false(size(ind));
        for i=1:length(ind)
            indc=ind{i};
            if isscalar(indc)
                v=tbl.(indc);
                tf(i)=fh(v);
            else
                tf(i)=all(varfun(fh,tbl(:,indc),'OutputFormat','uniform'));
            end
        end
    else
        tf=varfun(fh,tbl(:,ind),'OutputFormat','uniform');
    end
end

function tf=isInnerVariablePlottable(v)
    tf=((isdatetime(v)||isduration(v)||isnumeric(v)||islogical(v)||...
    iscategorical(v))&&size(v(:,:),2)>0);
end

function tf=isVariablePlottable(v)
    tf=((isdatetime(v)||isduration(v)||isnumeric(v)||islogical(v)||...
    iscategorical(v))&&size(v(:,:),2)>0)||(isa(v,'tabular')&&...
    any(varfun(@isInnerVariablePlottable,v,'OutputFormat','uniform')));
end
