function amiTree=readAmiFile(varargin)





    import serdes.internal.ibisami.ami.* %#ok<NSTIMP>





    if nargin>0
        fileName=varargin{1};
    else
        fileName="";
    end
    oldWarnState=warning('off','backtrace');
    c=onCleanup(@()warning(oldWarnState));
    fileContents=fileread(fileName);

    if nargin>1
        doSerDesTree=varargin{2};
    else
        doSerDesTree=false;
    end
    remainder=stripComments(fileContents);
    lineNum=1;
    inReservedParameters=false;
    inModelSpecific=false;
    amiTree=[];

    [initialToken,remainder,lineNum]=nextToken(remainder,lineNum);
    if strcmp(initialToken,"(")&&~isempty(remainder)
        [initialToken,remainder,lineNum]=nextToken(remainder,lineNum);
        if~strcmp(initialToken,"(")&&~strcmp(initialToken,")")&&~isempty(remainder)
            if doSerDesTree
                amiTree=SerDesTree(initialToken,false);
            else
                amiTree=Tree(initialToken,false);
            end
            recursivelyAddSubTree(amiTree.getRootNode())
            if doSerDesTree
                amiTree.setPaths2Nodes
            end
        else
            error(message('serdes:ibis:BadFileStart'))
        end
    else
        error(message('serdes:ibis:BadFileStart'))
    end

    function recursivelyAddSubTree(node)


        [token,remainder,lineNum]=nextToken(remainder,lineNum);
        while~isempty(remainder)&&~strcmp(token,")")
            if strcmp(token,"(")
                [token,remainder,lineNum]=nextToken(remainder,lineNum);
                if isempty(remainder)
                    warning(message('serdes:ibis:UnexpectedEOF',lineNum))
                    break;
                elseif strcmp(token,"(")
                    warning(message('serdes:ibis:BranchNameExpected',lineNum))
                    [remainder,lineNum]=skipThruMatchingClsParen(remainder,lineNum);
                    break;
                elseif strcmp(token,")")

                    break;
                else





                    node=nextBranchName(node,token);
                end
            else
                warning(message('serdes:ibis:OpenParensExpected',token,lineNum))
                break;
            end
            [token,remainder,lineNum]=nextToken(remainder,lineNum);
        end
    end
    function node=nextBranchName(node,branchName)
        import serdes.internal.ibisami.ami.*
        import serdes.internal.ibisami.ami.parameter.*

        if strcmpi(branchName,"Format")
            [branchName,remainder,lineNum]=nextToken(remainder,lineNum);
        end
        if strcmpi(branchName,"Description")


            [token,remainder,lineNum]=nextToken(remainder,lineNum);
            if isempty(remainder)||isempty(token)
                error(message('serdes:ibis:UnexpectedEOF',lineNum))
            end
            node.Description=token;
            [remainder,lineNum]=skipThruMatchingClsParen(remainder,lineNum);
        elseif AmiParameter.isPropertyString(branchName)||...
            AmiParameter.isFormatKeyWord(branchName)




            if~isa(node,'serdes.internal.ibisami.ami.parameter.AmiParameter')
                if AmiParameter.isReservedParameterName(branchName)
                    if~inReservedParameters
                        warning(message('serdes:ibis:WrongParameterBranch',branchName,'Model_Specific',lineNum))
                    end
                    branchNode=AmiParameter.getReservedParameter(node.NodeName);
                else
                    if~inModelSpecific
                        warning(message('serdes:ibis:WrongParameterBranch',branchName,'Reserved_Parameters',lineNum))
                    end
                    branchNode=getParamForTreeType(node.NodeName);
                end
                amiTree.replaceNode(node,branchNode)
                node=branchNode;
            end

            if strcmpi("Type",branchName)
                types=[];
                [typeName,remainder,lineNum]=nextToken(remainder,lineNum);
                while~isempty(remainder)&&~strcmp(typeName,')')
                    if AmiParameter.isType(typeName)
                        types=[types,string(typeName)];%#ok<AGROW>
                    else
                        warning(message('serdes:ibis:UnrecongnizedAmiItem','Type',typeName,lineNum))
                    end
                    [typeName,remainder,lineNum]=nextToken(remainder,lineNum);
                end
                node.Types=types;
            elseif strcmpi("Usage",branchName)
                [usageName,remainder,lineNum]=nextToken(remainder,lineNum);
                if AmiParameter.isUsage(usageName)
                    node.Usage=AmiParameter.getUsageFromName(usageName);
                else
                    warning(message('serdes:ibis:UnrecongnizedAmiItem','Usage',usageName,lineNum))
                end
                [remainder,lineNum]=skipThruMatchingClsParen(remainder,lineNum);
            elseif strcmpi("Default",branchName)
                [defaultValue,remainder,lineNum]=nextToken(remainder,lineNum);
                node.Default=defaultValue;
                if isempty(node.Format)
                    node.Format=serdes.internal.ibisami.ami.format.Value(defaultValue);
                end
                [remainder,lineNum]=skipThruMatchingClsParen(remainder,lineNum);
            elseif AmiParameter.isFormatKeyWord(branchName)
                if strcmpi(branchName,"Table")


                    format=generateTableFormat(node);
                else
                    formatArgs={};
                    [formatArg,remainder,lineNum]=nextToken(remainder,lineNum);
                    while~isempty(remainder)&&~strcmp(formatArg,")")
                        formatArgs=[formatArgs,{formatArg}];%#ok<AGROW>
                        [formatArg,remainder,lineNum]=nextToken(remainder,lineNum);
                    end
                    format=AmiParameter.getFormatForFormatName(branchName,formatArgs);
                end
                node.Format=format;
            else
                warning(message('serdes:ibis:UnrecongnizedAmiItem','Format or Branch',branchName,lineNum))
                [remainder,lineNum]=skipThruMatchingClsParen(remainder,lineNum);
            end
        elseif strcmpi(branchName,'list_tip')
            format=node.Format;
            if isempty(format)||~isa(format,'serdes.internal.ibisami.ami.format.List')
                warning(message('serdes:ibis:ListTipMustBeList',lineNum))
                [remainder,lineNum]=skipThruMatchingClsParen(remainder,lineNum);
            else
                listTips=[];
                [token,remainder,lineNum]=nextToken(remainder,lineNum);
                while~isempty(remainder)&&(~strcmp(token,")"))
                    listTips=[listTips,token];%#ok<AGROW>
                    [token,remainder,lineNum]=nextToken(remainder,lineNum);
                end
                format.ListTips=listTips;
                node.Format=format;
            end
        elseif amiTree.isRoot(node)


            if~strcmpi(branchName,Tree.ModelSpecificName)&&...
                ~strcmpi(branchName,Tree.ReservedParametersName)
                warning(message('serdes:ibis:RequiresRoot',lineNum))
            end
            branchNode=getNodeForTreeType(branchName);
            amiTree.addChild(node,branchNode)
            if strcmpi(branchName,"Model_Specific")
                inModelSpecific=true;
                inReservedParameters=false;
            else
                inReservedParameters=true;
                inModelSpecific=false;
            end
            recursivelyAddSubTree(branchNode)
        else


            if isa(node,'serdes.internal.ibisami.ami.parameter.AmiParameter')
                warning(message('serdes:ibis:AddBranchToParameter',branchName,node.NodeName,lineNum))
                [remainder,lineNum]=skipThruMatchingClsParen(remainder,lineNum);
            else
                if AmiParameter.isReservedParameterName(branchName)
                    if~inReservedParameters
                        warning(message('serdes:ibis:WrongParameterBranch',branchName,'Model_Specific',lineNum))
                        branchNode=getNodeForTreeType(branchName);
                    else
                        branchNode=AmiParameter.getReservedParameter(branchName);
                    end
                else
                    if inReservedParameters
                        warning(message('serdes:ibis:WrongParameterBranch',branchName,'Reserved_Parameters',lineNum))
                    end
                    branchNode=getNodeForTreeType(branchName);
                end
                amiTree.addChild(node,branchNode)
                recursivelyAddSubTree(branchNode)
            end
        end


    end
    function param=getParamForTreeType(parameterName)
        if doSerDesTree
            param=serdes.internal.ibisami.ami.parameter.SerDesModelSpecificParameter(parameterName);
        else
            param=serdes.internal.ibisami.ami.parameter.ModelSpecificParameter(parameterName);
        end
    end
    function node=getNodeForTreeType(nodeName)
        if doSerDesTree
            node=serdes.internal.ibisami.ami.SerDesNode(nodeName);
        else
            node=serdes.internal.ibisami.ami.Node(nodeName);
        end
    end
    function tableFormat=generateTableFormat(node)
