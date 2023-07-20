function out=getStatus(obj,cs,varargin)







    if nargin>=3
        adp=varargin{1};
    else
        adp=configset.internal.getConfigSetAdapter(cs);
    end
    for i=1:length(obj.ParentList)
        pl=obj.ParentList{i};
        val=adp.getParamValue(pl.Name,pl.Name,cs);
        if loc_contains(pl,val)
            out=0;
            return;
        end
    end
    if isempty(obj.License)
        out=obj.StatusLimit;
    else
        out=obj.License.getStatus(cs);
    end

    function out=loc_contains(pl,v)

        if isempty(pl.ValueSet)
            out=false;
            return;
        end
        for i=1:length(pl.ValueSet)


            if islogical(v)
                if v
                    v='on';
                else
                    v='off';
                end
            end

            if isequal(v,pl.ValueSet{i})
                out=~pl.Negate;
                return;
            end
        end
        out=pl.Negate;
