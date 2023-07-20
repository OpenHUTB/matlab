function[doShortcut,pj,pt]=getframeWithDecorationsShortcut(pj)

















    persistent awtAvailable;
    if isempty(awtAvailable)
        awtAvailable=usejava('awt');
    end
    doShortcut=awtAvailable&&pj.isPaperPositionModeAuto()&&...
    strcmp(pj.Handles{1}.Visible,'on')&&...
    (~pj.DPI||pj.DPI==pj.Handles{1}.ScreenPixelsPerInch)&&...
    strcmp(pj.Renderer,pj.Handles{1}.Renderer)&&...
    strcmpi(pj.DriverClass,'IM')&&...
    pj.PrintUI&&...
    ~pj.DriverClipboard;

    if doShortcut

        pj.getCopyOptionsPreferences();


        [pj,pt]=printjobContentChanges('set',pj);
drawnow





        try
            frame=matlab.graphics.internal.getframeWithDecorations(pj.Handles{1},false,false);
        catch

            doShortcut=false;
        end
        if doShortcut


            if strcmpi(pj.CallerFunc,'print')
                matlab.graphics.internal.export.logDDUXInfo(pj);
            end

            pj.Return=frame.cdata;
            if pj.RGBImage

            else

                pj.writeRaster();
            end

            matlab.graphics.internal.printHelper.requestGCIfNeeded();
        end
        [pj,pt]=printjobContentChanges('restore',pj,pt);
    end
end
