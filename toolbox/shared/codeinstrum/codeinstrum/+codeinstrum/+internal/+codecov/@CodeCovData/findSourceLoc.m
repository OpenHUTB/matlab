



function objs=findSourceLoc(this,fileName,fcnName)

    narginchk(3,3);

    if isempty(fcnName)
        if isempty(fileName)




            objs=this.CodeTr.getFilesInResults();
        else
            objs=this.CodeTr.findFile(fileName);
        end
    else
        objs=this.CodeTr.findFunction(fileName,fcnName);
    end
