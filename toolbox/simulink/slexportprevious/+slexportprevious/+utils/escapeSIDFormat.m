function escString=escapeSIDFormat(string)






    p=inputParser;
    p.addRequired('string',@ischar);
    p.parse(string);

    escString=strrep(string,':','&:');
end
