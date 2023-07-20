function checkreadonlyproperty(h,varargin_not,names)







    if nargin~=3||isempty(varargin_not)||isempty(names)
        return
    end

    n=numel(varargin_not);
    if isa(names,'cell')
        m=numel(names);
        for ii=1:m
            name=names{ii};
            for jj=1:2:n
                if any(strcmpi(varargin_not{jj},name))
                    if isempty(h.Block)
                        rferrhole=h.Name;
                    else
                        rferrhole=upper(class(h));
                    end
                    error(message(['rf:rfbase:rfbase:'...
                    ,'checkreadonlyproperty:ReadOnly'],rferrhole,name));
                end
            end
        end
    elseif isa(names,'char')
        name=names;
        for jj=1:2:n
            if any(strcmpi(varargin_not{jj},name))
                if isempty(h.Block)
                    rferrhole=h.Name;
                else
                    rferrhole=upper(class(h));
                end
                error(message(['rf:rfbase:rfbase:'...
                ,'checkreadonlyproperty:ReadOnly'],rferrhole,name));
            end
        end
    end