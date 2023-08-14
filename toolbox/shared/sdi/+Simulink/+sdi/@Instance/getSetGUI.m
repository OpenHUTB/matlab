function gui=getSetGUI(obj)

    mlock;
    persistent SDI_GUI;
    if nargin>0
        SDI_GUI=obj;
    elseif~isempty(SDI_GUI)&&~isvalid(SDI_GUI)
        SDI_GUI=[];
    end
    gui=SDI_GUI;
end
