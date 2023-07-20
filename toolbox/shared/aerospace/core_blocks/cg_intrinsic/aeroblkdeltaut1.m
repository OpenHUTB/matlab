function out=aeroblkdeltaut1(MJD,mjdData,ut1utcData,errorflag)




%#codegen
    coder.allowpcode('plain');
    coder.license('checkout','Aerospace_Toolbox');
    coder.license('checkout','Aerospace_Blockset');



    if MJD>=mjdData(end)+1


        if~errorflag

            bessDate=2000+(MJD-51544.03)/365.2422;

            dUT2UT1=0.022*sin(2*pi*bessDate)-0.012*cos(2*pi*bessDate)...
            -0.006*sin(4*pi*bessDate)+0.007*cos(4*pi*bessDate);

            out=0.5382-0.00124*(MJD-57801)-dUT2UT1;

            if abs(out)>0.9
                out=sign(out)*0.9;
            end
        else
            out=NaN;
        end
    elseif MJD<mjdData(1)


        out=ut1utcData(1);
    else

        if MJD<mjdData(end)+1&&MJD>=mjdData(end)

            out=ut1utcData(end);
        else
            idx=find((MJD<mjdData));
            out=ut1utcData(idx(1)-1);
        end

    end

