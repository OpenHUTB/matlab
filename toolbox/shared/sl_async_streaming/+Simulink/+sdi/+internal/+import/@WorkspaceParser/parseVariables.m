function ret=parseVariables(this,vars)


    ret={};
    validateattributes(vars,{'struct'},{});


    createPendingParsers(this);


    numVars=numel(vars);
    for varIdx=1:numVars
        try


            if isnumeric(vars(varIdx).VarValue)||...
                islogical(vars(varIdx).VarValue)||...
                isstruct(vars(varIdx).VarValue)||...
                isscalar(vars(varIdx).VarValue)||...
                istimetable(vars(varIdx).VarValue)||...
                isa(vars(varIdx).VarValue,'labeledSignalSet')||...
                strcmp(class(vars(varIdx).VarValue),'Simulink.Timeseries')%#ok<STISA>
                ret=locParseScalarObject(this,vars(varIdx),ret);
            else
                numObj=numel(vars(varIdx).VarValue);
                for objIdx=1:numObj
                    if iscell(vars(varIdx).VarValue)&&isa(vars(varIdx).VarValue{objIdx},'timetable')


                        tmpVar.VarName=sprintf('%s{%d}',vars(varIdx).VarName,objIdx);
                        tmpVar.VarValue=vars(varIdx).VarValue{objIdx};
                    else
                        tmpVar.VarName=sprintf('%s(%d)',vars(varIdx).VarName,objIdx);
                        tmpVar.VarValue=vars(varIdx).VarValue(objIdx);
                    end
                    if isfield(vars,'VarBlockPath')
                        tmpVar.VarBlockPath=vars(varIdx).VarBlockPath;
                    end
                    if isfield(vars,'VarSignalName')
                        tmpVar.VarSignalName=vars(varIdx).VarSignalName;
                    end
                    ret=locParseScalarObject(this,tmpVar,ret);
                end
            end
        catch me %#ok<NASGU>

        end
    end
end


function ret=locParseScalarObject(this,var,ret)





    if strcmp(var.VarName,'tout')&&~(isfield(var,'TimeSourceRule')&&strcmp(var.TimeSourceRule,'siganalyzer'))
        return
    end


    numParsers=getCount(this.CustomParsers);
    for parserIdx=1:numParsers
        parser=getDataByIndex(this.CustomParsers,parserIdx);
        try
            if supportsVariable(parser,var.VarValue)
                varParser=Simulink.sdi.internal.import.CustomWorkspaceVariableParser;
                varParser.CustomImporter=eval(class(parser));
                varParser.CustomImporter.VariableName=var.VarName;
                varParser.CustomImporter.VariableValue=var.VarValue;
                varParser.VariableName=var.VarName;
                varParser.VariableValue=var.VarValue;
                varParser.WorkspaceParser=this;
                if locIncludeParser(varParser)
                    ret{end+1}=varParser;%#ok<AGROW>
                end
                return
            end
        catch me %#ok<NASGU>
        end
    end


    numParsers=getCount(this.CreatedParsers);
    for parserIdx=1:numParsers
        parser=getDataByIndex(this.CreatedParsers,parserIdx);
        if isfield(var,'TimeSourceRule')
            parser.TimeSourceRule=var.TimeSourceRule;
        else
            parser.TimeSourceRule='';
        end
        try
            if supportsType(parser,var.VarValue)
                varParser=eval(class(parser));
                varParser.VariableName=var.VarName;
                varParser.VariableValue=var.VarValue;
                varParser.TimeSourceRule=parser.TimeSourceRule;
                varParser.WorkspaceParser=this;
                if isfield(var,'VarBlockPath')
                    varParser.VariableBlockPath=var.VarBlockPath;
                end
                if isfield(var,'VarSignalName')
                    varParser.VariableSignalName=var.VarSignalName;
                end
                if isfield(var,'Metadata')
                    varParser.Metadata=var.Metadata;
                else
                    varParser.Metadata=[];
                end
                if locIncludeParser(varParser)
                    ret{end+1}=varParser;%#ok<AGROW>
                end
                return
            end
        catch me %#ok<NASGU>
        end
    end
end


function ret=locIncludeParser(varParser)


    ret=true;
    if~isHierarchical(varParser)
        MAX_CHANNELS=30000;
        totalChannels=prod(getSampleDims(varParser));
        ret=(totalChannels<=MAX_CHANNELS);
        if~ret
            me=message('SDI:sdi:ImportChannelLimit',varParser.getSignalLabel(),MAX_CHANNELS);
            Simulink.sdi.internal.warning(me);
        end
    end
end

