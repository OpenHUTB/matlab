function loadFromBlock(this)
    params=get(this.Block,'DialogParameters');
    paramNames=fieldnames(params);
    this.HasRoundingMode=ismember('roundingMode',paramNames);
    this.HasOverflowMode=ismember('overflowMode',paramNames);


    if this.HasRoundingMode
        this.RoundingMode=this.Block.roundingMode;
    end
    if this.HasOverflowMode
        this.OverflowMode=strcmpi(this.Block.overflowMode,'on');
    end


    if~isempty(this.DataTypeRows)
        for dtrInd=1:length(this.DataTypeRows)
            this.DataTypeRows(dtrInd).loadFromBlock;
        end


        this.LockScale=strcmpi(this.Block.LockScale,'on');
    else

        this.LockScale=0;
    end


