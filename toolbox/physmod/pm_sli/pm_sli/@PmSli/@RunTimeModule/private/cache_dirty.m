function value=cache_dirty(mdl,value)







    if~isempty(mdl)

        if nargin==1

            value=get_param(mdl.Handle,'Dirty');

        else

            set_param(mdl.Handle,'Dirty',value);

        end

    end


