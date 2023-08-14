function quantityNames=getQuantityNamesForTabCompletion(p)








    [varNames,objNames,conNames]=getQuantityNames(p);
    quantityNames=[varNames;objNames;conNames];

end