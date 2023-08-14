function allStructs=cscdefn2struct(packageName)







    allStructs=[];
    cscErrs={};
    msErrs={};

    try
        allDefns=processcsc('GetAllDefns',packageName);
    catch
        allDefns={[];[]};
    end

    cscStruct=[];
    cscDefns=allDefns{1};
    for i=1:length(cscDefns)
        cscName=cscDefns(i).Name;
        try
            cscStruct.(cscName)=cscDefns(i).convert2struct();
        catch e
            cscErrs{1,end+1}=cscName;%#ok
            cscErrs{2,end}=e.message;
        end
    end

    msStruct=[];
    msDefns=allDefns{2};
    for i=1:length(msDefns)
        msName=msDefns(i).Name;
        try
            msStruct.(msName)=msDefns(i).convert2struct();
        catch e
            msErrs{1,end+1}=msName;%#ok
            msErrs{2,end}=e.message;
        end
    end

    if(isempty(cscErrs)&&isempty(msErrs))
        invalidList=validatecsc(packageName,cscDefns,msDefns);
        cscErrs=invalidList{1};
        msErrs=invalidList{2};
    end

    cscErrsLen=size(cscErrs,2);
    msErrsLen=size(msErrs,2);

    errs=[];
    if((0~=msErrsLen)||(0~=cscErrsLen))
        errs=DAStudio.message('Simulink:dialog:PkgValidFailedCSC',packageName);
        if(0~=cscErrsLen)
            errs=[errs,DAStudio.message('Simulink:dialog:CSCMessageWithNewLine')];
            for i=1:cscErrsLen
                errs=[errs,sprintf('- %s: %s\n',cscErrs{1,i},cscErrs{2,i})];%#ok
            end
        end
        if(0~=msErrsLen)
            errs=[errs,DAStudio.message('Simulink:dialog:MSMessageWithNewLine')];
            for i=1:msErrsLen
                errs=[errs,sprintf('- %s: %s\n',msErrs{1,i},msErrs{2,i})];%#ok
            end
        end
    end

    allStructs.CSCDefs=cscStruct;
    allStructs.MemorySectionDefs=msStruct;
    allStructs.ErrorString=errs;


