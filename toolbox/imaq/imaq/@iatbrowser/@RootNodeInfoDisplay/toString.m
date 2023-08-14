function displayString=toString(~)















    warnState=warning('off','imaq:imaqhwinfo:additionalVendors');
    info=imaqhwinfo;
    warning(warnState);

    stringTemplate=...
    ['<html>'...
    ,'<h3>%s</h3>'...
    ,'<table>'...
    ,'<tr><td align="left">Toolbox version:</td><td>%s</td></tr>'...
    ,'<tr><td align="left">MATLAB version:</td><td>%s</td></tr>'...
    ,'<tr><td align="left">Installed adaptors:</td><td>%s</td></tr>'...
    ,'</table>'...
    ,'</html>'];

    adaptors=sprintf('%s, ',info.InstalledAdaptors{:});
    adaptors=adaptors(1:end-2);

    displayString=sprintf(stringTemplate,info.ToolboxName,...
    info.ToolboxVersion,...
    info.MATLABVersion,...
    adaptors);