...
...
...
...
...
...
...
...
        startLine=lineNum;
        tableFormat=serdes.internal.ibisami.ami.format.Table();
        labels=[];
        tableArray=[];
        while~isempty(remainder)
            [token,remainder,lineNum]=nextToken(remainder,lineNum);
            if strcmp(token,")")
                break
            end

            if~strcmp(token,"(")
                warning(message('serdes:ibis:ExpectedAnOpenParen',node.NodeName,token,lineNum))
                [remainder,lineNum]=skipThruMatchingClsParen(remainder,lineNum);
                continue;
            end


            [token,remainder,lineNum]=nextToken(remainder,lineNum);
            if isempty(remainder)
                break;
            end

            inLabels=false;
            if strcmpi("Labels",token)
                if~isempty(labels)
                    warning(message('serdes:ibis:DuplicateLabels',node.NodeName,lineNum))
                    [remainder,lineNum]=skipThruMatchingClsParen(remainder,lineNum);
                else
                    inLabels=true;
                    [token,remainder,lineNum]=nextToken(remainder,lineNum);
                end
            end
            rowVector=[];
            while~isempty(remainder)&&(~strcmp(token,")"))
                rowVector=[rowVector,token];%#ok<AGROW>
                [token,remainder,lineNum]=nextToken(remainder,lineNum);
            end
            if~isempty(rowVector)
                if inLabels
                    labels=rowVector;
                else
                    tableArray=[tableArray;rowVector];%#ok<AGROW>
                end
            end
        end
        if~isempty(labels)
            tableFormat.Labels=labels;
        end
        if~isempty(tableArray)
            tableFormat.Values=tableArray;
        else
            warning(message('serdes:ibis:NoTableValues',node.NodeName,startLine))
        end
    end
