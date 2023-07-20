function tstamp=makeLogDir(prefix,postfix,parentPath)



    tstamp=datestr(now);
    tstamp=strrep(tstamp,' ','-');
    tstamp=strrep(tstamp,':','-');
    tstamp=[prefix,tstamp,postfix];
    tstamp=fullfile(parentPath,tstamp);
    mkdir(tstamp);
end