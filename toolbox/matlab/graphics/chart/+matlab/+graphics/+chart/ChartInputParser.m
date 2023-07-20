
classdef ChartInputParser<matlab.graphics.chart.internal.ChartInputParserBase



    properties(Access=public)



        ChartClassName(1,:)char


        DataArgumentPatterns cell


        DataArgumentTypes struct


LeadingFlags



        AllowUnmatched logical=false



TrailingFlags

        LineSpecification struct











    end


    properties(Access=public,Hidden)
Parent
    end


    properties(Access=protected)



ConvenienceRoot


ConvenienceTypes_I


ConvenienceSyntaxList_I


        SetupArgumentsFlag_I logical;



LineSpecification_I


PublicPropertyMetaData


PublicVisibleNames


        SupportsPositionalArguments(1,1)logical;


PositionalArgsList

    end


    methods(Access=public)

        function obj=ChartInputParser(varargin)


            obj.ChartParserState=matlab.graphics.chart.internal.ParserState.Start;


            obj.setupParserRoot;



            obj.SetupArgumentsFlag_I=false;


            obj.SupportsPositionalArguments=false;

            obj.AllowUnmatched=false;




            if nargin==0
                return;
            end




            matlab.graphics.chart.internal.ctorHelper(obj,varargin);





        end

        function remaining=getRemainingArgs(obj)
            remaining=obj.RemainingArgs;
        end

        function args=peekBack(obj,n)
            if nargin==1
                n=1;
            end

            if n>numel(obj.RemainingArgs)
                warning('Peekargs count greater than number of elements');
                n=numel(obj.RemainingArgs);
            end

            args=obj.RemainingArgs(end-n+1:end);
        end

        function args=peekFront(obj,n)
            if nargin==1
                n=1;
            end

            if n>numel(obj.RemainingArgs)
                warning('Peekargs count greater than number of elements');
                n=numel(obj.RemainingArgs);
            end

            args=obj.RemainingArgs(1:n);
        end

        function args=popFront(obj,n)
            if nargin==1
                n=1;
            end

            if n>numel(obj.RemainingArgs)
                warning('Popargs count greater than number of elements');
                n=numel(obj.RemainingArgs);
            end

            args=obj.RemainingArgs(1:n);

            obj.RemainingArgs(1:n)=[];
        end

        function args=popBack(obj,n)
            if nargin==1
                n=1;
            end

            if n>numel(obj.RemainingArgs)
                warning('Peekargs count greater than number of elements');
                n=numel(obj.RemainingArgs);
            end

            args=obj.RemainingArgs(end-n+1:end);
            obj.RemainingArgs(end-n+1:end)=[];
        end

        function disp(obj)
            chart=char(obj.ChartClassName);
            if isempty(obj.ChartClassName)
                chart='UnassignedChart';
            end

            disp([class(obj),' for ',chart,' with supported syntaxes:']);
            disp(' ');


            if~isempty(obj.DataArgumentPatterns)
                for i=1:numel(obj.DataArgumentPatterns)
                    thisArgList=obj.DataArgumentPatterns{i};
                    outSyntax=[chart,'('];
                    for j=1:numel(thisArgList)
                        thisArg=thisArgList{j};
                        outSyntax=strcat(outSyntax,thisArg,', ');
                    end
                    outSyntax(end-1:end)=[];
                    strcat(outSyntax,')');
                    disp(outSyntax);
                end
            end


            if~isempty(obj.LeadingFlags)
                outSyntax=[chart,'(LeadingFlag, __)'];
                disp(outSyntax);
            end

            if~isempty(obj.TrailingFlags)
                outSyntax=[chart,'(__, TrailingFlag)'];
                disp(outSyntax);
            end

            if~isempty(obj.LineSpecification)
                outSyntax=[chart,'(__, Linespec)'];
                disp(outSyntax);
            end

            disp([chart,'(__, Name, Value)']);
            disp([chart,'(parent, __)']);
        end

    end







    methods
        function set.ChartClassName(obj,className)




            if obj.SetupArgumentsFlag_I
                error(message('MATLAB:chartInputParser:AlreadyPresent','ChartClassName'));
            end

            obj.ChartClassName=className;
            obj.setupParser(className);
        end

        function set.DataArgumentPatterns(obj,argsList)



            if obj.SetupArgumentsFlag_I
                error(message('MATLAB:chartInputParser:AlreadyPresent','ChartClassName'));
            end





            obj.DataArgumentPatterns=argsList;
        end

        function set.DataArgumentTypes(obj,typeStruct)



            if obj.SetupArgumentsFlag_I
                error(message('MATLAB:chartInputParser:AlreadyPresent','DataArgumentTypes'));
            end





            obj.DataArgumentTypes=typeStruct;
        end

        function set.TrailingFlags(obj,args)



            if obj.SetupArgumentsFlag_I
                error(message('MATLAB:chartInputParser:AlreadyPresent','TrailingFlags'));
            end


            if~isstruct(args)&&~iscellstr(args)&&~isstring(args)
                error(message('MATLAB:chartInputParser:BadTrailingFlagType'));
            end

            obj.TrailingFlags=args;
        end

        function set.LineSpecification(obj,args)



            if obj.SetupArgumentsFlag_I
                error(message('MATLAB:chartInputParser:AlreadyPresent','LineSpecification'));
            end
            if numel(fieldnames(args))>3
                error(message('MATLAB:chartInputParser:BadLineSpecification'));
            end

            obj.LineSpecification=args;

        end

        function set.LeadingFlags(obj,args)

            if~iscellstr(args)&&~isstring(args)
                error(message('MATLAB:chartInputParser:InvalidLeadingFlags'));
            end


            args=string(args);
            obj.LeadingFlags=args;
        end

    end













    methods(Access=public,Hidden=true)


        function[parentPresent,parent]=parseInitialParent(obj,varargin)









            import matlab.graphics.chart.ChartInputParser;
            import matlab.graphics.chart.internal.ParserState;



            if obj.ChartParserState>=ParserState.ParsedParent
                parent=obj.ParsedParent;
                parentPresent=obj.ParentPresent;
                return;
            end

            obj.RemainingArgs=varargin;

            [parent,ind,parentPresent]=obj.parseInitialParent_I();

            obj.ParentPresent=parentPresent;





            obj.ParsedParent=parent;


            obj.RemainingArgs(ind)=[];


            obj.ChartParserState=ParserState.ParsedParent;
        end

        function[flag]=parseLeadingFlag(obj,varargin)








            import matlab.graphics.chart.internal.ParserState;



            if obj.ChartParserState>=ParserState.ParsedFlag
                flag=obj.parsedFlag;
                return;
            end



            if obj.ChartParserState<ParserState.getPrev(ParserState.ParsedFlag)
                obj.parseInitialParent(varargin{:});
            end

            [flag,ind]=obj.parseLeadingFlag_I();


            obj.RemainingArgs(ind)=[];


            obj.ParsedLeadingFlag=flag;


            obj.ChartParserState=ParserState.ParsedFlag;

        end

        function[ParsedNameValue]=parseNameValue(obj,varargin)
            import matlab.graphics.chart.internal.ParserState;
            import matlab.graphics.chart.ChartInputParser;


            obj.setupArguments;



            if obj.ChartParserState>=ParserState.ParsedNameValue
                ParsedNameValue=obj.ParsedNameValue;
                return;
            end




            if obj.ChartParserState<ParserState.getPrev(ParserState.ParsedNameValue)
                obj.parseLeadingFlag(varargin{:});
            end






            [ParsedNameValue,convEnd]=obj.parseNameValue_I();




            if(convEnd>1)
                obj.RemainingArgs=obj.RemainingArgs(1:convEnd-1);
            else
                obj.RemainingArgs=[];

            end


            savedRemainingArgs=obj.RemainingArgs;
            savedParsedOutput=ParsedNameValue;



            flagParsing=true;
            flag=obj.parseTrailingFlags_I;

            if isempty(flag)
                flagParsing=false;
            end

            errorCaught=false;











            while(~flagParsing)
                errorCaught=false;
                try

                    obj.parseDataArguments_I;
                catch ME
                    errorCaught=true;




                    if strcmp(ME.identifier,"MATLAB:chartInputParser:TooFewDataArgs")



                        if isempty(ParsedNameValue)
                            break;
                        end


                        obj.RemainingArgs=[obj.RemainingArgs,ParsedNameValue(1:2)];
                        ParsedNameValue(1:2)=[];

                    else


                        break;
                    end
                end





                if~errorCaught
                    break;
                end
            end

            if errorCaught








                obj.RemainingArgs=savedRemainingArgs;
                ParsedNameValue=savedParsedOutput;
            end









            [hasParent,parent,ParsedNameValue]=obj.findAndDeleteParent(ParsedNameValue);




            obj.ParsedNameValue=ParsedNameValue;

            if hasParent
                obj.ParentPresent=hasParent;
                if ChartInputParser.isEmptyOrValidParent(parent)
                    obj.ParsedParent=parent;
                    obj.ParentPresent=true;
                else
                    error(message('MATLAB:chartInputParser:BadParent'));
                end
            end


            obj.ChartParserState=ParserState.ParsedNameValue;
        end

        function[withName,withoutName]=parseTrailingFlags(obj,varargin)
            import matlab.graphics.chart.internal.ParserState;


            obj.setupArguments;


            if obj.ChartParserState>=ParserState.ParsedTrailingFlags
                withName=obj.ParsedTrailingFlagsWithNames;
                withoutName=obj.ParsedTrailingFlagsWithoutNames;
                return;
            end


            if obj.ChartParserState<ParserState.getPrev(ParserState.ParsedTrailingFlags)
                obj.parseLeadingFlag(varargin{:});
            end

            [withName,withoutName,RemainingArgs]=obj.parseTrailingFlags_I();


            obj.ParsedNameValue=[withName,obj.ParsedNameValue];


            obj.ParsedTrailingFlagsWithNames=withName;
            obj.ParsedTrailingFlagsWithoutNames=withoutName;

            obj.RemainingArgs=RemainingArgs;
            obj.ChartParserState=ParserState.ParsedTrailingFlags;

        end

        function parsedDataArgs=parseDataArguments(obj,varargin)
            import matlab.graphics.chart.internal.ParserState;


            obj.setupArguments;





            if obj.ChartParserState>=ParserState.ParsedConvenienceArgs
                parsedDataArgs=obj.parsedDataArgs;
                return;
            end


            if obj.ChartParserState<ParserState.getPrev(ParserState.ParsedConvenienceArgs)
                obj.parseNameValue(varargin{:});
            end

            [parsedDataArgs]=obj.parseDataArguments_I();


            obj.ChartParserState=ParserState.ParsedConvenienceArgs;


            obj.ParsedDataArgs=parsedDataArgs;
        end

        function[flag,LineSpecNameVal]=isLinSpec(obj,arg)
            flag=true;
            LineSpecNameVal={};




            if~isstring(arg)&&~ischar(arg)
                flag=false;
                return;
            end

            [LineS,ColorS,MarkerS]=colstyle(arg);

            if isempty(LineS)&&isempty(ColorS)&&isempty(MarkerS)
                flag=false;
                return;
            end



            if isfield(obj.LineSpecification_I,'LineStyle')
                LineSpecNameVal=[LineSpecNameVal,obj.LineSpecification_I.LineStyle,{LineS}];
            end

            if isfield(obj.LineSpecification_I,'MarkerStyle')
                LineSpecNameVal=[LineSpecNameVal,obj.LineSpecification_I.MarkerStyle,{MarkerS}];
            end

            if isfield(obj.LineSpecification_I,'Color')
                LineSpecNameVal=[LineSpecNameVal,obj.LineSpecification_I.Color,{ColorS}];
            end
        end

        function[flag,namedEnum,namelessEnum]=isEnumFlag(obj,arg)

            flag=false;
            namedEnum={};
            namelessEnum={};


            if~isstring(arg)&&~ischar(arg)
                return;
            end




            if isstruct(obj.TrailingFlags)
                fNames=fieldnames(obj.TrailingFlags);
                fieldNameMatched=[];
                fullArg=[];
                for i=1:numel(fNames)
                    fieldName=fNames{i};

                    values={obj.TrailingFlags.(fieldName)};
                    matchedVal=matlab.graphics.chart.ChartInputParser.matchTerminalFlag(values,arg);

                    if~isempty(matchedVal)

                        if isempty(fieldNameMatched)&&numel(matchedVal)==1
                            fieldNameMatched=fieldName;
                            fullArg=matchedVal{1};
                        else



                            return;
                        end

                    end
                end


                if~isempty(fieldNameMatched)

                    namedEnum={fieldNameMatched,fullArg};
                    flag=true;
                end
            else


                values=obj.TrailingFlags;
                matchedVal=matlab.graphics.chart.ChartInputParser.matchTerminalFlag(values,arg);
                if numel(matchedVal)==1


                    namelessEnum=matchedVal;
                    flag=true;
                end
            end
        end

        function validateParent(obj)
            parentArg=obj.ParsedParent;


            if isempty(parentArg)
                return
            end


            if~isscalar(parentArg)
                error('Parent must be scalar');
            elseif~isvalid(parentArg)
                error('Parent is recently deleted');
            end

        end

        function validateNameValuePairs(obj)
            args=obj.ParsedOutput;

            for i=1:2:numel(args)
                thisName=args{i};
                thisValue=args{i+1};


                isValid=validatePair(obj,thisName,thisValue);

                if isValid==false
                    error(['Invalid Name Value pair: ',thisName]);
                end
            end
        end

        function crossValidateNameValuePairs(obj)

            args=obj.ParsedOutput;

            for i=1:2:numel(args)
                nameValueStruct.(args{i})=args{i+1};
            end


            for i=1:numel(obj.CrossValidationNames)
                allFound=true;
                thisNameList=obj.CrossValidationNames{i};
                valueCell=cell(1,numel(thisNameList));

                for j=1:numel(thisNameList)

                    if~isfield(nameValueStruct,thisNameList{j})
                        allFound=false;
                        break;
                    else
                        valueCell{j}=nameValueStruct.(thisNameList{j});
                    end
                end

                if allFound==true

                    validators=obj.CrossValidationFunctions{i};
                    for j=1:numel(validators)
                        feval(validators{j},obj.ValidatorInstance,valueCell{:})
                    end
                end
            end
        end


        function dbg_print(obj)
            obj.RemainingArgs
            obj.ParsedParent
            obj.ParsedDataArgs
            obj.ParsedNameValue
            obj.ParsedOutput


            obj.ParsedLeadingFlag



            obj.ParsedTrailingFlagsWithoutNames={};


            obj.ParsedTrailingFlagsWithNames
        end
    end



    methods(Access=private)



        function[parent,ind,parentPresent]=parseInitialParent_I(obj)
            parentPresent=false;
            parent=gobjects(0);
            inputArgs=obj.RemainingArgs;
            ind=false(1,numel(inputArgs));

            if isempty(inputArgs)
                return;
            end

            if matlab.graphics.chart.ChartInputParser.isValidParent(inputArgs{1})
                parent=inputArgs{1};
                ind(1)=true;
                parentPresent=true;
            end
        end

        function[flag,ind]=parseLeadingFlag_I(obj)
            flag=[];
            ind=[];
            if isempty(obj.LeadingFlags)
                return;
            end


            argList=obj.RemainingArgs;
            choices=obj.LeadingFlags;



            Match=cellfun(@(x)matlab.graphics.chart.ChartInputParser.matchLeadingFlags(x,choices),...
            argList,'UniformOutput',0);

            ArgMatch=cellfun(@(x)any(x),Match);


            ind=find(ArgMatch);

            if isempty(ind)
                return;
            end

            flag=obj.RemainingArgs{ind};
        end

        function[ParsedOutput,convEnd]=parseNameValue_I(obj)

            argList=obj.RemainingArgs;

            argLen=numel(argList);
            convEnd=argLen+1;
            ParsedOutput={};

            for i=argLen-1:-2:1
                partialName=argList{i};

                if isstring(partialName)&&~isscalar(partialName)
                    break;
                end


                if~ischar(partialName)&&~isstring(partialName)
                    break;
                end

                fullName=obj.getFullName(partialName);





                if isempty(fullName)


                    if isempty(obj.DataArgumentPatterns)

                        throwAsCaller(MException('MATLAB:hg:InvalidProperty',message('MATLAB:hg:InvalidProperty',partialName,obj.ChartClassName)));
                    end
                    break;
                end

                argList{i}=fullName;
                convEnd=i;
            end



            if(convEnd<argLen)
                ParsedOutput=argList(convEnd:end);
            end

        end

        function[withName,withoutName,argList]=parseTrailingFlags_I(obj)
            withName=[];
            withoutName=[];
            argList=obj.RemainingArgs;


            for i=1:numel(argList)
                thisArg=argList{end};
                if~isempty(obj.TrailingFlags)
                    [flag,named,nameless]=obj.isEnumFlag(thisArg);
                    if flag
                        withName=[named,withName];%#ok<AGROW>
                        withoutName=[withoutName,nameless];%#ok<AGROW>
                        argList(end)=[];
                        continue;
                    end
                end

                if~isempty(obj.LineSpecification)
                    [flag,named]=obj.isLinSpec(thisArg);

                    if flag
                        argList(end)=[];


                        withName=[named,withName];%#ok<AGROW>
                        continue;
                    end
                end

                break;
            end
        end

        function ParsedOutput=parseDataArguments_I(obj,varargin)


            thisNode=obj.ConvenienceRoot;
            inputList=obj.RemainingArgs;
            ParsedOutput={};

            if isempty(inputList)
                return;
            end

            for i=1:numel(inputList)
                thisInput=inputList{i};





                thisLevel=thisNode.Next;
                foundNode=[];

                if isempty(thisLevel)
                    error(message('MATLAB:chartInputParser:TooManyDataArgs'));
                end

                for j=1:numel(thisLevel)
                    if isa(thisInput,thisLevel{j}.TypeName)
                        foundNode=thisLevel{j};
                        break;
                    elseif thisLevel{j}.TypeName(1)=='@'
                        typeName=thisLevel{j}.TypeName(2:end);
                        try
                            hgcastvalue(typeName,thisInput);


                            foundNode=thisLevel{j};
                            break;
                        catch
                        end
                    end
                end

                if isempty(foundNode)
                    error(message('MATLAB:chartInputParser:IncorrectDataArgs'))
                end


                thisNode=foundNode;
            end


            if isempty(thisNode.PathID)
                error(message('MATLAB:chartInputParser:TooFewDataArgs'))
            end


            syntaxList=obj.ConvenienceSyntaxList_I{thisNode.PathID};
            ParsedOutput=cell(1,2*numel(syntaxList));


            for i=1:numel(inputList)
                ParsedOutput{2*i-1}=syntaxList{i};
                ParsedOutput{2*i}=inputList{i};
            end
        end

        function ParsedOutput=parsePositionalArgs_I(obj,varargin)

            inputList=obj.RemainingArgs;
            ParsedOutput={};

            if isempty(inputList)
                return;
            end


            nArgs=numel(inputList);

            nArgsPossible=numel(obj.PositionalArgsList);

            if(nArgs>nArgsPossible)
                error(message('MATLAB:chartInputParser:TooManyDataArgs'));
            end


            Names=obj.PositionalArgsList(1:nArgs);



            ParsedOutput=cell(1,2*nArgs);

            ParsedOutput(1:2:end)=Names;
            ParsedOutput(2:2:end)=inputList;
        end
    end


    methods(Access=private)

        function setupParserRoot(obj)
            parserRoot=matlab.graphics.chart.internal.ParserNode;
            parserRoot.TypeName='proot';
            parserRoot.Next={};
            obj.ConvenienceRoot=parserRoot;
        end



        function setupParser(obj,className)

            nameStruct=struct;

            ClassMetaData=meta.class.fromName(className);

            if isempty(ClassMetaData)
                error(message('MATLAB:chartInputParser:InvalidChartName'));
            end


            PropertyMetaData=findobj(ClassMetaData.PropertyList,'SetAccess','public');


            for i=1:numel(PropertyMetaData)
                thisField=PropertyMetaData(i).Name;
                nameStruct.(thisField)=PropertyMetaData(i);

                validation=PropertyMetaData(i).Validation;

                if~isempty(validation)
                    if~isempty(validation.Class)
                        obj.ConvenienceTypes_I.(thisField)=string(validation.Class.Name);
                    end
                end
            end

            obj.PublicVisibleNames=properties(className);
            obj.PublicPropertyMetaData=nameStruct;


        end



        function setupArguments(obj)
            if obj.SetupArgumentsFlag_I==true
                return;
            end

            if isempty(obj.ChartClassName)
                error("Specify ChartClassName to set up chart.");
            end


            if~isempty(obj.DataArgumentTypes)
                obj.setupDataArgTypes();
            end


            obj.setupDataArgumentsPatterns();

            if~isempty(obj.TrailingFlags)
                obj.setupTrailingFlags();
            end

            if~isempty(obj.LineSpecification)
                obj.setupLineSpecification;
            end


            obj.SetupArgumentsFlag_I=true;
        end


        function setupTrailingFlags(obj)
            args=obj.TrailingFlags;
            if isstruct(args)

                fNames=fieldnames(args);
                isValid=obj.isValidPropertyName(fNames);

                ind=find(isValid==0,1);

                if~isempty(ind)
                    error(message('MATLAB:chartInputParser:WrongName',...
                    fNames{ind(1)},'TrailingFlags'));
                end

            end
        end


        function setupDataArgumentsPatterns(obj)

            syntaxList=obj.DataArgumentPatterns;


            obj.validateDataArgPatterns(syntaxList);


            for i=1:numel(syntaxList)
                obj.recursiveBuildSyntaxTree(obj.ConvenienceRoot,syntaxList{i},i);
            end


            obj.ConvenienceSyntaxList_I=syntaxList;

            obj.SetupArgumentsFlag_I=true;
        end


        function setupDataArgTypes(obj)

            typeStruct=obj.DataArgumentTypes;


            fields=fieldnames(typeStruct);


            obj.validateDataArgPatterns(fields);

            for i=1:numel(fields)
                field=fields{i};
                Value=typeStruct.(field);

                if isfield(obj.ConvenienceTypes_I,field)
                    warning(['Replacing previously set type for ',field]);
                end

                p=find(Value=='numeric');
                if~isempty(p)

                    Value(p)=[];
                    Value=[Value,obj.NumericTypes];%#ok<AGROW>
                end
                obj.ConvenienceTypes_I.(field)=Value;
            end
        end


        function setupLineSpecification(obj)
            origLineSpec=obj.LineSpecification;

            fs=fieldnames(origLineSpec);

            for i=1:numel(fs)
                f=fs{i};

                if~obj.isValidPropertyName(f)
                    error(message('MATLAB:chartInputParser:WrongName',f,'LineSpecification'));
                end

                value=origLineSpec.(f);
                if strcmpi(value,'Color')
                    if isfield(obj.LineSpecification,'Color')
                        warning(message('MATLAB:chartInputParser:RepeatedLineSpec','color'));
                    end

                    obj.LineSpecification_I.Color=f;
                elseif strcmpi(value,'LineStyle')
                    if isfield(obj.LineSpecification,'LineStyle')
                        warning(message('MATLAB:chartInputParser:RepeatedLineSpec','linestyle'));
                    end
                    obj.LineSpecification_I.LineStyle=f;
                elseif strcmpi(value,'MarkerStyle')
                    if isfield(obj.LineSpecification,'MarkerStyle')
                        warning(message('MATLAB:chartInputParser:RepeatedLineSpec','markerstyle'));
                    end
                    obj.LineSpecification_I.MarkerStyle=f;
                end
            end
        end

    end

    methods

        function fullName=getFullName(obj,partialName)
            AllNames=fieldnames(obj.PublicPropertyMetaData);
            VisibleNames=obj.PublicVisibleNames;
            fullName=[];

            matched=strcmpi(partialName,AllNames);

            if any(matched)==0
                matched=startsWith(VisibleNames,partialName,'IgnoreCase',true);
                if matched==0
                    return;
                end
                AllNames=VisibleNames;
            end

            index=find(matched);



            if numel(index)~=1


                fullName=[];
                for j=1:numel(index)
                    if strcmpi(AllNames{index(j)},partialName)
                        fullName=AllNames{index(j)};
                        break;
                    end
                end





                if isempty(fullName)
                    return;
                end
            else


                fullName=AllNames{index};
            end
        end

        function isValid=validatePair(obj,Name,Value)


            thisNameMetaData=obj.PublicPropertyMetaData.(Name);


            thisValidationClass=thisNameMetaData.Validation;


            if(isempty(thisValidationClass))


                isValid=matlab.graphics.chart.ChartInputParser.validateType(thisNameMetaData,Value);
            else

                isValid=matlab.graphics.chart.ChartInputParser.validateClass(thisValidationClass,Value);
            end
        end

        function recursiveBuildSyntaxTree(obj,node,nameList,pathID)

            if isempty(nameList)

                if~isempty(node.PathID)
                    error(message('MATLAB:chartInputParser:AmbiguousPattern'));
                else
                    node.PathID=pathID;
                end

                return;
            end


            thisName=nameList{1};


            thisLevel=node.Next;


            if~isfield(obj.ConvenienceTypes_I,thisName)
                error(message('MATLAB:chartInputParser:UnspecifiedType',thisName));
            end


            typeList=obj.ConvenienceTypes_I.(thisName);


            for i=1:numel(typeList)

                thisType=typeList{i};
                foundNode=[];

                for j=1:numel(thisLevel)
                    thisName=thisLevel{j}.TypeName;

                    if strcmp(thisName,thisType)
                        foundNode=thisLevel{j};
                        break;
                    end
                end



                if isempty(foundNode)


                    newNode=matlab.graphics.chart.internal.ParserNode;
                    newNode.TypeName=thisType;
                    newNode.Parent=node;
                    newNode.Next={};
                    node.Next(end+1)={newNode};
                    nextNode=newNode;

                else

                    nextNode=foundNode;
                end


                nextNameList=nameList;
                nextNameList(1)=[];


                obj.recursiveBuildSyntaxTree(nextNode,nextNameList,pathID);
            end
        end





        function[hasParent,parent,remainingNV]=findAndDeleteParent(obj,args)
            nArgs=numel(args);
            keepThese=true(1,nArgs);
            parent=gobjects(0);
            remainingNV=[];
            hasParent=false;
            if isempty(args)
                return;
            end

            for i=1:2:nArgs
                pName=args{i};


                fullName=obj.getFullName(pName);


                if strcmpi(fullName,"Parent")
                    keepThese(i:i+1)=false;
                    parent=args{i+1};
                    hasParent=true;
                end
            end

            remainingNV=args(keepThese);
        end

        function validateDataArgPatterns(obj,patterns)

            if~iscell(patterns)
                error(message('MATLAB:chartInputParser:DataArgWrongType'));
            end

            for i=1:numel(patterns)
                pattern=patterns{i};


                if~iscellstr(pattern)
                    error(message('MATLAB:chartInputParser:DataArgWrongType'));
                end



                valid=obj.isValidPropertyName(pattern);


                invalidIndices=find(valid==0);



                if~isempty(invalidIndices)
                    error(message('MATLAB:chartInputParser:WrongName',...
                    pattern{invalidIndices(1)},'DataArgumentPatterns'));
                end
            end
        end

        function isValid=isValidPropertyName(obj,propName)

            names=fieldnames(obj.PublicPropertyMetaData);
            isValid=ismember(propName,names);

        end
    end


    methods(Access=private,Static)
        function fullName=matchTerminalFlag(values,arg)

            fullName='';
            tf=startsWith(values,arg);
            ind=find(tf);

            if~isempty(ind)
                fullName=values(ind);
            end
        end

        function matched=matchLeadingFlags(element,choices)
            if~isstring(element)&&~ischar(element)
                matched=zeros(size(choices));
            else
                matched=strcmpi(element,choices);
            end
        end

        function[isParent]=isEmptyOrValidParent(item)
            import matlab.graphics.chart.ChartInputParser;
            isParent=(isnumeric(item)&&isempty(item))||...
            (isempty(item)&&isa(item,'matlab.graphics.GraphicsPlaceholder'))||...
            (~isempty(item)&&ChartInputParser.isValidParent(item));
        end

        function[isParent]=isValidParent(item)
            isParent=isscalar(item)&&...
            isa(item,'matlab.graphics.Graphics')&&...
            ~isa(item,'matlab.graphics.GraphicsPlaceholder');

        end

        function isValid=validateType(thisNameMetaData,Value)

            thisType=thisNameMetaData.Type;
            isValid=true;

            try
                hgcastvalue(thisType.Name,Value);
            catch
                isValid=false;
            end
        end

        function isValid=validateClass(thisValidationClass,Value)
            isValid=true;

            try

                if~isempty(thisValidationClass.Class)

                end


                if~isempty(thisValidationClass.ValidatorFunctions)

                    validatorFuncs=thisValidationClass.ValidatorFunctions;

                    for i=1:numel(validatorFuncs)
                        validatorFunc=validatorFuncs{i};
                        validatorFunc(Value);
                    end

                end



                if~isempty(thisValidationClass.Size)
                    arrayDimension=thisValidationClass.Size;
                    for i=1:numel(arrayDimension)
                        switch class(arrayDimension(i))
                        case 'meta.FixedDimension'
                            assert(size(Value,i)==arrayDimension(i).Length);
                        case 'meta.UnrestrictedDimension'

                        end
                    end
                end
            catch
                isValid=false;
            end
        end
    end
end



