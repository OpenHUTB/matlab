function[jsonStruct,arrayOfProps,errMsg]=insertSignal(insertParametersStruct)





    jsonStruct={};
    arrayOfProps=[];
    errMsg='';


    signalTypeToInsert=insertParametersStruct.signalType;
    scenarioID=insertParametersStruct.scenarioid;
    allParentIDs=insertParametersStruct.parentIDToAssign;
    currentTreeOrderMax=insertParametersStruct.currentTreeOrderMax;
    fileName=insertParametersStruct.filename;
    parentFullName=insertParametersStruct.parentFullName;

    if ischar(parentFullName)
        parentFullName={parentFullName};
    end

    if isempty(fileName)
        fileName='';
    end

    modelName=insertParametersStruct.model;




    if isempty(allParentIDs)
        allParentIDs=0;
    end


    aSigToInsert=[];
    aSigName='Signal';
    IS_VIRTUAL_BUS=false;

    switch signalTypeToInsert

    case 'scenario'

        aSigToInsert=Simulink.SimulationData.Dataset();

        aSigName='Scenario';

    case 'ground'

        aSigToInsert=[];

        aSigName='Ground';

    case 'functioncall'

        aSigToInsert=0;

        aSigName='FunctionCall';

    case 'signal'

        if isfield(insertParametersStruct,'name')
            aSigName=insertParametersStruct.name;
        else
            aSigName='Signal';
        end

        dataType=insertParametersStruct.signalProperties.dataType;
        if isempty(dataType)
            errMsg=DAStudio.message('sl_sta:editor:insertDataTypeEmpty');
            return;
        end

        outEnumDataType=slwebwidgets.AuthorUtility.parseDataTypeStringForEnumeration(dataType);

        IS_ENUM=~isempty(enumeration(outEnumDataType))||insertParametersStruct.signalProperties.IS_ENUM;


        theDims=str2num(insertParametersStruct.signalProperties.dimensions);%#ok<ST2NM> 

        if isfield(insertParametersStruct.signalProperties,'y')
            dataIn=cell2mat(slwebwidgets.getMATLABValueFromConnectorData(insertParametersStruct.signalProperties.y));
        else
            dataIn=[0;0];
        end

        if isfield(insertParametersStruct.signalProperties,'x')
            timeIn=cell2mat(slwebwidgets.getMATLABValueFromConnectorData(insertParametersStruct.signalProperties.x));
        else
            timeIn=[0;10];
        end


        if IS_ENUM

            enumType=strtrim(outEnumDataType);
            if isempty(enumType)
                errMsg=DAStudio.message('sl_sta:editor:enumClassEmpty');
                return;
            end

            DOES_ENUM_EXIST=exist(enumType,'file')==2;
            [~,enumFileNameOnly,~]=fileparts(enumType);

            [IS_VALID,ISA_META_STRUCT]=slwebwidgets.AuthorUtility.isSignalDataTypeStringValid(enumFileNameOnly);
            FOUND_ENUM=IS_VALID&&ISA_META_STRUCT.IS_ENUM;

            insertParametersStruct.signalProperties.dataType=enumFileNameOnly;
            if~DOES_ENUM_EXIST&&~FOUND_ENUM
                errMsg=DAStudio.message('sl_sta:editor:enumNotFound',insertParametersStruct.signalProperties.dataType);
                return;
            end

            if~isfield(insertParametersStruct.signalProperties,'y')
                [dataVals,errMsg]=generateEnumerationData(insertParametersStruct.signalProperties.dataType,theDims);
            else
                errMsg='';
                try
                    dataVals=feval(insertParametersStruct.signalProperties.dataType,dataIn);
                catch ME_ENUM

                    errMsg=ME_ENUM.message;
                end
            end

            if~isempty(errMsg)
                return;
            end
        else

            try
                if strcmp(insertParametersStruct.signalProperties.dataType,'string')

                    dataVals=generateStringData(theDims);

                elseif slwebwidgets.AuthorUtility.isDataTypeNumericType(insertParametersStruct.signalProperties.dataType)

                    if~license('test','Fixed_Point_Toolbox')
                        errMsg=DAStudio.message('fixed:fi:licenseCheckoutFailed');
                        return;
                    end

                    try
                        dataVals=generateFixedPointData(insertParametersStruct.signalProperties.dataType,...
                        theDims,insertParametersStruct.signalProperties.complexity,dataIn);
                    catch ME_FI

                        errMsg=ME_FI.message;
                        return;
                    end
                else
                    if(strcmp(insertParametersStruct.signalProperties.dataType,'logical')...
                        ||strcmp(insertParametersStruct.signalProperties.dataType,'boolean'))&&...
                        ~strcmp(insertParametersStruct.signalProperties.complexity,'real')
                        errMsg=DAStudio.message('sl_sta:editor:realPartInputNonNumericOrNonReal');
                        return;
                    end

                    dataVals=generateBuiltInData(insertParametersStruct.signalProperties.dataType,...
                    theDims,insertParametersStruct.signalProperties.complexity,dataIn);
                end
            catch ME
                errMsg=ME.message;

            end
        end

        units=insertParametersStruct.signalProperties.units;
        interp=insertParametersStruct.signalProperties.interpolation;

        if strcmp(insertParametersStruct.signalProperties.dataType,'string')
            interp='zoh';
        end

        aSigToInsert=SignalEditorUtil.createSignalVariable(...
        insertParametersStruct.signalProperties.objecttype,...
        timeIn,dataVals,units,interp);
    case 'bus'
        aSigName='Bus';

        busObject=insertParametersStruct.signalProperties.busObject;

        if~isempty(busObject)&&~strcmp(busObject,'-')


            try
                aSigToInsert=createBusFromBusObj(modelName,busObject);
            catch ME

                switch ME.identifier

                case 'Simulink:Parameters:InvParamSetting'
                    [~,errMsg]=resolveBusCreateError(ME);
                    return

                end

                errMsg=DAStudio.message('sl_sta:editor:busObjectNotFound',busObject);
                return;
            end


            theDims=str2num(insertParametersStruct.signalProperties.dimensions);%#ok<ST2NM> 

            if(length(theDims)==1)
                aSigToInsert=repmat(aSigToInsert,[theDims,1]);
            else
                aSigToInsert=repmat(aSigToInsert,theDims);
            end

        else
            IS_VIRTUAL_BUS=true;
            aSigToInsert=struct;
        end

    end

    for kParents=1:length(allParentIDs)
        parentIDToAssign=allParentIDs(kParents);
        if parentIDToAssign==0


            if~isvarname(aSigName)


                aSigName=matlab.lang.makeValidName(aSigName);

            end

            aSigName=Simulink.sta.editor.uniqueSignalNameUnderInput(scenarioID,aSigName);

        else
            if~strcmp(signalTypeToInsert,'scenario')

                if~isvarname(aSigName)


                    aSigName=matlab.lang.makeValidName(aSigName);

                end

                aSigName=Simulink.sta.editor.uniqueSignalNameUnderSignal(parentIDToAssign,aSigName);

            end
        end

        if IS_VIRTUAL_BUS
            itemFactory=starepository.factory.MATLABStructBusItem(aSigName,aSigToInsert);
            item=itemFactory.createSignalItemWithoutChildren();
        else

            itemFactory=starepository.factory.createSignalItemFactory(aSigName,aSigToInsert);

            item=itemFactory.createSignalItem;
        end

        if iscell(parentFullName)
            insertParentName=parentFullName{kParents};
        elseif isempty(parentFullName)
            insertParentName='';
        else
            insertParentName=parentFullName(kParents);
        end
        [tmpJsonStruct,tmpArrayOfProps]=Simulink.sta.editor.createSignalInRepositoryUnderParent(...
        item,fileName,currentTreeOrderMax,scenarioID,parentIDToAssign,insertParentName);

        currentTreeOrderMax=currentTreeOrderMax+length(tmpJsonStruct);
        if isempty(jsonStruct)
            jsonStruct=tmpJsonStruct;
        else
            newJson={jsonStruct{1,:},tmpJsonStruct{1,:}};
            jsonStruct=newJson;
        end

        if isempty(arrayOfProps)
            arrayOfProps=tmpArrayOfProps;
        else
            newArrayOfProps=[arrayOfProps,tmpArrayOfProps];
            arrayOfProps=newArrayOfProps;
        end

    end

    if~isempty(arrayOfProps)

        uniqueIDs=unique([arrayOfProps.id]);

        if length(arrayOfProps)==length(uniqueIDs)

            return;
        end
        lastUpdateID=zeros(1,length(uniqueIDs));
        for kID=1:length(uniqueIDs)

            lastUpdateID(kID)=find([arrayOfProps.id]==uniqueIDs(kID)&strcmp({arrayOfProps(:).propertyname},'TreeOrder'),1,'last');
        end

        arrayOfProps=[arrayOfProps(lastUpdateID),arrayOfProps(~strcmp({arrayOfProps(:).propertyname},'TreeOrder'))];
    end
