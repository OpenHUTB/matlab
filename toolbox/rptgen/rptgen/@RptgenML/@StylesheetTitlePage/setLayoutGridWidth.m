function acceptedValue=setLayoutGridWidth(h,newValue)




    h.Format.LayoutGrid.Width=newValue;
    if isempty(newValue)
        h.LOGridWidthType='page';
    else
        h.LOGridWidthType='specify';
    end
    acceptedValue=newValue;
