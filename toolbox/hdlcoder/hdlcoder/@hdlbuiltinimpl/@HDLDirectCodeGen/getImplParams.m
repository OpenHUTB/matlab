function values=getImplParams(this,param)








    values=[];

    if~isempty(this.implParams)&&iscell(this.implParams)
        names=this.implParamNames;
        properties=this.implParams(1:2:end);
        for ii=1:length(properties)
            idx=strmatch(lower(properties{ii}),lower(names));
            if~isempty(idx)&&length(idx)==1
                properties{ii}=names{idx};
            end
        end
        propvalues=this.implParams(2:2:end);
        if iscell(param)
            values=cell(size(param));
            for ii=1:length(param)
                values{ii}=[];
                matches=strmatch(param,properties);
                if~isempty(matches)&&length(matches)==1
                    values{ii}=propvalues{matches};
                end
            end
        else
            values=[];
            matches=strmatch(lower(param),lower(properties));
            if~isempty(matches)
                if length(matches)==1&&matches<=length(propvalues)
                    values=propvalues{matches};
                else
                    matches=find(ismember(lower(properties),lower(param)));
                    if~isempty(matches)&&length(matches)==1&&matches<=length(propvalues)
                        values=propvalues{matches};
                    end
                end
            end

        end
    end
