function messages=runPIRConstrainer(fcnInfoRegistry,exprMap,constrainerArgs)





    internal.mtree.Type.setIntegersSaturateOnOverflow(constrainerArgs.IntsSaturate);

    fcnInfos=fcnInfoRegistry.getAllFunctionTypeInfos;


    hasClass=cellfun(@(x)~isempty(x.className),fcnInfos);

    fcnsWithoutClass=fcnInfos(~hasClass);
    messagesWithoutClass=cell(1,numel(fcnsWithoutClass));
    for i=1:numel(fcnsWithoutClass)
        constrainer=internal.ml2pir.constrainer.PIRConstrainer(fcnsWithoutClass{i},...
        exprMap,fcnInfoRegistry,constrainerArgs);
        messagesWithoutClass{i}=constrainer.run;
    end
    messagesWithoutClass=[messagesWithoutClass{:}];


    msgsAreUnsupSysObjMsgs=arrayfun(...
    @(x)strcmp(x.id,'hdlcommon:matlab2dataflow:UnsupportedAuthoredSystemObject'),...
    messagesWithoutClass);
    unsupSysObjMsgs=messagesWithoutClass(msgsAreUnsupSysObjMsgs);
    unsupportedClasses={unsupSysObjMsgs.params};


    fcnsWithClass=fcnInfos(hasClass);
    messagesWithClass=cell(1,numel(fcnsWithClass));
    for i=1:numel(fcnsWithClass)
        fcn=fcnsWithClass{i};
        if lowersysobj.isPIRSupportedObject(fcn.className)
            continue;
        elseif any(cellfun(@(x,y)strcmp(x{1},y),unsupportedClasses,repmat({fcn.className},size(unsupportedClasses))))


            continue;
        end
        constrainer=internal.ml2pir.constrainer.PIRConstrainer(fcn,...
        exprMap,fcnInfoRegistry,constrainerArgs);
        messagesWithClass{i}=constrainer.run;
    end


    messages=[messagesWithoutClass,messagesWithClass{:}];
end

