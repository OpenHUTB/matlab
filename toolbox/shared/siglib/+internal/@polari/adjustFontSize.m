function adjustFontSize(p)











    p.pFontSize=getFontSize(p);


    updateAngleFont(p);
    updateMagFont(p);
    updateTitleFont(p);


    notify(p,'FontChanged');
