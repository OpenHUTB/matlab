function location_out=unescape(location)













    location_out=[];

    if isempty(location)
        return
    end

    location=strrep(location,'_s','/');
    location=strrep(location,'_c',':');
    location=strrep(location,'_u','_');

    location_out=location;
end
