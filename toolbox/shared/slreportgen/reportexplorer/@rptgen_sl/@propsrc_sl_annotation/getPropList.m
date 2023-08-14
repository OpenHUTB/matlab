function list=getPropList(h,filterName)




    switch filterName
    case 'all'
        list={
'Name'
'Tag'
'Description'
'Type'
'Parent'
'Handle'
'HiliteAncestors'
'Position'
'HorizontalAlignment'
'VerticalAlignment'
'ForegroundColor'
'BackgroundColor'
'Text'
'DropShadow'
'TeXMode'
'FontName'
'FontSize'
'FontWeight'
'FontAngle'
'Selected'
'ClickFcn'
'LoadFcn'
'DeleteFcn'
'UseDisplayTextAsClickCallback'
'UserData'
        };
    case 'main'
        list={
'Description'
'Parent'
'Text'
'ClickFcn'
        };
    case 'callback'
        list={
'ClickFcn'
'LoadFcn'
'DeleteFcn'
'UseDisplayTextAsClickCallback'
        };
    otherwise
        list={};
    end



