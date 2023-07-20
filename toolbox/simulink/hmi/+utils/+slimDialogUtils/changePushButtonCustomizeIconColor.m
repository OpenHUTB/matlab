function changePushButtonCustomizeIconColor(dlg,pushbuttonBlockHandle,checked,isSlimDialog)

    if isSlimDialog
        set_param(pushbuttonBlockHandle,'IconColor',double(checked));
    end
    dlg.setEnabled('icon_color_webbrowser',checked);
end