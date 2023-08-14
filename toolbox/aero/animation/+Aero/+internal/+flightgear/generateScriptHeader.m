function[lines,errorThrown]=generateScriptHeader(h,operatingSystem)




    lines=repmat(string(missing),3,1);
    errorThrown=false;

    if operatingSystem=="PCWIN64"

        lines(1)=extractBefore(h.FlightGearBaseDirectory,3);
        lines(3)="cd "+h.FlightGearBaseDirectory;

        if(lines(1).startsWith("\\"))

            warnmsg=message('aero:aerofgrunscript:InvalidUNC',h.FlightGearBaseDirectory);
            warntitle=message('aero:aerofgrunscript:WarningTitle');
            h.throwWarning(warnmsg,warntitle);
        elseif~(lines(1).startsWith(lettersPattern(1)+":"))

            errormsg=message('aero:aerofgrunscript:InvalidPath',h.FlightGearBaseDirectory);
            errortitle=message('aero:aerofgrunscript:InvalidFileNameTitle');
            h.throwError(errormsg,errortitle);
            errorThrown=true;
            return
        end
    else
        if ispc

            shell="/bin/bash";
        else

            [~,shell]=system('echo $0');
            shell=extract(string(shell),wildcardPattern+lineBoundary("end"));
            shell(shell=="")=[];
        end


        lines(1)="#!"+shell;


        if(operatingSystem=="MACI64"||operatingSystem=="MACA64")
            lines(3)="cd "+h.FlightGearBaseDirectory+"/Contents/Resources";
        else
            lines(2:end)=[];
        end
    end

end
