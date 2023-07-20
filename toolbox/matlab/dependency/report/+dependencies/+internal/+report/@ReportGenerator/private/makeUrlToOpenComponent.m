function url=makeUrlToOpenComponent(loc,compPath,depType,action)




    argString=i_addApices(loc);
    compPath=regexprep(compPath,'\s',' ');
    argString=argString+","+i_addApices(compPath);
    argString=argString+","+i_addApices(depType.ID);
    url="matlab:dependencies.internal.report."+action+"("+argString+")";
end


function str=i_addApices(str)
    str="'"+str+"'";
end
