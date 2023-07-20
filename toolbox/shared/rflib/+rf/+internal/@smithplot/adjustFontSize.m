function adjustFontSize(p)










    p.pFontSize=getFontSize(p);


    updateAngleFont(p);
    updateResFont(p);
    updateTitleFont(p);


    notify(p,'FontChanged');
