function this=initSPCUniFixptDialog(this,controller,dtRowStructInputArgs)







    startRowIdx=2;
    row=startRowIdx;
    lenBaseDTs=length(dtRowStructInputArgs);
    if lenBaseDTs==0
        dtRows=handle(ones(1,0));
    else
        for ind=1:lenBaseDTs
            dtRows(ind)=...
            DVUnifiedFixptDlgDDG.SPCUniFixptDTRow(dtRowStructInputArgs{ind},...
            row,...
            controller);%#ok
            row=row+1;
        end
    end




    this.Controller=controller;
    this.Block=controller.block;
    this.TotalOpRows=1;
    this.DataTypeRows=dtRows;
    this.TotalDataTypeRows=length(this.DataTypeRows)+startRowIdx;
    this.loadFromBlock;