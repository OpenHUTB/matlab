function CRLs=getCRLs(lTargetRegistry,Tfl_QueryString)









    if~contains(Tfl_QueryString,coder.internal.getCrlLibraryDelimiter)
        CRLs=coder.internal.getTfl(lTargetRegistry,Tfl_QueryString);
    else
        libNames=coder.internal.getCrlLibraries(Tfl_QueryString);
        num=length(libNames);
        CRLs(1:num)=RTW.TflRegistry;
        numNone=0;
        for i=1:num
            if strcmpi(libNames{i},'none')
                CRLs(i-numNone)=[];
                numNone=numNone+1;
            else
                CRLs(i-numNone)=coder.internal.getTfl(lTargetRegistry,libNames{i});
            end

        end
    end




