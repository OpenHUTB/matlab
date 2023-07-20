function OnTableValueChangeCB(this,dlg,trow,tcol,value)














    srow=trow+1;
    scol=tcol+1;
    scolName=this.colName{scol};

    if(srow<1||srow>this.NumRows)
        error(message('HDLLink:OnTableValueChangeCB:BadIndex'));
    end
    hRow=this.RowSources(srow);


    switch(scolName)
    case 'ioMode'
        if(value~=hRow.ioMode)
            hRow.ioMode=value;
            switch(value)
            case 1

                hRow.sampleTime='Inherit';
                hRow.datatype=-1;
                hRow.fracLength='Inherit';
            case 2
                hRow.sampleTime=this.LastUninheritedValues.sampleTime;
                hRow.datatype=-1;
                hRow.fracLength='Inherit';
            end
        end
    case 'datatype'
        if(value~=hRow.datatype)
            hRow.datatype=value;
            switch(value)
            case-1
                hRow.fracLength='Inherit';
            case 0
                hRow.fracLength=this.LastUninheritedValues.fracLength;
            otherwise
                hRow.fracLength='0';
                hRow.sign=1;
            end
        end
    case 'sign'
        hRow.sign=value;
    case 'path'
        hRow.path=value;
    case{'sampleTime','fracLength'}
        try






            hRow.(scolName)=value;
            this.LastUninheritedValues.(scolName)=value;
        catch
            warning(message('HDLLink:OnTableValueChangeCB:ValueNotNumber'));
        end
    end
    this.RefreshRow(dlg,srow);
end
