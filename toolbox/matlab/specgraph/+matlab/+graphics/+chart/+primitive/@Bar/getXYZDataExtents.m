function varargout=getXYZDataExtents(hObj,~,constraints)









    if hObj.NumPeers>1
        hPeers=matlab.graphics.chart.primitive.bar.internal.getBarPeers(hObj);

        flags=get(hPeers,'PrepWasAlreadyRun');
        if numel(hPeers)>1


            flags=[flags{:}]';
        end




        if~any(flags)||all(flags)
            if all(flags)
                set(hPeers,'PrepWasAlreadyRun',false);
            end
            hObj.computeLayout(hPeers);
        end
        hObj.PrepWasAlreadyRun=true;
    else
        hObj.computeLayout(hObj);
    end

    [xd,yd]=getSingleBarExtentsArray(hObj,constraints);


    xlim=matlab.graphics.chart.primitive.utilities.arraytolimits(xd);
    ylim=matlab.graphics.chart.primitive.utilities.arraytolimits(yd);
    zlim=[0,NaN,NaN,0];

    if strcmpi(hObj.Horizontal,'off')
        varargout{1}=[xlim;ylim;zlim];
    else
        varargout{1}=[ylim;xlim;zlim];
    end
