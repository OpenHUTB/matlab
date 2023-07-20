














































function register(name,busObj,varargin)

    parser=inputParser;

    addRequired(parser,'busName');
    addRequired(parser,'busObject');
    addOptional(parser,'forceRegister',false);
    addParameter(parser,'blockHandle',[]);
    addParameter(parser,'docLink',[]);
    addParameter(parser,'alterDims',true);
    parse(parser,name,busObj,varargin{:});

    name=parser.Results.busName;
    busObj=parser.Results.busObject;
    forceRegister=parser.Results.forceRegister;
    blockHandle=parser.Results.blockHandle;
    docLink=parser.Results.docLink;
    alterDims=parser.Results.alterDims;


    invalidInputs=false;
    if~ischar(name)||~isa(busObj,'Simulink.Bus')||...
        ~islogical(forceRegister)||~islogical(alterDims)
        invalidInputs=true;
    end

    if~isempty(blockHandle)&&~isempty(docLink)
        invalidInputs=true;
    end

    if~isempty(blockHandle)&&~ishandle(blockHandle)
        invalidInputs=true;
    end
    if~isempty(docLink)&&~startsWith(docLink,'doc ')
        invalidInputs=true;
    end

    if invalidInputs
        errid='Simulink:Bus:BusRegisterInvalidInputArgs';
        me=MException(errid,DAStudio.message(errid));
        throwAsCaller(me);
    end


    if~isempty(blockHandle)
        origin=blockHandle;
    else
        origin=docLink;
    end


    busDict=Simulink.BusDictionary.getInstance();
    alreadyDefined=busDict.registeredBusTypeDefined(name)||...
    busDict.classBasedBusTypeDefined(name);


    if~alreadyDefined||forceRegister
        if(alreadyDefined)
            busDict.deleteRegisteredBusType(name);
            busDict.deleteRegisteredBusOrigin(name);
            busDict.deleteClassBasedBusType(name);
        end


        if alterDims
            for idx=1:length(busObj.Elements)
                if isequal(busObj.Elements(idx).Dimensions,1)
                    busObj.Elements(idx).Dimensions=[1,1];
                end
            end
        end

        busDict.addRegisteredBusType(name,busObj);
        if~isempty(origin)
            busDict.addRegisteredBusOrigin(name,origin);
        end
    else
        existingBus=busDict.getClassBasedBusType(name);
        if isempty(existingBus)
            existingBus=busDict.getRegisteredBusType(name);
        end

        reportCannotOverwriteError=false;

        if~isequal(existingBus,busObj)
            reportCannotOverwriteError=true;
        else


            if isequal(busDict.getRegisteredBusOrigin(name),origin)
                return;
            else
                reportCannotOverwriteError=true;
            end
        end
        if reportCannotOverwriteError
            errid='Simulink:Bus:BusRegisterCannotOverwrite';
            me=MException(errid,DAStudio.message(errid,name));
            throwAsCaller(me);
        end
    end
end

