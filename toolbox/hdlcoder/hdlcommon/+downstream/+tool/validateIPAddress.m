function validateIPAddress(ipAddr)




    if~ischar(ipAddr)
        error('IP address must be specified as a character array.');
    end


    ipAddr=strtrim(ipAddr);
    tmp=regexp(ipAddr,'(?:\d{1,3}\.){3}\d{1,3}','match');
    if(isempty(tmp)||~isequal(tmp{1},ipAddr))
        error('%s is not a valid IP address.',ipAddr);
    end

end