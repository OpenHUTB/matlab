function updateLayout(hObj)





    if hObj.NumPeers>1
        hPeers=hObj.AreaPeers;




        flags=vertcat(hPeers.PrepWasAlreadyRun);
        if~any(flags)||all(flags)
            if all(flags)
                set(hPeers,'PrepWasAlreadyRun',false);
            end
            matlab.graphics.chart.primitive.Area.computeLayout(hPeers);
        end
        hObj.PrepWasAlreadyRun=true;
    else
        matlab.graphics.chart.primitive.Area.computeLayout(hObj);
    end