end
function[remainder,lineNum]=skipThruMatchingClsParen(remainder,lineNum)




    remainder=char(remainder);
    parenCount=1;
    while~isempty(remainder)&&parenCount~=0
        [token,remainder,lineNum]=nextToken(remainder,lineNum);
        if strcmp(token,")")
            parenCount=parenCount-1;
        elseif strcmp(token,"(")
            parenCount=parenCount+1;
        end
    end




end
function[token,remainder,lineNum]=nextToken(remainder,lineNum)
...
...
...
...
...
...
...
...
...

    remainder=char(remainder);

    while~isempty(remainder)&&remainder(1)<=32
        if remainder(1)==newline
            lineNum=lineNum+1;
        end
        remainder=remainder(2:end);
    end
    if isempty(remainder)
        token=char.empty;
        return
    end
    token="";
    inQuote=false;
    tokenFound=false;
    while~tokenFound&&~isempty(remainder)



        chr=remainder(1);
        if inQuote

            remainder=remainder(2:end);

            token=token+chr;

            if chr=='"'



                inQuote=false;
            else



                if chr==newline
                    lineNum=lineNum+1;
                end
            end
        elseif chr=='('||chr==')'

            if token==""

                remainder=remainder(2:end);
                token=string(chr);
                tokenFound=true;
            else



                tokenFound=true;
            end
        elseif chr<=32





            tokenFound=true;
        else


            remainder=remainder(2:end);
            token=token+chr;
            if chr=='"'





                inQuote=true;
            end
        end
    end
end
function noComments=stripComments(withComments)



    withComments=char(withComments);
    inQuote=false;
    inComment=false;
    noComments="";
    nextChr=1;
    lastChar=strlength(withComments);
    while nextChr<=lastChar
        chr=withComments(nextChr);
        if inQuote


            noComments=noComments+chr;
            if chr=='"'
                inQuote=false;
            end
        elseif inComment

            if chr==newline


                inComment=false;
                noComments=noComments+chr;
            end
        elseif chr=='|'

            inComment=true;
        else

            noComments=noComments+chr;

            if chr=='"'
                inQuote=true;
            end
        end
        nextChr=nextChr+1;
    end
end
