function schema








    hCreateInPackage=findpackage('PMDialogs');
    hBaseObj=hCreateInPackage.findclass('PmGuiObj');


    hThisClass=schema.class(hCreateInPackage,'PmGroupPanel',hBaseObj);


    schema.prop(hThisClass,'LabelText','ustring');

    if isempty(findtype('GroupBoxStyleEnum'))
        schema.EnumType(...
        'GroupBoxStyleEnum',...
        {'NoBoxNoTitle','Box','NoBoxWithTitle','NoBoxWithTitleAndLine',...
        'NoBoxWithTitleAndSpace','HorzLine','Flat','TabContainer',...
        'TabPage','Spacer','VerticalAlignment'},[1,2,3,4,5,6,7,8,9,10,11]...
        );
    end

    if isempty(findtype('StdLayout'))
        schema.EnumType('StdLayout',...
        {'Unset','1ColLayout','2ColLayout',...
        '3ColLayout','4ColLayout'},[0,1,2,3,4]...
        );
    end


    schema.prop(hThisClass,'Style','GroupBoxStyleEnum');
    schema.prop(hThisClass,'StdLayoutCfg','StdLayout');


    schema.prop(hThisClass,'BoxStretch','bool');


