function updateFontProperties(hObj,peerAxes)








    if isempty(peerAxes)||~isvalid(peerAxes)
        return
    end


    if strcmp(hObj.FontNameMode,'auto')
        hObj.FontName_I=peerAxes.FontName;
    end


    if strcmp(hObj.FontAngleMode,'auto')
        hObj.FontAngle_I=peerAxes.FontAngle;
    end


    if strcmp(hObj.FontSizeMode,'auto')
        if~strcmpi(peerAxes.FontUnits,'points')




            switch peerAxes.FontUnits
            case 'inches'
                fontSize=peerAxes.FontSize_I*72;
            case 'centimeters'
                fontSize=(peerAxes.FontSize_I/2.54)*72;
            case 'normalized'



                hFig=ancestor(peerAxes,'figure');
                pos=hgconvertunits(hFig,peerAxes.Position_I,...
                peerAxes.Units_I,'points',peerAxes.Parent);



                axesHeight=pos(4);
                fontSize=round(peerAxes.FontSize_I*axesHeight);
            case 'pixels'
                screenDPI=get(groot,'ScreenPixelsPerInch');
                fontSize=(peerAxes.FontSize_I*72)/screenDPI;
            end
        else
            fontSize=peerAxes.FontSize_I;
        end

        if abs(round(fontSize)-fontSize)<100*eps(fontSize)




            fontSize=round(fontSize);
        end

        hObj.FontSize_I=.9*fontSize;
    end


    if strcmp(hObj.FontWeightMode,'auto')
        hObj.FontWeight_I=peerAxes.FontWeight_I;
    end
end

