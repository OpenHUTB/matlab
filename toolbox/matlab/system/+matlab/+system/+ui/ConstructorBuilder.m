classdef(Hidden)ConstructorBuilder<handle




    properties
        ClassName;
        ObjectName='sysobj';
    end

    properties(Hidden)
        BlockSetParamError;
    end

    properties(SetAccess=private)
        ClassDisplayProperty;
    end

    properties(Access=private)
        ParameterValuePairs;
        StringLiteralParameters={};
        IndentLevel=1;
        HasObjectParameter=false;
    end

    methods
        function obj=ConstructorBuilder(name)
            obj.ClassName=name;
            obj.ParameterValuePairs=struct();
        end

        function paramNames=getParameterNames(obj)
            paramNames=fieldnames(obj.ParameterValuePairs);
        end

        function isParam=isParameter(obj,paramName)
            isParam=isfield(obj.ParameterValuePairs,paramName);
        end

        function isBuilderParam=isBuildableParameter(obj,paramName)
            isBuilderParam=isParameter(obj,paramName)&&...
            isa(obj.ParameterValuePairs.(paramName),'matlab.system.ui.ConstructorBuilder');
        end

        function paramValue=getLiteralParameterValue(obj,paramName)
            paramValue=obj.ParameterValuePairs.(paramName);


            if isa(paramValue,'matlab.system.ui.ConstructorBuilder')
                paramValue=paramValue.buildExpression();
            end
        end

        function paramValue=getParameterValue(obj,paramName)
            paramValue=obj.ParameterValuePairs.(paramName);


            if isa(paramValue,'matlab.system.ui.ConstructorBuilder')
                paramValue=paramValue.buildExpression();
            elseif ismember(paramName,obj.StringLiteralParameters)
                paramValue=mat2str(paramValue);
            end
        end

        function paramValue=getParameterBuilder(obj,paramName)
            paramValue=obj.ParameterValuePairs.(paramName);
            validateattributes(paramValue,{'matlab.system.ui.ConstructorBuilder'},{'nonempty'});
        end

        function addLiteralParameterValue(obj,paramName,paramValue)
            obj.ParameterValuePairs.(paramName)=paramValue;
            obj.StringLiteralParameters=setdiff(obj.StringLiteralParameters,paramName);
        end

        function addStringParameterValue(obj,paramName,paramValue)
            obj.ParameterValuePairs.(paramName)=paramValue;
            obj.StringLiteralParameters=union(obj.StringLiteralParameters,paramName);
        end

        function addObjectParameterValue(obj,paramName,paramValue)
            obj.HasObjectParameter=true;
            addLiteralParameterValue(obj,paramName,paramValue)
        end

        function s=build(obj)
            if~obj.HasObjectParameter
                s=buildWithValuesAssigned(obj);
            else
                s=buildWithValuesConstructed(obj);
            end
        end

        function expression=buildExpression(obj)

            pvPairs='';
            paramNames=obj.getParameterNames();
            numParams=numel(paramNames);
            for k=1:numParams
                paramName=paramNames{k};
                paramValue=obj.getParameterValue(paramName);
                pvPairs=[pvPairs,'''',paramName,''',',paramValue];

                if k<numParams
                    pvPairs=[pvPairs,','];
                end
            end

            expression=[obj.ClassName,'(',pvPairs,')'];
        end

        function v=constructObject(obj,block)


            useBlock=nargin>1;





            v=eval(obj.ClassName);

            ipws=matlab.system.internal.InactiveWarningSuppressor(v);

            paramNames=obj.getParameterNames();
            for k=1:numel(paramNames)
                paramName=paramNames{k};

                try %#ok<TRYNC>
                    if obj.isBuildableParameter(paramName)
                        if useBlock
                            v.(paramName)=obj.getParameterBuilder(paramName).constructObject(block);
                        else
                            v.(paramName)=obj.getParameterBuilder(paramName).constructObject();
                        end
                    else
                        if useBlock
                            blockParent=get_param(block,'Parent');
                            v.(paramName)=slResolve(obj.getParameterValue(paramName),blockParent);
                        else
                            v.(paramName)=evalin('base',obj.getParameterValue(paramName));
                        end
                    end
                end
            end
        end

        function v=validateObject(obj,block)


            useBlock=nargin>1;

            v=eval(obj.ClassName);

            ipws=matlab.system.internal.InactiveWarningSuppressor(v);

            paramNames=obj.getParameterNames();
            for k=1:numel(paramNames)
                paramName=paramNames{k};

                if obj.isBuildableParameter(paramName)
                    if useBlock
                        v.(paramName)=obj.getParameterBuilder(paramName).validateObject(block);
                    else
                        v.(paramName)=obj.getParameterBuilder(paramName).validateObject();
                    end
                else
                    paramValue=obj.getParameterValue(paramName);


                    try
                        if useBlock
                            resolvedExpression=slResolve(paramValue,block);
                        else
                            resolvedExpression=evalin('base',paramValue);
                        end
                    catch
                        continue;
                    end
                    v.(paramName)=resolvedExpression;
                end
            end
        end
    end

    methods(Access=protected)
        function s=buildWithValuesConstructed(obj)






            indent=repmat(' ',1,4*obj.IndentLevel);
            s=[obj.ClassName,'( '];
            paramNames=obj.getParameterNames();
            for pInd=1:numel(paramNames)
                paramName=paramNames{pInd};
                s=[s,'...',char(10),indent,'''',paramName,''',',obj.getParameterValue(paramName),','];%#ok<*AGROW>
            end
            s(end)=')';

            s=[indent,obj.ObjectName,' = ',s,';'];
        end

        function s=buildWithValuesAssigned(obj)






            indent=repmat(' ',1,4*obj.IndentLevel);
            s=[indent,obj.ObjectName,' = ',obj.ClassName,'(); '];
            paramNames=obj.getParameterNames();
            for pInd=1:numel(paramNames)
                paramName=paramNames{pInd};
                s=[s,char(10),indent,obj.ObjectName,'.',paramName,' = ',obj.getParameterValue(paramName),';'];%#ok<*AGROW>
            end
        end
    end

    methods(Static)
        function[builder,parseError]=parse(firstArg,expression,propertyGroupsArgument)






            parseError=false;
            if isempty(firstArg)
                builder=[];
                return;
            end

            if nargin<3
                propertyGroupsArgument=[];
            end


            className=firstArg;
            firstArgIsDisplayProperty=isa(firstArg,'matlab.system.display.internal.Property');
            if nargin<2
                className=getClassNameFromConstructor(firstArg);
                expression=firstArg;
            elseif firstArgIsDisplayProperty&&~isempty(firstArg.CustomPresenter)
                className=getClassNameFromConstructor(expression);
            elseif firstArgIsDisplayProperty
                classNames=firstArg.ClassStringSet.Values;
                isMatch=@(x)strcmp(expression,x)||strncmp(expression,[x,'('],length(x)+1);
                matchMask=cellfun(isMatch,classNames);
                if any(matchMask)
                    className=classNames{matchMask};
                else
                    className='';
                end
            end

            T=mtree(expression);


            if isempty(T)||~isempty(mtfind(T,'Kind','ERR'))
                parseError=true;
                builder=[];
                return;
            end



            if isempty(className)
                builder=[];
                return;
            end


            builder=matlab.system.ui.ConstructorBuilder(className);
            if firstArgIsDisplayProperty
                builder.ClassDisplayProperty=firstArg;
            end



            if strcmp(className,expression)
                return;
            end


            if~strncmp(className,expression,length(className))
                builder=[];
                return;
            end


            rootArgNode=T.root.Arg;
            if~ismember(rootArgNode.kind,{'SUBSCR','CALL'})
                builder=[];
                return;
            end



            groups=matlab.system.display.internal.Memoizer.getPropertyGroups(className,...
            'PropertyGroupsArgument',propertyGroupsArgument);
            dialogProps=matlab.system.ui.getPropertyList(className,groups);

            pNode=rootArgNode.Right;
            while~isempty(pNode)



                if~strcmp(pNode.kind,'CHARVECTOR')
                    builder=[];
                    return;
                end


                pName=eval(pNode.string);
                dialogProp=findobj(dialogProps,'Name',pName);



                if isempty(dialogProp)
                    builder=[];
                    return;
                end


                vNode=pNode.Next;
                if isempty(vNode)
                    builder=[];
                    return;
                end


                vExpression=expression(lefttreepos(vNode):righttreepos(vNode));
                dialogProp.addParsedExpression(vExpression,builder);

                pNode=vNode.Next;
            end
        end

        function[unresolvedParam,unresolvedValue,isExprResolved]=resolveExpression(expression,block)
            isExprResolved=true;
            unresolvedParam='';
            unresolvedValue='';
            try
                [paramBuilder,parseError]=matlab.system.ui.ConstructorBuilder.parse(char(expression));
            catch
                error(message('MATLAB:system:DialogInvalidExpression'));
            end
            if isempty(paramBuilder)



                if parseError
                    error(message('MATLAB:system:DialogInvalidExpression'));
                end
            else
                paramNames=paramBuilder.getParameterNames;
                for i=1:length(paramNames)
                    if~isExprResolved
                        return;
                    end
                    paramName=paramNames{i};
                    if paramBuilder.isBuildableParameter(paramName)
                        subExpr=paramBuilder.getParameterBuilder(paramName).buildExpression;
                        [unresolvedParam,unresolvedValue,isExprResolved]=matlab.system.ui.ConstructorBuilder.resolveExpression(subExpr,block);
                    else
                        paramValue=paramBuilder.getParameterValue(paramName);
                        try
                            blockParent=get_param(block,'Parent');
                            resolvedExpression=slResolve(paramValue,blockParent);
                        catch
                            isExprResolved=false;
                            unresolvedParam=paramName;
                            unresolvedValue=paramValue;
                            return;
                        end
                    end
                end
            end
        end
    end
end

function className=getClassNameFromConstructor(constructorString)

    className=constructorString(1:strfind(constructorString,'(')-1);
    if isempty(className)&&isequal(exist(constructorString,'class'),8)
        className=constructorString;
    elseif~isequal(exist(className,'class'),8)
        className='';
    end
end

