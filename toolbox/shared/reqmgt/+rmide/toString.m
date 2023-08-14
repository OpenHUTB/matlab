function stringId=toString(entry)




    [fPath,dPath,label]=rmide.resolveEntry(entry);

    stringId=[fPath,'|',dPath,'.',label];

end