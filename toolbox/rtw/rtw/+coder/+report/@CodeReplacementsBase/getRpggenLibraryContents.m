function[tflList,tflName]=getRpggenLibraryContents(obj)




    import mlreportgen.dom.*;
    tflList={};

    crls=coder.internal.getCRLs(obj.getTargetRegistry,obj.LibName);
    if~isempty(crls)
        n=length(crls);
        for i=1:n
            aTfl=crls(i);
            if isempty(aTfl)
                continue;
            end

            tflName=aTfl.Name;
            tflList=obj.addRptgenLibraryContentsToList(tflName,tflList);
            baseTfl=aTfl.BaseTfl;
            while~isempty(baseTfl)
                tflList=obj.addRptgenLibraryContentsToList(baseTfl,tflList);
                baseTfl=coder.internal.getTfl(obj.getTargetRegistry,baseTfl).BaseTfl;
            end
        end
    end
end
