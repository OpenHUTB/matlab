function retValue=doesBusHaveAnonymousStructName(busObjectName,scope)

    if nargin==1
        scope=Simulink.data.BaseWorkspace;
    end


    if nargin>2
        DAStudio.error('Simulink:tools:slbusInvalidNumInputs');
    end
    assert(~isempty(busObjectName)&&ischar(busObjectName));

    if ischar(scope)
        scope=Simulink.data.BaseWorkspace;
    elseif isa(scope,'Simulink.dd.Connection')
        scope=Simulink.data.DataDictionary(scope.filespec);
    end

    sldd='';
    if scope.IsConnectedToDataDictionary
        [~,NAME,EXT]=fileparts(scope.DataSource.filespec);
        sldd=[NAME,EXT];
    end

    handleToBusObject=scope.get(busObjectName);
    assert(isa(handleToBusObject,'Simulink.Bus'));


    tmpModelName=matlab.lang.makeValidName(['tmpModelForAnonStruct_',strrep(mat2str(rand(1)),'0.','')]);
    tmpBusObjectName=matlab.lang.makeValidName(['tmpBusObject_',strrep(mat2str(rand(1)),'0.','')]);


    cleanUpVar=onCleanup(@()localCleanUp(tmpModelName));


    bd=Simulink.BlockDiagram(tmpModelName);


    bd.DataDictionary=sldd;

    dtt=Simulink.internal.DataTypeTable(tmpModelName);


    dtt.register(tmpBusObjectName,handleToBusObject);


    anonymousNameForBusType=dtt.generateAnonymousStructTypeName(tmpBusObjectName);
    retValue=(strcmp(anonymousNameForBusType,busObjectName)==1);



    function localCleanUp(tmpModelName)

        bdclose(tmpModelName);


