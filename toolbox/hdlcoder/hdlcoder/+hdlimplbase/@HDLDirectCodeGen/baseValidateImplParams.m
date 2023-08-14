function v=baseValidateImplParams(this,~)












    v=hdlvalidatestruct;

    if~isempty(this.implParams)&&iscell(this.implParams)
        names=implParamNames(this);

        if mod(length(this.implParams),2)~=0
            v(end+1)=hdlvalidatestruct(2,...
            message('hdlcoder:validate:oddnumimplparams'));
            this.implParams(end)=[];
        end

        if~isempty(this.implParams)

            properties=this.implParams(1:2:end);
            notstrings=not(cellfun(@ischar,properties));
            if~isempty(find(notstrings,1))
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:validate:nonstringproperty'));
            end
        end

        for ii=1:2:length(this.implParams)
            param=this.implParams{ii};
            m=find(strncmpi(param,names,length(param)));
            if isempty(m)
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:validate:unknownImplProperty'));%#ok<*AGROW>
            elseif length(m)>1
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:validate:nonuniqueproperty'));
            end
        end
    end




    for ii=1:2:length(this.implParams)
        implParam=this.implParams{ii};

        if this.implParamInfo.isKey(lower(implParam))


            implParamInfo=this.implParamInfo(lower(implParam));
            value=this.getImplParams(implParam);
            [v(end+1),~]=validateParamValue(value,implParamInfo);
        end
    end

end


