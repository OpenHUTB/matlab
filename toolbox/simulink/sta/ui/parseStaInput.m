function Results=parseStaInput(varargin)





























    p=inputParser;

    defaultDebug=false;

    defaultLaunchUsing='cef';

    addParameter(p,'DataSource',[],@isValidDataSource);
    addParameter(p,'ProcessedData',[],@isValidProcessedInput);
    addParameter(p,'Model',[],@isValidSimulinkModel);
    addParameter(p,'CloseCallback',[],@isCloseCallback)
    addParameter(p,'Debug',defaultDebug,@isValidDebugFlag);
    addParameter(p,'DebugPort',[],@isnumeric);
    addParameter(p,'LaunchDebugTools',false,@islogical);
    addParameter(p,'LaunchUsing',defaultLaunchUsing,@isValidLaunchUsingFormat);


    addParameter(p,'InputSpecification',[],@isValidInputSpecification);


    addParameter(p,'Scenario',[],@isValidScenarioFile);





    optionsDefault=struct();
    optionsDefault.askSaveOnClose=true;

    addParameter(p,'Options',optionsDefault,@isValidStaOption);

    parse(p,varargin{:});


    Results=p.Results;


    defaultFields=fieldnames(optionsDefault);


    for kField=1:length(defaultFields)

        if~isfield(Results.Options,defaultFields{kField})

            Results.Options.(defaultFields{kField})=optionsDefault.(defaultFields{kField});

        end

    end




    Results.DataSource=deblank(Results.DataSource);

    if iscell(Results.DataSource)&&length(Results.DataSource)==1

        Results.DataSource=Results.DataSource{1};

    end

    Results.Model=deblank(Results.Model);

end


function isValidDataSource(input)

    if isstring(input)&&isscalar(input)
        input=char(input);
    end

    if isstring(input)&&~isscalar(input)
        input=cellstr(input);
    end

    if iscell(input)
        fileName=input{1};
        isValidInputFile(fileName);
        for id=2:length(input)
            if~isvarname(input{id})
                error(message('sl_sta:sta:InvalidVariableName',input{id}));
            end
        end
    else
        fileName=input;
        isValidInputFile(fileName);
    end

end

function isValidInputFile(input)

    if isstring(input)&&isscalar(input)
        input=char(input);
    end

    if isstring(input)&&~isscalar(input)
        input=cellstr(input);
    end

    if iscell(input)
        error(message('sl_sta:sta:InvalidInputValue'));







    end
    isValidFile(input);



    [~,~,ext]=fileparts(deblank(input));
    if~any(strcmp(ext,{'.mat','.xls','.xlsx','.csv'}))


        error(message('sl_sta:sta:InvalidInputValue'));
    end

end


function isValidSimulinkModel(input)

    if~isempty(input)

        if isstring(input)&&isscalar(input)
            input=char(input);
        end



        if~ischar(input)
            error(message('sl_sta:sta:InvalidInputValue'));
        elseif exist(deblank(input),'file')~=4
            error(message('sl_sta:sta:InvalidInputValue'));
        end
    end
end

function isValidFile(input)

    if~isempty(input)

        if~ischar(input)
            error(message('sl_sta:sta:InvalidInputValue'));
        elseif~exist(deblank(input),'file')
            error(message('sl_sta:sta:FileDoesNotExist',input));
        end
    end
end

function isValidProcessedInput(input)

    if~isempty(input)


        if iscell(input)


            for k=1:length(input)


                if~isstruct(input{k})
                    error(message('sl_sta:sta:InvalidInputValue'));
                end
            end


            return;
        end

        if~isstruct(input)
            error(message('sl_sta:sta:InvalidInputValue'));
        elseif~all(strcmp(fieldnames(input),{'Data';'Names'}))
            error(message('sl_sta:sta:InvalidInputValue'));
        end
    end
end

function isValidDebugFlag(input)



    if~isempty(input)
        if~islogical(input)
            error(message('sl_sta:sta:InvalidInputValue'));
        end
    end
end

function isValidLaunchUsingFormat(input)

    if~isempty(input)
        if~ischar(input)
            error(message('sl_sta:sta:InvalidInputValue'));
        elseif~any(strcmpi(input,{'cef','ddg'}))
            error(message('sl_sta:sta:InvalidInputValue'));
        end
    end
end


function isCloseCallback(input)
    if~isempty(input)
        if~isa(input,'function_handle')

        end
    end
end


function isValidInputSpecification(input)


    if~isempty(input)


        if isnumeric(input)


            sta.InputSpecification(input);
        elseif~isa(input,'Simulink.iospecification.InputSpecification')

            error(message('sl_sta:sta:errorInputSpec'));
        end
    end

end


function isValidScenarioFile(input)


    isValidFile(input);


    [~,~,scenarioExt]=fileparts(input);

    fileExtSupported='.mldatx';


    if~strcmp(scenarioExt,fileExtSupported)
        error(message('sl_sta:sta:ScenarioWrongExtension',fileExtSupported));
    end

end




function isValidStaOption(input)


    if~isstruct(input)
        error(message('sl_sta:sta:pvpairOptionsNotValid'));
    end

    namesOfStruct=fieldnames(input);

    for kField=1:length(namesOfStruct)

        if~islogical(input.(namesOfStruct{kField}))
            error(message('sl_sta:sta:pvpairOptionsFieldNotValid',namesOfStruct{kField}));
        end

    end
end
