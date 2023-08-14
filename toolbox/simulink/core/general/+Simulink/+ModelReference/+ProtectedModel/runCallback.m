function runCallback(fullName,event,appliesTo)




    import Simulink.ModelReference.ProtectedModel.*;
    opts=getOptions(fullName,'runConsistencyChecksNoPlatform');
    if isempty(opts.callbackMgr)||~opts.callbackMgr.hasCallback(event,appliesTo)
        return;
    end

    narginchk(3,4);
    assert(strcmpi(appliesTo,'SIM')||strcmpi(appliesTo,'VIEW')||strcmpi(appliesTo,'CODEGEN'));
    assert(strcmpi(event,'PreAccess')||strcmpi(event,'Build'));

    cb=opts.callbackMgr.getCallback(event,appliesTo);
    [~,fcnName,~]=fileparts(cb.CallbackFileName);


    locExtractAndRunCallback(fullName,opts.modelName,event,appliesTo,fcnName);
end

function locExtractAndRunCallback(protectedModelFile,modelName,event,appliesTo,fcnName)

    import Simulink.ModelReference.ProtectedModel.*;
    import Simulink.ModelReference.common.*;


    origDir=pwd;
    tmpFolder=tempname;
    mkdir(tmpFolder);
    cd(tmpFolder);



    addpath(origDir);
    oc=onCleanup(@()locCleanup(tmpFolder,origDir));


    switch(appliesTo)
    case 'SIM'
        year=RelationshipSimCallback.getRelationshipYear();
        writeRelationship(protectedModelFile,tmpFolder,'simCallback',year);
    case 'VIEW'
        year=RelationshipViewCallback.getRelationshipYear();
        writeRelationship(protectedModelFile,tmpFolder,'viewCallback',year);
    case 'CODEGEN'
        year=RelationshipCodegenCallback.getRelationshipYear();
        writeRelationship(protectedModelFile,tmpFolder,'codegenCallback',year);
    end



    try

        locEval(fcnName);
    catch me
        error(message('Simulink:protectedModel:protectedModelCallbackErrorWrapper',...
        event,appliesTo,modelName,me.message));
    end
end

function locCleanup(tmpFolder,origDir)
    cd(origDir);
    if exist(tmpFolder,'dir')
        slprivate('removeDir',tmpFolder);
    end
    rmpath(origDir);
end

function locEval(fcnName)
    eval(fcnName);
end


