function setImplParams(this,params)





    implMap=this.getImplParamInfo;
    clkParams={'clockinputport','clockenableinputport','resetinputport'};

    uniqueLen=[6,6,1];
    addClkParams={'addclockport','addclockenableport','addresetport'};
    for ii=1:1:numel(clkParams)
        clkParam=clkParams{ii};
        if~any(strncmpi(params,clkParam,uniqueLen(ii)))

            addClkParam=addClkParams{ii};

            addClkParamIdx=find(strcmpi(params,addClkParam),1);
            if isempty(addClkParamIdx)||...
                (~isempty(addClkParamIdx)&&strcmpi(params{addClkParamIdx+1},'on'))


                val=implMap(clkParam).DefaultValue;
                params=[params,clkParams(ii),{val}];%#ok<AGROW>
            end
        end
    end

    this.implParams=params;


