classdef(Sealed)StandardFunctionHandleGenerator







    properties(Constant,Hidden)
        PrefixVariableReplacement='x(:,';
        SuffixVariableReplacement=')';
        RegexpMatch='x\(:,\d+\)';
    end

    properties(SetAccess=private)
        FunctionHandle;
        NumberOfDimensions;
    end

    methods
        function this=StandardFunctionHandleGenerator(functionHandle)
            this.FunctionHandle=convert(this,functionHandle);
            this.NumberOfDimensions=getNumberOfDimensions(this,this.FunctionHandle);
        end

        function decodedString=extractFunctionName(this)





            functionString=func2str(this.FunctionHandle);
            decodedString=regexprep(functionString,{this.RegexpMatch,'\@\(x\)'},'');
            decodedString=regexprep(decodedString,['\(',',*','\)'],'');
        end
    end

    methods(Access=private)
        function functionHandle=convert(this,functionHandle)
            functionMetadata=functions(functionHandle);
            hasWorkspaceVariables=any(ismember(fieldnames(functionMetadata),'workspace'));
            if hasWorkspaceVariables
                variables=functionMetadata.workspace{1};
                this.assignVariables(variables);
            end
            functionHandle=FunctionApproximation.internal.ProblemDefinitionFactory.getFunctionHandleForSpecialFunction(functionHandle);
            fullFunctionString=func2str(functionHandle);
            variableNames=getVariableNames(this,fullFunctionString);
            if~isempty(variableNames)
                functionString=getFunctionString(this,fullFunctionString);
                convertedFunctionString=getConvertedFunctionString(this,variableNames,functionString);
                functionHandle=str2func(['@(x)',convertedFunctionString]);
            else
                nInputs=nargin(functionHandle);
                if nInputs>0
                    functionCallString='(';
                    for ii=1:nInputs
                        functionCallString=[functionCallString,'x',int2str(ii),','];%#ok<AGROW>
                    end
                    functionCallString(end)=')';
                    functionHandle=str2func(['@',functionCallString,fullFunctionString,functionCallString]);
                    functionHandle=convert(this,functionHandle);
                else
                    functionHandle=str2func(['@()',fullFunctionString]);
                end
            end
            vString=vectorize(functionHandle);
            eval(['functionHandle = ',vString,';']);
        end

        function assignVariables(~,variables)
            names=fieldnames(variables);
            for idx=1:numel(names)
                varName=names{idx};
                assignin('caller',varName,variables.(varName));
            end
        end

        function variableNames=getVariableNames(~,functionString)




            openBracesAt=strfind(functionString,'(');
            closeBracesAt=strfind(functionString,')');
            if~(isempty(openBracesAt)||isempty(closeBracesAt))
                variableNames=split(functionString(openBracesAt(1)+1:closeBracesAt(1)-1),',');
            else
                variableNames=string([]);
            end
        end

        function functionString=getFunctionString(~,fullFunctionString)




            closeBraces=strfind(fullFunctionString,')');
            functionString=fullFunctionString((closeBraces(1)+1):end);
        end

        function functionString=getConvertedFunctionString(this,variableNames,functionString)






            functionString=['-',functionString,'-'];
            for ii=1:numel(variableNames)
                name=char(variableNames(ii));
                jj=2;
                len=numel(functionString);
                while jj<len
                    localString=functionString(jj-1:min(jj+numel(name),len));

                    location=regexp(localString,['[~.^(,*+ -/\[]',name,'[\].^),*+-/]']);
                    location=(jj-1)+(location-1);
                    if~isempty(location)
                        variableReplacement=encoder(this,ii);
                        functionString=[functionString(1:location),variableReplacement,functionString((location+length(name)+1):end)];
                        len=numel(functionString);
                    end
                    jj=jj+1;
                end
            end
            functionString(1)='';
            functionString(end)='';
        end

        function nDims=getNumberOfDimensions(this,functionHandle)

            nDims=nargin(functionHandle);
            functionString=func2str(functionHandle);
            dimensionPlaceHolders=regexp(functionString,this.RegexpMatch,'match');
            dimesionsAfterExcludingRepetitions=numel(unique(dimensionPlaceHolders));
            nDims=max(nDims,dimesionsAfterExcludingRepetitions);
        end

        function encodedVariableName=encoder(this,indexValue)
            encodedVariableName=[this.PrefixVariableReplacement,num2str(indexValue,'%g'),this.SuffixVariableReplacement];
        end
    end
end
