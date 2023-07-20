function ConnectorInfoGlyphAction(connType,origOwners,origReaders,origWriters,origReaderWriters)

    if(~isempty(origOwners)||~isempty(origReaders)||...
        ~isempty(origWriters)||~isempty(origReaderWriters))

        screenSize=get(0,'ScreenSize');


        pointerLocation=get(0,'PointerLocation');


        pointerLocation(2)=screenSize(4)-pointerLocation(2);


        connectorInfoLinks=Simulink.ConnectorInfoLinks(...
        connType,origOwners,origReaders,origWriters,origReaderWriters);
        dlg=DAStudio.Dialog(connectorInfoLinks);
        dlg.position(1:2)=pointerLocation;
        dlg.show;
    end


