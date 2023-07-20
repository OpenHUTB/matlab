


function out=getDateStr(propValue)




    if isa(propValue,'datetime')
        if isnat(propValue)
            out=getString(message('Slvnv:slreq:NoVersionAvaiable'));
        else
            out=datestr(propValue,'Local');
        end
    elseif isa(propValue,'double')

        if propValue==0
            out=getString(message('Slvnv:slreq:NoVersionAvaiable'));
        else
            out=slreq.utils.getDateStr(datetime(propValue,'ConvertFrom','posixtime','TimeZone','Local'));
        end
    else

        out=propValue;
    end
end