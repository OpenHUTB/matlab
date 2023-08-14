function v=validateImplParams(this,hC)





    v=baseValidateImplParams(this,hC);

    tmpv=validateEnumParam(this,hC,'DistributedPipelining',{'on','off','inherit'});
    if tmpv.Status~=0
        v(end+1)=tmpv;
    end

    tmpv=validateOnOffParam(this,'FlattenHierarchy',true);
    if tmpv.Status~=0
        v(end+1)=tmpv;
    end

    tmpv=validateOnOffParam(this,'BalanceDelays',true);
    if tmpv.Status~=0
        v(end+1)=tmpv;
    end

    v(end+1)=validateEnumParam(this,hC,'DSPStyle',{'on','off','none'});

end

function v=validateOnOffParam(this,param,andInherit)

    v=hdlvalidatestruct(0,'','hdlcoder:validate:');

    value=this.getImplParams(param);

    if~isempty(value)
        if andInherit&&strcmpi(value,'inherit')
            return;
        end
        if~strcmpi(value,'on')&&~strcmpi(value,'off')
            v=hdlvalidatestruct(1,[param,' value must be either on or off'],'hdlcoder:validate:unknownproperty');
        end
    end
end


