function inputStruct=parseEditorInputs(varargin)


    p=inputParser;

    addParameter(p,'Debug',false,@isValidDebugFlag);
    addParameter(p,'DebugPort',[],@isnumeric);
    addParameter(p,'DataSource',[],@isValidDataSource);
    addParameter(p,'Signals',[],@iscell);
    addParameter(p,'ViewInput',[],@isstruct);
    addParameter(p,'RIMSigStruct',[],@iscell);
    addParameter(p,'UpstreamAppID',[],@isValidUpstreamAppID);
    addParameter(p,'Model',[],@isValidSimulinkModel);
    addParameter(p,'EditMode',true,@islogical);
    addParameter(p,'Tag',[],@ischar);
    addParameter(p,'StandAlone',[],@islogical);
    addParameter(p,'LaunchDebugTools',false,@islogical);
    addParameter(p,'ForceDirty',false,@islogical);
    addParameter(p,'SignalEditorBlock',false,@islogical);
    parse(p,varargin{:});
    inputStruct=p.Results;

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
        if isa(fileName,'iofile.File')





            [~,~,ext]=fileparts(deblank(fileName.FileName));


            if~strcmpi(ext,'.mat')
                error(message('sl_sta:sta:InvalidInputValue'));
            end

            return;
        else
            isValidInputFile(fileName);
            for id=2:length(input)
                if~isvarname(input{id})
                    error(message('sl_sta:sta:InvalidVariableName',input{id}));
                end
            end
        end
    else
        fileName=input;
        isValidInputFile(fileName);
    end

end


function isValidInputFile(input)

    if iscell(input)
        error(message('sl_sta:sta:InvalidInputValue'));







    end
    isValidFile(input);



    [~,~,ext]=fileparts(deblank(input));
    if~any(strcmp(ext,{'.mat'}))


        error(message('sl_sta:sta:InvalidInputValue'));
    end

end


function isValidFile(input)

    if~isempty(input)

        if isstring(input)&&isscalar(input)
            input=char(input);
        end

        if~ischar(input)
            error(message('sl_sta:sta:InvalidInputValue'));
        elseif~exist(deblank(input),'file')
            error(message('sl_sta:sta:FileDoesNotExist',input));
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


function isValidSimulinkModel(input)

    if~isempty(input)

        if isstring(input)&&isscalar(input)
            input=char(input);
        end

        if~ischar(input)
            error(message('sl_sta:sta:InvalidInputValue'));
        end

        if~bdIsLoaded(input)
            error(message('sl_sta:sta:InvalidInputValue'));
        end
    end
end


function isValidUpstreamAppID(input)

    if~ischar(input)&&~isempty(input)
        error(message('sl_sta:sta:InvalidInputValue'));
    end

end
