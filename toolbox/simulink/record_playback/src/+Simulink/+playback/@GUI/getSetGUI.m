function gui=getSetGUI(blockId,obj)

    mlock;
    persistent SDI_GUI_MAP;

    if isempty(SDI_GUI_MAP)
        SDI_GUI_MAP=containers.Map;
    end


    if nargin>1
        SDI_GUI_MAP(blockId)=obj;
        gui=obj;
        return
    end


    gui=[];
    if SDI_GUI_MAP.isKey(blockId)
        gui=SDI_GUI_MAP(blockId);
    end


    if~isempty(gui)&&~isvalid(gui)
        gui=[];
    end
end