end


function[dataVals,errMsg]=generateEnumerationData(dataTypeStr,theDims)

    errMsg='';

    try
        ENUM_DEFAULT=eval([dataTypeStr...
        ,'.getDefaultValue']);

        if~strcmp(class(ENUM_DEFAULT),dataTypeStr)
            dataVals=[];
            errMsg=DAStudio.message('sl_sta:editor:defaultEnumNotOfClass',dataTypeStr);
            return;
        end

    catch ME_NODEFAULT %#ok<NASGU> 

        try


            [enumMembers,~]=enumeration(dataTypeStr);
            ENUM_DEFAULT=enumMembers(1);
        catch ME_NO_DEF
            dataVals=[];
            errMsg=ME_NO_DEF.message;
            return;
        end


    end

    if all(theDims==1)
        dataVals=[ENUM_DEFAULT;ENUM_DEFAULT];
    else

        if length(theDims)==1

            dataVals=repmat(ENUM_DEFAULT,[2,theDims]);

        else

            dataVals=repmat(ENUM_DEFAULT,[theDims,2]);

        end

    end
end


function dataVals=generateBuiltInData(dataTypeStr,theDims,complexityStr,varargin)

    if isempty(varargin)
        scalarData=[0;0];
    else

        scalarData=varargin{1};
    end

    dataTypeFcn=str2func(dataTypeStr);


    if all(theDims==1)
        dataVals=dataTypeFcn(scalarData);
    else

        if length(theDims)==1

            dataVals=zeros([2,theDims]);

        else

            dataVals=zeros([theDims,2]);

        end

        dataVals=dataTypeFcn(dataVals);
    end


    if~strcmp(complexityStr,'real')
        dataVals=complex(dataVals,dataVals);
    end
