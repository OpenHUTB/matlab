function OnColorButton(hThis,dlgSrc,objSrc)



    color=str2num(hThis.ColorVector);
    c=uisetcolor(color);
    hThis.ColorVector=strcat(mat2str(c',6));

    dlgSrc.enableApplyButton(true);
    dlgSrc.refresh();



