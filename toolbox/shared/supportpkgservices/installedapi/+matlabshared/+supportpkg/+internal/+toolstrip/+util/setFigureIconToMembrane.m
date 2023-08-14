function setFigureIconToMembrane(h)




    membraneIcon=matlab.ui.internal.toolstrip.Icon.MATLAB_16;
    iconPath=membraneIcon.getIconFile();
    h.Icon=iconPath;
end
