function out=convertTimeStamp(str)




    out=0.0;
    if~isempty(str)
        dnum=[];
        try
            firstWord=strtok(str);

            if any(strcmp({'Sun','Mon','Tue','Wed','Thu','Fri','Sat'},firstWord))
                str=str(1+length(firstWord):end);
            end
            if~isempty(str)
                dnum=datenum(str);
            end
        catch me %#ok<NASGU>
        end
        if~isempty(dnum)
            out=RTW.TraceInfo.datenum2timestamp(dnum);
        end
    end
end

