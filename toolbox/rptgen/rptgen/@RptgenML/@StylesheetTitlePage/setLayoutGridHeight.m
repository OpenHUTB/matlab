function acceptedValue=setLayoutGridHeight(h,newValue)




    h.Format.LayoutGrid.Height=newValue;
    if isempty(newValue)
        h.LOGridHeightType='page';
    else
        h.LOGridHeightType='specify';
    end
    acceptedValue=newValue;