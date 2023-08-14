function[tflList,tflName]=getLibraryContents(obj)




    tflList=[];
    tflName=obj.LibName;
    crls=coder.internal.getCRLs(obj.getTargetRegistry,obj.LibName);
    if~isempty(crls)
        tflList=Advisor.List;
        tflList.setType('Bulleted');
        n=length(crls);
        for i=1:n
            aTfl=crls(i);
            if isempty(aTfl)
                continue;
            end

            tflName=aTfl.Name;
            tflList=obj.addLibraryContentsToList(tflName,tflList);
            baseTfl=aTfl.BaseTfl;
            while~isempty(baseTfl)
                tflList=obj.addLibraryContentsToList(baseTfl,tflList);
                baseTfl=coder.internal.getTfl(obj.getTargetRegistry,baseTfl).BaseTfl;
            end
        end
    end
end
