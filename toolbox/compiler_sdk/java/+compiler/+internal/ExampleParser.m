classdef ExampleParser



    properties(Access=private)
        fileContents;
        functionPaths;
        functionNames;
        originalPath;
        figureManager;
        listener;
        filename;
        conflictingNames;
        newNames;
    end

    methods(Static)
        function[functionCalls]=getFunctionCalls(filename,functionNameMap,componentName)
            fullFunctionNames=cell(functionNameMap.keySet().toArray());

            exampleParser=compiler.internal.ExampleParser(filename,fullFunctionNames);

            functionCalls=exampleParser.makeFunctionCalls(functionNameMap,componentName);
        end

        function[validationErrors]=getArgumentValidation(filename,functionNameMap)
            fullFunctionNames=cell(functionNameMap.keySet().toArray());

            exampleParser=compiler.internal.ExampleParser(filename,fullFunctionNames);

            [functionVariables,validationErrors]=exampleParser.getVariables();

            if isempty(validationErrors)
                validationErrors=exampleParser.validateArgumentTypes(functionVariables);
            end
        end
    end

    methods

        function[this]=ExampleParser(filename,fullFunctionNames)
            this.fileContents=fileread(filename);
            [this.functionPaths,this.functionNames,~]=cellfun(@(x)fileparts(x),fullFunctionNames,'UniformOutput',false);
        end








        function[functionCalls]=makeFunctionCalls(this,functionNameMap,componentName)
            import org.apache.commons.lang.*
            import java.util.Arrays
            import com.mathworks.toolbox.compiler_examples.strategy_api.inputvariables.*
            import com.mathworks.toolbox.compiler_examples.strategy_api.outputvariables.*
            import com.mathworks.toolbox.compiler_examples.strategy_api.NumericType
            import com.mathworks.toolbox.compiler_examples.strategy_api.codecomponents.*



            [names,inputs,outputs]=this.getDataFromFile();
            variables=this.getVariables();

            functionCalls=java.util.ArrayList;




            for callInd=1:numel(names)

                functionName=names{callInd};

                className=this.getClassName(functionName,functionNameMap);



                inputIndices=zeros(numel(inputs{callInd}),1);
                for inInd=1:numel(inputs{callInd})
                    inputIndices(inInd,1)=find(cellfun(@(x)strcmp(x,inputs{callInd}(inInd).Name),{variables.Name}));
                end


                inputVariables=this.appendPostfix(variables(inputIndices),'In');
                inputsAsVariableDeclarations=java.util.ArrayList;

                for inInd=1:numel(inputIndices)
                    inputsAsVariableDeclarations.add(this.getInVarDec(inputVariables(inInd).Name,...
                    inputVariables(inInd).Type,...
                    inputVariables(inInd).Dimensions,...
                    inputVariables(inInd).Data));
                end



                outputIndices=zeros(numel(outputs{callInd}),1);
                for outInd=1:numel(outputs{callInd})
                    outputIndices(outInd,1)=find(cellfun(@(x)strcmp(x,outputs{callInd}(outInd).Name),{variables.Name}));
                end


                outputVariables=this.appendPostfix(variables(outputIndices),'Out');
                outputsAsVariableDeclarations=java.util.ArrayList;
                for outInd=1:numel(outputIndices)
                    outputsAsVariableDeclarations.add(this.getOutVarDec(outputVariables(outInd).Name,...
                    outputVariables(outInd).Type,...
                    outputVariables(outInd).Dimensions));
                end

                functionCalls.add(FunctionCall(functionName,className,componentName,inputsAsVariableDeclarations,outputsAsVariableDeclarations));
            end
        end


        function variables=appendPostfix(~,variables,postfix)








            for idx=1:numel(variables)
                variables(idx).Name=strcat(variables(idx).Name,postfix);
            end
        end














        function[names,inputs,outputs]=getDataFromFile(this)
            funcTree=mtree(this.fileContents);
            functionNodes=mtfind(funcTree,'Fun',cell(this.functionNames));
            callIndices=indices(functionNodes);

            names=cell(numel(callIndices),1);
            inputs=cell(numel(callIndices),1);
            outputs=cell(numel(callIndices),1);

            for i=1:numel(callIndices)
                callNode=select(funcTree,callIndices(i));
                names{i,1}=string(callNode);

                inputArgs=List(Right(Parent(callNode)));
                if~allkind(inputArgs,'ID')
                    error(message('CompilerSDK:ExampleParser:inputsNotId'));
                end
                inputs{i,1}=struct('Name',strings(inputArgs).');



                parentNode=Parent(Parent(callNode));
                if(iskind(parentNode,'EQUALS'))
                    outputArgs=Left(parentNode);
                    if(iskind(outputArgs,'LB'))
                        outputArgs=List(Arg(outputArgs));
                    end
                    if~allkind(outputArgs,'ID')
                        error(message('CompilerSDK:ExampleParser:outputsNotId'));
                    end
                    outputs{i,1}=struct('Name',strings(outputArgs).');
                else
                    outputs{i,1}=struct('Name',{});
                end
                if~isempty(intersect({inputs{i,1}.Name},{outputs{i,1}.Name}))||...
                    numel({inputs{i,1}.Name})~=numel(unique({inputs{i,1}.Name}))||...
                    numel({outputs{i,1}.Name})~=numel(unique({outputs{i,1}.Name}))
                    error(message('CompilerSDK:ExampleParser:sameNameInInputsAndOutputs'));
                end
            end
        end







        function[className]=getClassName(~,functionName,functionNameMap)
            import org.apache.commons.io.*

            methodNames=functionNameMap.keySet();
            iter=methodNames.iterator();
            fullMethodName=java.lang.String;



            while(iter.hasNext())
                curr=java.lang.String(iter.next);
                if(strcmp(FilenameUtils.getBaseName(curr),(functionName)))
                    fullMethodName=curr;
                    break
                end
            end

            className=functionNameMap.get(fullMethodName);
        end













        function[inVarDec]=getInVarDec(this,name,type,dims,data)
            import com.mathworks.toolbox.compiler_examples.strategy_api.NumericType
            import com.mathworks.toolbox.compiler_examples.strategy_api.NumericComplexity
            import com.mathworks.toolbox.compiler_examples.strategy_api.inputvariables.MatlabNumber
            import com.mathworks.toolbox.compiler_examples.strategy_api.inputvariables.*
            import com.mathworks.toolbox.compiler_examples.strategy_api.inputvariables.StructInputVariableDeclaration.*
            import java.lang.Math

            inName=java.lang.String(name);


            inDims=java.util.ArrayList;

            for dimInd=1:numel(dims)
                inDims.add(java.lang.Integer(Math.round(dims(dimInd))));
            end

            inData=java.util.ArrayList;
            inVarDec=[];


            switch type
            case 'char'
                for dataInd=1:numel(data)
                    inData.add(java.lang.Character(data(dataInd)));
                end
                inVarDec=CharInputVariableDeclaration(inName,inDims,inData);

            case 'logical'
                for dataInd=1:numel(data)
                    inData.add(java.lang.Boolean(data(dataInd)));
                end
                inVarDec=LogicalInputVariableDeclaration(inName,inDims,inData);
            case{'double','single','int8','int16','int32','int64','uint8','uint16','uint32','uint64'}
                numericType=NumericType.getNumericType(java.lang.String(type));

                switch type
                case{'double'}
                    javaDataFun=@java.lang.Double;
                case{'single'}
                    javaDataFun=@java.lang.Float;
                case{'int8'}
                    javaDataFun=@java.lang.Byte;
                case{'int16','uint8'}
                    javaDataFun=@java.lang.Short;
                case{'int32','uint16'}
                    javaDataFun=@java.lang.Integer;
                case{'int64'}
                    javaDataFun=@java.lang.Long;
                case{'uint32','uint64'}
                    javaDataFun=@(x)java.math.BigInteger(java.lang.String(num2str(x)));
                end

                if isreal(data)
                    for dataInd=1:numel(data)
                        inData.add(MatlabNumber(javaDataFun(data(dataInd))));
                    end
                    inVarDec=NumericInputVariableDeclaration(inName,inDims,inData,numericType,NumericComplexity.REAL);
                else
                    for dataInd=1:numel(data)
                        inData.add(MatlabNumber(javaDataFun(real(data(dataInd))),javaDataFun(imag(data(dataInd)))));
                    end
                    inVarDec=NumericInputVariableDeclaration(inName,inDims,inData,numericType,NumericComplexity.COMPLEX);
                end
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...

            case 'cell'
                for dataInd=1:numel(data)
                    innerData=data{dataInd};
                    cellName=[name,'_',num2str(dataInd)];
                    inData.add(this.getInVarDec(cellName,class(innerData),size(innerData),innerData));
                end
                inVarDec=CellInputVariableDeclaration(inName,inDims,inData);
            case 'struct'
                fieldNames=fieldnames(data);
                for dataInd=1:numel(data)
                    fieldValueMap=java.util.LinkedHashMap;
                    for fieldInd=1:numel(fieldNames)
                        field=fieldNames{fieldInd};
                        value=getfield(data,{dataInd},field);
                        structName=[name,'_',field,'_',num2str(dataInd)];
                        mapField=java.lang.String(field);
                        mapValue=this.getInVarDec(structName,class(value),size(value),value);
                        fieldValueMap.put(mapField,mapValue);
                    end
                    inData.add(fieldValueMap);
                end
                fieldList=java.util.ArrayList;
                for idx=1:length(fieldNames)
                    fieldList.add(string(fieldNames{idx}));
                end
                inVarDec=StructInputVariableDeclaration(inName,inDims,inData,fieldList);
            end
        end











        function[outVarDec]=getOutVarDec(~,name,type,dims)
            import com.mathworks.toolbox.compiler_examples.strategy_api.NumericType
            import com.mathworks.toolbox.compiler_examples.strategy_api.outputvariables.*
            import java.lang.Math

            outName=java.lang.String(name);



            outDims=java.util.ArrayList;

            for dimInd=1:numel(dims)
                outDims.add(java.lang.Integer(Math.round(dims(dimInd))));
            end


            switch type
            case 'char'
                outVarDec=CharOutputVariableDeclaration(outName,outDims);
            case 'logical'
                outVarDec=LogicalOutputVariableDeclaration(outName,outDims);
            case{'double','single','int8','int16','int32','int64','uint8','uint16','uint32','uint64'}
                numericType=NumericType.getNumericType(java.lang.String(type));
                outVarDec=NumericOutputVariableDeclaration(outName,outDims,numericType);
            case 'cell'
                outVarDec=CellOutputVariableDeclaration(outName,outDims);
            case 'struct'
                outVarDec=StructOutputVariableDeclaration(outName,outDims);
            end
        end




        function[variables,evalErrors]=getVariables(this)
            import java.util.Arrays



            potentialConflictingNames={'this','cleanupObject','vars','forIndex','structIndex','p','evalErrors'};

            this=this.prepareForEval(potentialConflictingNames);


            clear('potentialConflictingNames')

            cleanupObject=onCleanup(@()this.cleanupFcn());

            try
                eval(this.fileContents);
                evalErrors=[];
            catch ME
                evalErrors=java.util.ArrayList;
                javaErrorArray=java.util.ArrayList;
                javaErrorArray.add(java.lang.String.valueOf("EVAL_ERROR"));
                javaErrorArray.add(java.lang.String.valueOf(ME.message));
                evalErrors.add(javaErrorArray)
            end

            vars=whos();


            vars=vars(~ismember({vars.name},{'this','cleanupObject','evalErrors'}));

            variables=struct('Name',{vars.name}.',...
            'Dimensions',{vars.size}.',...
            'Type',{vars.class}.',...
            'Data',[]);

            for idx=1:numel(variables)
                variables(idx).Data=eval(variables(idx).Name);
                variables(idx).Name=this.restoreOriginalName(variables(idx).Name);
            end


        end



        function cleanupFcn(this)
            path(this.originalPath);
            delete(this.listener);
            this.figureManager.stopCapture();
        end



        function name=restoreOriginalName(this,name)
            if(find(strcmp(name,this.newNames),1))
                name=this.conflictingNames{strcmp(name,this.newNames)};
            end
        end



        function this=prepareForEval(this,potentialConflictingNames)


            this=this.replaceConflictingVariableNames(potentialConflictingNames);


            this.originalPath=path;
            cellfun(@(x)addpath(x),this.functionPaths);



            this.figureManager=compiler.internal.FigureManager(groot);
            this.figureManager.startCapture();
        end


        function[this]=replaceConflictingVariableNames(this,potentialConflictingNames)
            import compiler.internal.ExampleParser.*;

            this.conflictingNames=this.getConflictingVariableNames(potentialConflictingNames);
            this.newNames=cell(length(this.conflictingNames),1);

            for ind=1:length(this.conflictingNames)
                this.newNames{ind}=this.getNonConflictingName(this.conflictingNames{ind});
                indices=this.getConflictPositions(this.conflictingNames{ind});
                this.fileContents=this.replaceVariableName(this.conflictingNames{ind},this.newNames{ind},indices);
            end
        end



        function[conflictingNames]=getConflictingVariableNames(this,potentialConflictingNames)
            variableNamesUsed=this.getVariableNamesUsedInScript();
            conflictingIndices=cell2mat(cellfun(@(x)~isempty(find(strcmp(variableNamesUsed,x),1)),...
            potentialConflictingNames,'UniformOutput',false));
            conflictingNames=potentialConflictingNames(conflictingIndices);
        end



        function[varNamesUsed]=getVariableNamesUsedInScript(this)
            funcTree=mtree(this.fileContents);
            assignedVariables=asgvars(funcTree);
            varNamesUsed=unique(strings(assignedVariables));
        end


        function[newName]=getNonConflictingName(this,oldName)
            number=1;
            newName=[oldName,num2str(number)];
            while this.nameConflicts(newName)
                number=number+1;
                newName=[oldName,num2str(number)];
            end
        end


        function[conflicts]=nameConflicts(this,newName)
            funcTree=mtree(this.fileContents);
            conflicts=~isnull(mtfind(funcTree,'Var',newName));
        end


        function[indices]=getConflictPositions(this,conflictingName)
            funcTree=mtree(this.fileContents);
            conflicts=mtfind(funcTree,'Var',conflictingName);
            indices=position(conflicts);
        end



        function fileContents=replaceVariableName(this,oldName,newName,indices)
            indices=sort(indices,'descend');
            for ind=1:length(indices)
                this.fileContents=[this.fileContents(1:indices(ind)-1)...
                ,newName...
                ,this.fileContents(indices(ind)+length(oldName):length(this.fileContents))];
            end
            fileContents=this.fileContents;
        end

        function argumentTypeErrors=validateArgumentTypes(this,variables)
            import org.apache.commons.lang.*
            import java.util.Arrays

            argumentTypeErrors=java.util.ArrayList;



            for varIdx=1:numel(variables)
                currVariable=variables(varIdx);
                if~this.isSupportedType(currVariable.Type,currVariable.Data)
                    currVariableError=java.util.ArrayList;
                    currVariableError.add(java.lang.String.valueOf("VARIABLE_TYPE_ERROR"))
                    currVariableError.add(java.lang.String.valueOf(currVariable.Name))
                    argumentTypeErrors.add(currVariableError);
                end
            end
        end

        function isSupported=isSupportedType(this,type,data)
            isSupported=false;
            switch type
            case 'char'
                isSupported=true;

            case 'logical'
                isSupported=true;

            case{'double','single','int8','int16','int32','int64','uint8','uint16','uint32','uint64'}
                isSupported=true;

            case 'cell'
                isSupported=true;
                for dataInd=1:numel(data)
                    innerData=data{dataInd};
                    isSupported=this.isSupportedType(class(innerData),innerData);
                    if~isSupported
                        break
                    end
                end

            case 'struct'
                isSupported=true;
                fieldNames=fieldnames(data);
                for dataInd=1:numel(data)
                    for fieldInd=1:numel(fieldNames)
                        field=fieldNames{fieldInd};
                        value=getfield(data,{dataInd},field);
                        isSupported=this.isSupportedType(class(value),value);
                        if~isSupported
                            break
                        end
                    end
                end
            end
        end

    end

end

