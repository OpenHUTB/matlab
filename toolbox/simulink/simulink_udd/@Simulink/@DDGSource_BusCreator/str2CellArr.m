function[cellarr]=str2CellArr(~,str)






    signalList=strsplit(str,',');

    cellarr=regexprep(signalList,'^''(.*)''$','$1');

end

