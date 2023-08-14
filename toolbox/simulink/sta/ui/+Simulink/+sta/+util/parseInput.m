function Results=parseInput(varargin)














    p=inputParser;

    defaultMappingMode={'BlockName',''};
    defaultSaveScenario={false,''};

    addParameter(p,'Model',[],@isValidSimulinkModel);
    addParameter(p,'DataSource',[],@isValidDataSource);
    addParameter(p,'MappingMode',defaultMappingMode,@isValidMapping);
    addParameter(p,'SaveScenario',defaultSaveScenario,@isValidSaveScenario);
    addParameter(p,'CompileIfNeeded',false,@islogical);
    addParameter(p,'AllowPartialBusSpecification',false,@islogical);

    parse(p,varargin{:});

    Results=p.Results;



    Results.DataSource=deblank(Results.DataSource);
    Results.Model=deblank(Results.Model);
    Results.MappingMode=deblank(Results.MappingMode);

    if~isempty(Results.SaveScenario)
        if length(Results.SaveScenario)>1
            Results.SaveScenario{2}=deblank(Results.SaveScenario{2});
        end
    end

end


function isValidDataSource(input)

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


    isValidFile(input);



    [~,~,ext]=fileparts(deblank(input));
    if~any(strcmp(ext,{'.mat','.xls','.xlsx','.csv'}))


        error(message('sl_sta:sta:singleClickDataSourceNotValidFileType'));
    end

end


function isValidSimulinkModel(input)

    if~isempty(input)

        if~ischar(input)
            error(message('sl_sta:sta:singleClickModelFileNotChar'));
        elseif exist(deblank(input),'file')~=4
            error(message('sl_sta:sta:singleClickModelFileNotChar'));
        end
    end
end


function isValidFile(input)

    if~isempty(input)

        if~ischar(input)
            error(message('sl_sta:sta:singleClickFileNotChar'));
        elseif~exist(deblank(input),'file')
            error(message('sl_sta:sta:FileDoesNotExist',input));
        end
    end
end


function isValidMapping(input)

    if iscell(input)
        mode=input{1};
        isValidMappingMode(mode);
        if(length(input)==2)
            file=input{2};
            if~isempty(file)
                isValidFile(file);
            end
        end
    else

        error(message('sl_sta:sta:singleClickMapModeNotCell'));
    end

end


function isValidMappingMode(input)

    validModes={'BlockName','PortOrder','SignalName','BlockPath','Custom'};
    if all(~strcmpi(input,validModes))
        error(message('sl_sta:sta:singleClickMapModeNotValid'));
    end

end


