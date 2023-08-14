classdef(Abstract)spiceBase<handle





    properties(Constant,Access=protected)
        commentIndicators=["*",";"];
        scaleFactors=struct(...
        't',1e12,...
        'g',1e9,...
        'meg',1e6,...
        'k',1e3,...
        'mil',25.4e-6,...
        'm',1e-3,...
        'u',1e-6,...
        'n',1e-9,...
        'p',1e-12,...
        'f',1e-15);
        supportedMATLABFunctions=["abs","acos","asin","atan","atan2"...
        ,"cos","cosh","der","exp","log","log10","max","min","sin"...
        ,"sinh","sqrt","tan","tanh","simscape.power","ln","limit"...
        ,"poly","pulse","pwl","sffm","value","simscape.tablelookup"...
        ,"simscape.function.abs","simscape.function.acosm","simscape.function.asinm"...
        ,"simscape.function.coshm","simscape.function.expm","simscape.function.limitm"...
        ,"simscape.function.log10m","simscape.function.logm","simscape.function.maxm"...
        ,"simscape.function.minm","simscape.function.powerRational"...
        ,"simscape.function.sign","simscape.function.sinhm"...
        ,"simscape.function.sqrtm","simscape.function.tanm"...
        ,"simscape.function.limit"];
        subcircuit2sscReservedWords=["capacitorSeriesResistance"...
        ,"inductorParallelConductance","specifyParasiticValues"...
        ,"crossZero","dropPowerFlag","dropPowerHypEpsilon","dropTanFlag"...
        ,"dropTanHypEpsilon","dropTanX0","expXh","expXl"...
        ,"hyperbolicMaximumAbsolute","logX0","smoothN","smoothEpsilon"...
        ,"aWarning"];
        maxSimscapeTextLength=100;
    end

    properties(Access=public)
        name;
        nodes;
        connectingNodes;
        unsupportedStrings=string.empty;
        conversionNotes=string.empty;
    end

    methods(Access=protected)
        function str=getConnectionString(this,varargin)
            if length(this.nodes)~=length(this.connectingNodes)
                pm_error('physmod:ee:spice2ssc:UnconnectedNodes',this.name);
            end
            str=strings(1,length(this.nodes));
            if isempty(varargin)
                for ii=1:length(str)
                    str(ii)="connect("+this.name+"."...
                    +this.nodes(ii)+","...
                    +this.connectingNodes(ii)+");";
                end
            elseif nargin==2
                componentName=varargin{1};
                for ii=1:length(str)
                    str(ii)="connect("+componentName+"."...
                    +this.nodes(ii)+","...
                    +this.connectingNodes(ii)+");";
                end
            else
                pm_error('physmod:ee:spice2ssc:IncorrectNumberParameters');
            end
        end
    end

    methods(Static,Access=protected)
        function result=isLiteralParameter(instr)
            cond1=isempty(str2num(instr));%#ok<ST2NM>
            cond2=~(strncmpi(instr,'{',1)...
            ||strncmpi(instr,'(',1)...
            ||strncmpi(instr,'[',1));
            result=cond1&&cond2;
        end

        function outstr=reformatStringWithContinuation(instr)
            expr="(.{"+num2str(spiceBase.maxSimscapeTextLength)+"}[,\(\s])(?=\w)";
            tab=sprintf('    ');
            [~,endPos]=regexp(instr,expr);
            for i=1:numel(endPos)
                substring=extractBetween(instr,1,endPos(i));
                while endPos(i)<=strlength(instr)&&mod(length(strfind(substring,"'")),2)~=0
                    endPos(i)=endPos(i)+1;
                    substring=extractBetween(instr,1,endPos(i));
                end
            end
            for i=numel(endPos):-1:1
                instr=insertAfter(instr,endPos(i)," ..."+newline+tab+tab+tab);
            end
            outstr=instr;
        end

        function newString=parseSpiceUnits(str)


            unitNames=fieldnames(spiceBase.scaleFactors);
            newString=str;
            if~isstring(str)
                return;
            end




            key="__SIMSCAPE_LEADING_NUMERIC_NODE_NAME_";
            matchStr=regexp(newString,"(\d+\w\.v)",'match');

            if length(newString)==1
                for ii=1:length(matchStr)
                    newString=strrep(newString,matchStr(ii),key+int2str(ii));
                end
            else
                for ii=1:length(matchStr)
                    for jj=1:length(matchStr{ii})
                        newString(ii)=strrep(newString(ii),matchStr{ii}(jj),key+int2str(jj));
                    end
                end
            end




            newString=regexprep(newString,"(?i)(?<![a-z]\d*|\_\d*)(\.?\d++(e[+-]?\d++)?)+"...
            +unitNames,"($1*"+cellfun(@(x)(spiceBase.scaleFactors.(x)),unitNames)+")");



            newString=regexprep(newString,"(?i)(?<![a-z]|\_)(\.?\d++(e[+-]?\d++)?)+"...
            +char(181),"($1*1e-06)");
            newString=regexprep(newString,"(?i)(?<![a-z]|\_)(\.?\d++(e[+-]?\d++)?)+"...
            +char(956),"($1*1e-06)");


            newString=regexprep(newString,"(?i)(?<=\W+(\.?\d++(e[+-]?\d++)?)+)([a-d]|[f-z])+","");







            newString=regexprep(newString,"(?<=\))\w+","");


            if length(newString)==1
                for ii=1:length(matchStr)
                    newString=strrep(newString,key+int2str(ii),matchStr(ii));
                end
            else
                for ii=1:length(matchStr)
                    for jj=1:length(matchStr{ii})
                        newString(ii)=strrep(newString(ii),key+int2str(jj),matchStr{ii}(jj));
                    end
                end
            end

        end

        function[names,values]=parseNameEqualsValue(str)




            str=spiceSubckt.parseSpiceUnits(str);



            exprGroups=spiceSubckt.findEnclosure(str,'{','}');
            if isempty(exprGroups)
                expressions=string.empty;
                strExprRemoved=str;
            else
                expressions=strings(1,size(exprGroups,1));
                for ii=1:size(exprGroups,1)
                    expressions(ii)=extractBetween(str,exprGroups(ii,1)+1,exprGroups(ii,2)-1);
                end
                strExprRemoved=replace(str,"{"+expressions+"}","{}");
            end

            strExprRemoved=regexprep(strExprRemoved,spiceBase.commentIndicators(2)+".*","");

            strComponents=strsplit(strExprRemoved,[" ","=",","]);
            strComponents(strComponents=="")=[];
            if mod(length(strComponents),2)~=0
                pm_error('physmod:ee:spice2ssc:UnexpectedFormat',str);
            end
            names=strComponents(1:2:end);
            tempVals=strComponents(2:2:end);


            if any(contains(names,["^"," ","+","-","*","/","~","|","&","=","(",")","{","}","[","]",","]))
                pm_error('physmod:ee:spice2ssc:UnexpectedFormat',str);
            end

            expr_indices=find(strcmp(tempVals,"{}"));
            val_indices=find(~strcmp(tempVals,"{}").*~strcmp(tempVals,"simscape.function.powerRational()"));

            if length(expr_indices)~=length(expressions)
                pm_error('physmod:ee:spice2ssc:UnexpectedFormat',str);
            end
            values=cell(1,length(names));


            tempNumVals=cell(1,length(val_indices));
            for ii=1:length(val_indices)
                tempNumVals(ii)={str2num(tempVals{val_indices(ii)})};%#ok<ST2NM>
            end



            idx=find(cellfun(@isempty,tempNumVals));
            for ii=1:length(idx)
                tempNumVals{idx(ii)}=tempVals{val_indices(idx(ii))};
            end



            for ii=1:length(expr_indices)
                values{expr_indices(ii)}=expressions(ii);
            end
            for ii=1:length(val_indices)
                values{val_indices(ii)}=tempNumVals{ii};
            end
        end

        function result=fnExpander(str,data)


            calledFunctions=regexpi(str,"(?<=^|[^.a-zA-Z_0-9])\w+(?=\()",'match');
            la=ismember(calledFunctions,data.names);
            result=str;

            if~any(la)
                return;
            end

            libName=spiceBase.extractLibraryName(data.path);
            for ii=1:length(la)
                if la(ii)
                    idx=find(data.names==calledFunctions(ii),1);
                    extraArgs=strtrim(strjoin(data.parameters{idx},","));
                    parOpen=regexp(result,"(?<=(^|[^.a-zA-Z_0-9])"+calledFunctions(ii)+")\(",'start');
                    fnStart=regexp(result,"(?<=^|[^.a-zA-Z_0-9])"+calledFunctions(ii)+"\(",'start');
                    for jj=length(parOpen):-1:1
                        fnParIndices=spiceSubckt.findEnclosure(result,'(',')');
                        indexRow=find(parOpen(jj)==fnParIndices(:,1),1);
                        parClose=fnParIndices(indexRow,2);

                        if strlength(extraArgs)>=1
                            if parOpen(jj)==parClose-1
                                result=replaceBetween(result,parClose,parClose-1,extraArgs);
                            else
                                result=replaceBetween(result,parClose,parClose-1,","+extraArgs);
                            end
                        end
                        result=replaceBetween(result,fnStart(jj),fnStart(jj)-1,libName+".");
                    end
                end
            end
        end

        function[result,modified]=getUniqueNames(str,excludeStr,prefix)


            if~exist('prefix','var')
                prefix='node_';
            end
            [validValues,modified1]=matlab.lang.makeValidName(str,'Prefix',prefix);
            [result,modified2]=matlab.lang.makeUniqueStrings(validValues,excludeStr,namelengthmax);
            modified=modified1|modified2;
        end

        function[strippedString,expr]=stripArguments(cleanStr,delimiterStart,delimiterEnd)


            delimiterStart=string(delimiterStart);
            delimiterEnd=string(delimiterEnd);
            exprGroups=spiceBase.findEnclosure(cleanStr,delimiterStart,delimiterEnd);
            expr=string.empty;
            strippedString=cleanStr;
            lastUsed=0;
            for ii=1:size(exprGroups,1)
                if exprGroups(ii,2)>lastUsed
                    expr(end+1)=extractBetween(cleanStr,exprGroups(ii,1)+1,exprGroups(ii,2)-1);%#ok<AGROW>
                    strippedString=regexprep(strippedString,...
                    regexptranslate('escape',delimiterStart+expr(end)+delimiterEnd),...
                    delimiterStart+delimiterEnd,1);
                    lastUsed=exprGroups(ii,2);
                end
            end
        end

        function result=parseModelDefinition(str)

            [s,brace,paren,brack]=spiceBase.stripEnclosedArguments(str);
            [strComponents,matches]=strsplit(s,{' ','()','[]'});
            matches=strtrim(matches);
            for ii=1:length(matches)
                if matches(ii)=="()"
                    strComponents(ii+1)="()";
                elseif matches(ii)=="[]"
                    strComponents(ii+1)="[]";
                end
            end
            splitString=spiceBase.repopulateArguments(strComponents,brace,paren,brack,false);
            if length(splitString)<2
                result.supportedString=false;
            else
                result.name=splitString(1);
                result.type=splitString(2);
                result.supportedString=true;
                if length(splitString)>2
                    parameters=strjoin(splitString(3:end));
                    strippedString=spiceBase.stripOuterParen(parameters);
                    strippedString=spiceBase.stripOuterBrack(strippedString);
                    [result.parameterNames,result.parameterValues]=...
                    spiceBase.parseNameEqualsValue(strippedString);
                else
                    result.parameterNames=string.empty;
                    result.parameterValues=string.empty;
                end
            end
        end

        function index=findNameEquals(cellArray,name)


            index=[];
            for ii=1:length(cellArray)
                if length(cellArray{ii})>1&&strcmpi(cellArray{ii}(1),name)
                    index=ii;
                end
            end
        end

        function index=findName(cellArray,name)

            index=[];
            for ii=1:length(cellArray)
                tempString=spiceBase.stripEnclosedArguments(cellArray{ii}(1));
                tempString=regexprep(tempString,"\(\)","");
                tempString=regexprep(tempString,"\{\}","");
                tempString=regexprep(tempString,"\[\]","");
                if strcmpi(tempString,name)
                    index=ii;
                end
            end
        end

        function str=stripOuterParen(strin)

            if strncmpi(strin,'(',1)
                [~,str]=spiceBase.stripArguments(strin,'(',')');
            else
                str=strin;
            end
        end

        function str=stripOuterBrack(strin)

            if strncmpi(strin,'[',1)
                [~,str]=spiceBase.stripArguments(strin,'[',']');
            else
                str=strin;
            end
        end

        function libName=extractLibraryName(strin)


            [s,e,libName]=regexp(strin,"(?<=(\"+filesep+"\+|^\+))\w+",'start','end','match');
            if length(libName)>1
                for ii=2:length(s)
                    if s(ii)~=e(ii-1)+3
                        pm_error('physmod:ee:spice2ssc:UnexpectedFormat',getString(message('physmod:ee:library:comments:spice2ssc:spiceBase:error_LibraryPath')));
                    end
                end
                if e(end)~=strlength(strin)
                    pm_error('physmod:ee:spice2ssc:UnexpectedFormat',getString(message('physmod:ee:library:comments:spice2ssc:spiceBase:error_LibraryPath')));
                end
                libName=strjoin(libName,'.');
            elseif length(libName)==1
                if e(end)~=strlength(strin)
                    pm_error('physmod:ee:spice2ssc:UnexpectedFormat',getString(message('physmod:ee:library:comments:spice2ssc:spiceBase:error_LibraryPath')));
                end
            end
        end
    end

    methods(Static,Access=public)
        function[strippedString,exprBraces,exprParen,exprBrackets]=stripEnclosedArguments(cleanStr)


            [strippedString,exprBraces]=spiceBase.stripArguments(cleanStr,"{","}");
            exprBraces=regexprep(exprBraces,"(?<!(\Wif|\Welse|,))\s+(?=(\+|\-)\S)","");
            exprBraces=strrep(exprBraces,"{","(");
            exprBraces=strrep(exprBraces,"}",")");
            [strippedString,exprParen]=spiceBase.stripArguments(strippedString,"(",")");
            [strippedString,exprBrackets]=spiceBase.stripArguments(strippedString,"[","]");
        end

        function indices=findEnclosure(str,delimiterStart,delimiterEnd,errCheck)







            if strcmp(delimiterStart,delimiterEnd)
                pm_error('physmod:ee:spice2ssc:DoesNotMatch',getString(message('physmod:ee:library:comments:spice2ssc:spiceBase:error_StartDelimiter')),getString(message('physmod:ee:library:comments:spice2ssc:spiceBase:error_EndDelimiter')),str);
            end


            charStr=char(str);


            startIndices=strfind(charStr,delimiterStart);
            endIndices=strfind(charStr,delimiterEnd);

            if nargin<4
                errCheck=true;
            end

            if errCheck&&length(startIndices)~=length(endIndices)
                pm_error('physmod:ee:spice2ssc:NotPaired',getString(message('physmod:ee:library:comments:spice2ssc:spiceBase:error_Delimiters')),str);
            else
                minLength=min(length(startIndices),length(endIndices));
                startIndices=startIndices(1:minLength);
                endIndices=endIndices(1:minLength);
            end


            if~isempty(startIndices)
                indices=[startIndices(:),NaN*ones(length(endIndices),1)];
                for ii=1:length(endIndices)

                    ndex=find(endIndices(ii)>startIndices,1,'last');
                    indices(ndex,2)=endIndices(ii);



                    startIndices(ndex)=NaN;
                end
            else
                indices=[];
            end
        end

        function result=repopulateArguments(strippedString,brace,paren,brack,omitEnclFlag)





            if~exist('omitEnclFlag','var')
                omitEnclFlag=true;
            end

            result=strippedString;
            indices=strfind(result,"[]");
            if iscell(indices)
                loc=cellfun(@length,indices);
                if sum(loc)~=length(brack)
                    pm_error('physmod:ee:spice2ssc:Mismatch',getString(message('physmod:ee:library:comments:spice2ssc:spiceBase:error_NumberOfExpression')),getString(message('physmod:ee:library:comments:spice2ssc:spiceBase:error_NumberOfGroups')),strippedString);
                end
                cells2modify=find(loc);
                cellindices=zeros(length(cells2modify),2);
                ctr=1;
                for ii=length(cells2modify):-1:1
                    numMods=loc(cells2modify(ii));
                    cellindices(ctr:(ctr+numMods-1),1)=cells2modify(ii);
                    cellindices(ctr:(ctr+numMods-1),2)=numMods:-1:1;
                    ctr=ctr+numMods;
                end
                for ii=1:length(brack)
                    idx=indices{cellindices(ii,1)}(cellindices(ii,2));
                    result(cellindices(ii,1))=replaceBetween(result(cellindices(ii,1)),idx,idx+1,"["+brack(length(brack)-ii+1)+"]");
                end

                indices=strfind(result,"()");
                loc=cellfun(@length,indices);
                if sum(loc)~=length(paren)
                    pm_error('physmod:ee:spice2ssc:Mismatch',getString(message('physmod:ee:library:comments:spice2ssc:spiceBase:error_NumberOfParentheses')),getString(message('physmod:ee:library:comments:spice2ssc:spiceBase:error_ExpectedNumber')),strippedString(1));
                end
                cells2modify=find(loc);
                cellindices=zeros(length(cells2modify),2);
                ctr=1;
                for ii=length(cells2modify):-1:1
                    numMods=loc(cells2modify(ii));
                    cellindices(ctr:(ctr+numMods-1),1)=cells2modify(ii);
                    cellindices(ctr:(ctr+numMods-1),2)=numMods:-1:1;
                    ctr=ctr+numMods;
                end
                for ii=1:length(paren)
                    idx=indices{cellindices(ii,1)}(cellindices(ii,2));
                    result(cellindices(ii,1))=replaceBetween(result(cellindices(ii,1)),idx,idx+1,"("+paren(length(paren)-ii+1)+")");
                end

                indices=strfind(result,"{}");
                loc=cellfun(@length,indices);
                if sum(loc)~=length(brace)
                    pm_error('physmod:ee:spice2ssc:Mismatch',getString(message('physmod:ee:library:comments:spice2ssc:spiceBase:error_NumberOfBraces')),getString(message('physmod:ee:library:comments:spice2ssc:spiceBase:error_ExpectedNumber')),strippedString);
                end
                cells2modify=find(loc);
                cellindices=zeros(length(cells2modify),2);
                ctr=1;
                for ii=length(cells2modify):-1:1
                    numMods=loc(cells2modify(ii));
                    cellindices(ctr:(ctr+numMods-1),1)=cells2modify(ii);
                    cellindices(ctr:(ctr+numMods-1),2)=numMods:-1:1;
                    ctr=ctr+numMods;
                end
                for ii=1:length(brace)
                    idx=indices{cellindices(ii,1)}(cellindices(ii,2));
                    if omitEnclFlag
                        result(cellindices(ii,1))=replaceBetween(result(cellindices(ii,1)),idx,idx+1,brace(length(brace)-ii+1));
                    else
                        result(cellindices(ii,1))=replaceBetween(result(cellindices(ii,1)),idx,idx+1,"{"+brace(length(brace)-ii+1)+"}");
                    end
                end
            else
                if length(indices)~=length(brack)
                    pm_error('physmod:ee:spice2ssc:Mismatch',getString(message('physmod:ee:library:comments:spice2ssc:spiceBase:error_NumberOfBrackets')),getString(message('physmod:ee:library:comments:spice2ssc:spiceBase:error_ExpectedNumber')),strippedString);
                end
                for ii=length(brack):-1:1
                    result=replaceBetween(result,indices(ii),indices(ii)+1,"["+brack(ii)+"]");
                end

                indices=strfind(result,"()");
                if length(indices)~=length(paren)
                    pm_error('physmod:ee:spice2ssc:Mismatch',getString(message('physmod:ee:library:comments:spice2ssc:spiceBase:error_NumberOfParentheses')),getString(message('physmod:ee:library:comments:spice2ssc:spiceBase:error_ExpectedNumber')),strippedString);
                end
                for ii=length(paren):-1:1
                    result=replaceBetween(result,indices(ii),indices(ii)+1,"("+paren(ii)+")");
                end

                indices=strfind(result,"{}");
                if length(indices)~=length(brace)
                    pm_error('physmod:ee:spice2ssc:Mismatch',getString(message('physmod:ee:library:comments:spice2ssc:spiceBase:error_NumberOfBraces')),getString(message('physmod:ee:library:comments:spice2ssc:spiceBase:error_ExpectedNumber')),strippedString);
                end
                for ii=length(brace):-1:1
                    if omitEnclFlag
                        result=replaceBetween(result,indices(ii),indices(ii)+1,brace(ii));
                    else
                        result=replaceBetween(result,indices(ii),indices(ii)+1,"{"+brace(ii)+"}");
                    end
                end
            end
        end

        function components=parseSpiceString(str,varargin)


            defaultIgnoreEqual=false;
            p=inputParser;
            addParameter(p,'ignoreEqual',defaultIgnoreEqual,@islogical);
            parse(p,varargin{:});

            str=regexprep(str,spiceBase.commentIndicators(2)+".*","");
            [s,brace,paren,brack]=spiceBase.stripEnclosedArguments(str);
            [strComponents,matches]=strsplit(s,{' ',',',':','='});
            splitString=spiceBase.repopulateArguments(strComponents,brace,paren,brack,false);
            ii=1;
            components={};
            while ii<=length(splitString)
                if ii<length(splitString)
                    switch strtrim(matches(ii))
                    case ":"
                        components{end+1}=splitString(ii)+":";%#ok<AGROW>
                        ii=ii+1;
                    case "="
                        if p.Results.ignoreEqual
                            components{end+1}=splitString(ii);%#ok<AGROW>
                            ii=ii+1;
                        else
                            components{end+1}=[splitString(ii),splitString(ii+1)];%#ok<AGROW>
                            ii=ii+2;
                        end
                    otherwise
                        components{end+1}=splitString(ii);%#ok<AGROW>
                        ii=ii+1;
                    end
                else
                    components{end+1}=splitString(ii);%#ok<AGROW>
                    ii=ii+1;
                end
            end
        end

        function str=stripOuterBraces(strin)

            if strncmpi(strin,'{',1)
                [~,str]=spiceBase.stripArguments(strin,'{','}');
            else
                str=strin;
            end
        end

        function[in,out]=extractTableData(strin)
            max_attempts=10;
            basicString=strrep(strin,")(",") (");
            strippedString="()";
            exprParen=basicString;
            attempt=1;
            while strippedString=="()"&&attempt<max_attempts
                [strippedString,exprBraces,exprParen,exprBrackets]=spiceBase.stripEnclosedArguments(exprParen);
                attempt=attempt+1;
            end
            if attempt>=max_attempts
                pm_error('physmod:ee:spice2ssc:UnexpectedFormat',strin);
            end
            splitString=strsplit(strippedString,[" ",","]);
            splitString=spiceBase.repopulateArguments(splitString,exprBraces,exprParen,exprBrackets);
            splitString=regexprep(splitString,"^\((.*)\)$","$1");
            splitString=strsplit(strjoin(splitString," "),[" ",","]);
            splitString(splitString=="")=[];
            in=splitString(1:2:end);
            out=splitString(2:2:end);
        end

        function newString=parseSpiceUnitsIdx(str,idx)





            idx=idx-1;
            strparse=spiceBase.parseSpiceUnits(str);
            ssplit1=strsplit(str);
            ssplit2=strsplit(strparse);
            if size(ssplit1,2)>=idx
                newString=strjoin([ssplit1(1:idx),ssplit2(idx+1:end)]);
            else
                newString=strparse;
            end
        end

        function newStrComponents=parseSpiceUnitsCell(strComponents,varargin)



            if nargin==2
                idx_start=varargin{1};
                idx_end=length(strComponents);
            elseif nargin==3
                idx_start=varargin{1};
                idx_end=varargin{2};
            end

            newStrComponents=strComponents;
            for ii=idx_start:idx_end
                newStrComponents{ii}=spiceBase.parseSpiceUnits(strComponents{ii});
            end
        end

    end

    methods(Abstract)



        output=getSimscapeText(this,libName);
    end
end
