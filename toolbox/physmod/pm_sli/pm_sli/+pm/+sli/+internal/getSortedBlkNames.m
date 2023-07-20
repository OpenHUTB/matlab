function[blkNames,I]=getSortedBlkNames(blkNames)




    [~,I]=sort(regexprep(blkNames,'\s+',' '));
    blkNames=blkNames(I);

end