function opsEns=GetTableOperationsEnables(this)
    opsEns.AddRow=true;
    if this.NumRows>=1
        opsEns.DeleteRow=true;
    else
        opsEns.DeleteRow=false;
    end

    if this.CurrRow>1
        opsEns.MoveRowUp=true;
    else
        opsEns.MoveRowUp=false;
    end

    if this.CurrRow>0&&this.CurrRow<this.NumRows
        opsEns.MoveRowDown=true;
    else
        opsEns.MoveRowDown=false;
    end

    if this.NumRows==0
        opsEns.DeleteRow=false;
        opsEns.MoveRowUp=false;
        opsEns.MoveRowDown=false;
    end
end
