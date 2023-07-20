function printFig=prepareCopyToClipboard(this,printFig)





    prepareCopyToClipboard@matlabshared.scopes.visual.Visual(this,printFig);

    textColor=[0,0,0];
    hStatusReadOut=findall(printFig,'Tag','StatusBarReadoutText');
    set(hStatusReadOut,'Color',textColor);


    hColorbar=findobj(printFig,'Type','colorbar');
    set(hColorbar,'Color',textColor);


