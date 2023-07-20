function loadFromBlock(this)







    this.RoundingMode=udtGetPopupValueFromBlock(this,'roundingMode');
    if strcmpi(this.Block.overflowMode,'on')
        this.OverflowMode='Saturate';
    else
        this.OverflowMode='Wrap';
    end

    if this.hasLockScale
        this.LockScale=strcmpi(this.Block.LockScale,'on');
    end


    if~isempty(this.ExtraOp)
        for ind=1:length(this.ExtraOp)
            this.ExtraOp(ind).loadFromBlock;
        end
    end


    if~isempty(this.DataTypeRows)
        for dtrInd=1:length(this.DataTypeRows)
            this.DataTypeRows(dtrInd).loadFromBlock;
        end
    end

    function pValue=udtGetPopupValueFromBlock(this,paramName)









        bStrings=set(this.Block,paramName);


        ddgStrings=set(this,paramName);

        if length(bStrings)~=length(ddgStrings)
            error(message('dspshared:dialog:popupLengthsDiffer'));
        end


        bValue=get(this.Block,paramName);



        idx=find(strcmp(bStrings,bValue)==true);

        if isempty(idx)
            error(message('dspshared:dialog:missingPopupValue'));
        end


        pValue=ddgStrings{idx};


