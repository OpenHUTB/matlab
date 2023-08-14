function widget=CreateTableWidget(this)














    widget.Mode=0;
    widget.Type='table';
    widget.Tag=this.TableName;
    widget.Size=double([this.NumRows,this.NumCols]);
    widget.Grid=1;
    widget.HeaderVisibility=[0,1];
    widget.FontFamily='Courier';
    widget.Editable=true;
    widget.Enabled=1;
    widget.Tunable=0;
    widget.SelectedRow=double(this.CurrRow-1);


    [widget.ColumnCharacterWidth,widget.ColHeader,widget.ColumnHeaderHeight]=...
    this.GetColInfo;











    char2PixelFudge=10.5;

    heightGuess=0;
    widthGuess=(char2PixelFudge*sum(widget.ColumnCharacterWidth));
    widget.MinimumSize=[widthGuess,heightGuess];


    if this.NumRows<=0
        widget.Data={''};
        return;
    else
        widget.Data=this.CreateTableData;
    end

end


