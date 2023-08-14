function dlgSetSrcProp(this,tag,value)





    switch tag
    case 'RowNum'
        this.CurrElemRow=value+1;
    case 'RowSpan'
        this.CurrElemRowSpan=str2double(value);
    case 'ColNum'
        this.CurrElemCol=value+1;
    case 'ColSpan'
        this.CurrElemColSpan=str2double(value);
    case 'FontSize'
        this.CurrElemFontSize=value;
    case 'Color'
        eColors=RptgenML.enumColors;
        color=char(eColors.strings(ismember(eColors.DisplayNames,value)));
        if isempty(color)
            color=value;
        end
        this.CurrElemColor=color;
    case 'IsBold'
        this.CurrElemIsBold=value;
    case 'IsItalic'
        this.CurrElemIsItalic=value;
    case 'HAlign'
        eHAlign=RptgenML.enumHorizAlign;
        align=eHAlign.strings{value+1};
        this.CurrElemHAlign=align;
    case 'XForm'
        this.CurrElemXForm=value;
    end
