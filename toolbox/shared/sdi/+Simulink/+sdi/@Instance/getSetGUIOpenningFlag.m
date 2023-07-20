function isOpening=getSetGUIOpenningFlag(val)

    mlock;
    persistent GUIIsOpening;
    if nargin>0
        GUIIsOpening=val;
    elseif isempty(GUIIsOpening)
        GUIIsOpening=false;
    end
    isOpening=GUIIsOpening;
end