end


function dataVals=generateStringData(theDims)

    if all(theDims==1)
        dataVals=["";""];
    else

        if length(theDims)==1
            dataVals=repmat("",[2,theDims]);
        else
            dataVals=repmat("",[theDims,2]);
        end
    end

end


function dataVals=generateFixedPointData(...
    dataType,theDims,complexityStr,varargin)

    fiObject=eval(dataType);

    if isempty(varargin)
        scalarData=[0;0];
    else

        scalarData=varargin{1};
    end


    if all(theDims==1)
        dataVals=fi(scalarData,fiObject);
    else

        if length(theDims)==1

            dataVals=fi(zeros([2,theDims]),fiObject);

        else

            dataVals=fi(zeros([theDims,2]),fiObject);

        end
    end


    if~strcmp(complexityStr,'real')
        dataVals=complex(dataVals,dataVals);
    end

end


function[errID,errMsg]=resolveBusCreateError(ME)

    if~isempty(ME.cause)
        [errID,errMsg]=resolveBusCreateError(ME.cause{1});
    else
        errID=ME.identifier;
        errMsg=ME.message;
    end
end


function xBus=createBusFromBusObj(mdl,BusObjectName)

    modelToGenerate=Simulink.sta.editor.generateTempModel(mdl);

    inport_name_full=[modelToGenerate,'/In1'];
    add_block('built-in/Inport',inport_name_full);


    set_param(inport_name_full,'useBusObject','on');
    set_param(inport_name_full,'OutDataTypeStr',['Bus: ',BusObjectName]);
    set_param(inport_name_full,'BusOutputAsStruct','on');



    outport_name=sprintf('%s/Out1',modelToGenerate);
    add_block('built-in/Outport',outport_name);


    set_param(outport_name,'useBusObject','on');
    set_param(outport_name,'BusObject',BusObjectName);

    start_point='In1/1';
    end_point='Out1/1';
    lineH=add_line(modelToGenerate,start_point,end_point);%#ok<NASGU> 


    try
        mdlH=get_param(mdl,'Handle');
        overrideStruct.startTime='0';
        overrideStruct.stopTime='10';
        overrideStruct.FixedStep='10';
        Simulink.sta.editor.setModelLoggingParameters(mdlH,modelToGenerate,overrideStruct);
    catch ME %#ok<NASGU> 


    end

    doneCompiling=false;



    while~doneCompiling
        try

            simOut=sim(modelToGenerate,'OutputSaveName','out');
            doneCompiling=true;


            bdclose(modelToGenerate);
        catch ME_SIMULATE %#ok<NASGU> 
            errMsg=DAStudio.message('sl_sta:editor:errorGeneratingSimInput');%#ok<NASGU> 

            bdclose(modelToGenerate);
            clearVarsPlacedInWS(vars_in_ws_to_clear);
            return;
        end
    end


    r=Simulink.sdi.getCurrentSimulationRun(modelToGenerate,'',false);
    if~isempty(r)
        Simulink.sdi.deleteRun(r.id);
    end


    xBus=simOut.get('out').get(1).Values;

    xBus=Simulink.sta.editor.setInterpolationByDataType(xBus);

end


function clearVarsPlacedInWS(vars_in_ws_to_clear)

    for k=1:length(vars_in_ws_to_clear)

        evalin('base',['clear ',vars_in_ws_to_clear{k}]);

    end
end
