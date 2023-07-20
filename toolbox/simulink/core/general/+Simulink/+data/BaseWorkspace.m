




classdef BaseWorkspace<handle
    properties(Constant)
        DataSource='base'
        IsConnectedToDataDictionary=false;
    end

    methods(Access=public)
        function varargout=evalin(this,command)
            [varargout{1:nargout}]=evalin(this.DataSource,command);
        end

        function assignin(this,varName,value)
            assignin(this.DataSource,varName,value);
        end

        function save(this,dataFile,variableNames)
            variableNames=variableNames(cellfun(@(item)~isempty(item),variableNames));
            if~isempty(variableNames)
                evalin(this.DataSource,this.getSaveCommand(dataFile,variableNames));
            end
        end

        function status=exist(this,varName)
            status=evalin(this.DataSource,sprintf('builtin(''exist'',''%s'', ''var'') > 0;',varName));
        end

        function results=whos(this,classType)
            results={};
            allVariables=evalin(this.DataSource,'builtin(''whos'')');
            if~isempty(allVariables)
                baseClassInfo=meta.class.fromName(classType);
                assert(~isempty(baseClassInfo),'Unsupported class type: %s\n',classType);
                N=length(allVariables);
                for idx=1:N
                    val=allVariables(idx);
                    classInfo=meta.class.fromName(val.class);
                    if~isempty(classInfo)&&(classInfo<=baseClassInfo)
                        results{end+1}=val.name;%#ok
                    end
                end
                results=results';
            end
        end

        function val=get(this,varName)
            val=evalin(this.DataSource,varName);
        end
    end

    methods(Static,Access=public)
        function strbuf=getSaveCommand(dataFile,variableNames)
            [~,~,fileExt]=fileparts(dataFile);
            if strcmpi(fileExt,'.m')
                strbuf=['matlab.io.saveVariablesToScript','(''',dataFile,''', ',...
                Simulink.ModelReference.Conversion.Utilities.cellstr2str(variableNames,'{','}'),');'];
            else
                strbuf=['save(','''',dataFile,''', ',...
                Simulink.ModelReference.Conversion.Utilities.cellstr2str(variableNames,'',''),');'];
            end
        end
    end
end
