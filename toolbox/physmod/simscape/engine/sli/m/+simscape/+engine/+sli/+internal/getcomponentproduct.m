function product=getcomponentproduct(sourceFile)





    product='';

    lb=PmSli.LibraryDatabase;
    [isInLib,entry]=lb.containsFile(which(sourceFile));
    if isInLib
        product=entry{1}.Product;
    end

end
