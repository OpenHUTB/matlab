function schema

    pk=findpackage('xregGui');
    c=schema.class(pk,'SystemColors');

    s=i_getcolors;

    i_addproperty(c,'CTRL_TEXT',s,'CTRL_TEXT');
    i_addproperty(c,'CTRL_BACK',s,'CTRL_BACK');
    i_addproperty(c,'CTRL_BG',s,'CTRL_BACK');
    i_addproperty(c,'CTRL_SHADOW',s,'CTRL_SHADOW');
    i_addproperty(c,'CTRL_DK_SHADOW',s,'CTRL_DK_SHADOW');
    i_addproperty(c,'CTRL_HILITE',s,'CTRL_HILITE');
    i_addproperty(c,'CTRL_LT_HILITE',s,'CTRL_LT_HILITE');
    i_addproperty(c,'CTRL_SELECTED_BG',s,'CTRL_SELECTED_BG');
    i_addproperty(c,'CTRL_SELECTED_TEXT',s,'CTRL_SELECTED_TEXT');
    i_addproperty(c,'TITLE_INACTIVE_BG',s,'TITLE_INACTIVE_BG');
    i_addproperty(c,'TITLE_INACTIVE_TEXT',s,'TITLE_INACTIVE_TEXT');
    i_addproperty(c,'TITLE_ACTIVE_BG',s,'TITLE_ACTIVE_BG');
    i_addproperty(c,'TITLE_ACTIVE_TEXT',s,'TITLE_ACTIVE_TEXT');
    i_addproperty(c,'WINDOW_BG',s,'WINDOW_BG');


    function s=i_getcolors
        s=struct('CTRL_TEXT',uint8(255*get(0,'DefaultUicontrolForegroundColor')),...
        'CTRL_BACK',uint8(255*get(0,'DefaultUicontrolBackgroundColor')),...
        'CTRL_SHADOW',[160,160,160],...
        'CTRL_DK_SHADOW',[105,105,105],...
        'CTRL_HILITE',[227,227,227],...
        'CTRL_LT_HILITE',[255,255,255],...
        'CTRL_SELECTED_BG',[0,120,215],...
        'CTRL_SELECTED_TEXT',[255,255,255],...
        'TITLE_INACTIVE_BG',[255,255,255],...
        'TITLE_INACTIVE_TEXT',[0,0,0],...
        'TITLE_ACTIVE_BG',[153,180,209],...
        'TITLE_ACTIVE_TEXT',[0,0,0],...
        'WINDOW_BG',uint8(255*get(0,'DefaultAxesColor')));


        function i_addproperty(c,PropName,s,StructField)
            p=schema.prop(c,PropName,'MATLAB array');
            p.AccessFlags.PublicSet='off';
            p.AccessFlags.Init='on';
            p.AccessFlags.Listener='off';
            if isfield(s,StructField)
                p.FactoryValue=uint8(s.(StructField));
            else
                p.FactoryValue=uint8([0,0,0]);
            end
