classdef ParseTreeUtils




    methods(Static)
        function mt=getTree(classCode,varargin)


            mt=mtree(classCode,'-com','-cell',varargin{:});
        end

        function isErr=isTreeError(mt)




            isErr=(mt.count==1)&&mt.iskind('ERR');
        end

        function m=getTreeErrorMessage(mt)


            if matlab.system.editor.internal.ParseTreeUtils.isTreeError(mt)


                errResults=regexp(string(mt),'^L\s*(\S+)\s*\(C\s*(\S+)\)\:\s*\w+\:\s*(.*)','tokens','once');
                if numel(errResults)==3
                    m=message('MATLAB:system:Editor:CodeSyntaxErrorLine',errResults{1},errResults{3});
                else
                    m=message('MATLAB:system:Editor:CodeSyntaxError');
                end
            else
                m='';
            end
        end

        function className=getClassName(classdefNode)


            classExprNode=classdefNode.Cexpr;
            classNameNode=classExprNode.Left;
            if isnull(classNameNode)
                classNameNode=classExprNode;
            end
            className=string(classNameNode);
        end

        function superClasses=getSuperClasses(classdefNode)


            superClasses={};


            superClassNode=classdefNode.Cexpr.Right;
            while~isnull(superClassNode)&&strcmp(kind(superClassNode),'AND')
                superClasses{end+1}=string(superClassNode.Right);%#ok<*AGROW>
                superClassNode=superClassNode.Left;
            end


            if~isnull(superClassNode)
                superClasses{end+1}=string(superClassNode);
            end


            superClasses=superClasses(end:-1:1);
        end

        function isSubclass=isSubclassOf(classdefNode,name,parentSuperClasses)

            isSubclass=false;



            if nargin<3
                parentSuperClasses={};
            end


            superClasses=matlab.system.editor.internal.ParseTreeUtils.getSuperClasses(classdefNode);
            if ismember(name,superClasses)
                isSubclass=true;
                return;
            end


            for k=1:numel(superClasses)
                superClassName=superClasses{k};
                superClassFile=which(superClassName);


                if isempty(superClassFile)||ismember(superClassName,parentSuperClasses)
                    continue;
                end

                [~,~,ext]=fileparts(superClassFile);
                if strcmp(ext,'.m')
                    mt=matlab.system.editor.internal.ParseTreeUtils.getTree(superClassFile,'-file');
                    if matlab.system.editor.internal.ParseTreeUtils.isTreeError(mt)
                        continue;
                    end
                    if matlab.system.editor.internal.ParseTreeUtils.isSubclassOf(...
                        mtfind(mt,'Kind','CLASSDEF'),name,[parentSuperClasses,superClasses])
                        isSubclass=true;
                        return;
                    end
                elseif strcmp(ext,'.p')
                    try

                        mc=meta.class.fromName(superClassName);
                        if~isempty(mc)&&(mc<=meta.class.fromName(name))
                            isSubclass=true;
                            return;
                        end
                    catch e %#ok<NASGU>

                    end
                end
            end
        end

        function[names,nodes]=getMethodInputNames(methodNode)


            names={};
            nodes={};
            if~isnull(methodNode)
                insNode=methodNode.Ins;
                if~isnull(insNode)
                    methodInputNode=insNode.Next;
                    [names,nodes]=getArgumentListNames(methodInputNode);
                end
            end
        end

        function[names,nodes]=getMethodOutputNames(methodNode)


            names={};
            nodes={};
            if~isnull(methodNode)
                [names,nodes]=getArgumentListNames(methodNode.Outs);
            end
        end

        function[names,nodes]=getPropertyBlockProperties(propertyBlock)


            names={};
            nodes={};
            propertyNode=propertyBlock.Body;
            while~isnull(propertyNode)
                if~isCommentNode(propertyNode)
                    propertyNameNode=propertyNode.Left;
                    if strcmp(propertyNameNode.kind,'PROPTYPEDECL')
                        propertyNameNode=propertyNameNode.VarName;
                    end
                    names{end+1}=string(propertyNameNode);
                    nodes{end+1}=propertyNode;
                end
                propertyNode=propertyNode.Next;
            end
        end

        function[setAccess,getAccess,attributes]=getPropertyBlockAttributes(propertyBlock)



            attributes={};
            setAccess='public';
            getAccess='public';


            attributesNode=propertyBlock.Attr;
            if isnull(attributesNode)
                return;
            end
            attribute=attributesNode.Arg;
            if isnull(attribute)
                return;
            end


            while~isnull(attribute)
                switch string(attribute.Left)
                case{'Access'}
                    attributeAccess=getAccessValue(attribute);
                    setAccess=attributeAccess;
                    getAccess=attributeAccess;
                case{'GetAccess'}
                    getAccess=getAccessValue(attribute);
                case{'SetAccess'}
                    setAccess=getAccessValue(attribute);
                otherwise
                    attributes=addAttributeName(attributes,attribute);
                end
                attribute=attribute.Next;
            end
        end

        function[access,attributes]=getMethodBlockAttributes(methodsBlock)



            attributes={};
            access='public';


            attributesNode=methodsBlock.Attr;
            if isnull(attributesNode)||isnull(attributesNode.Arg)
                return;
            end


            attribute=attributesNode.Arg;
            while~isnull(attribute)
                switch string(attribute.Left)
                case{'Access'}
                    access=getAccessValue(attribute);
                otherwise
                    attributes=addAttributeName(attributes,attribute);
                end
                attribute=attribute.Next;
            end
        end
        function[attributes]=getClassAttributes(mt)



            attributes={};
            ClassdefNode=mtfind(mt,'Kind','CEXPR');
            attributeArgumentNode=ClassdefNode.Left.Arg;
            if isnull(attributeArgumentNode)
                return;
            end
            for Count=1:length(attributeArgumentNode)
                while~isnull(attributeArgumentNode)
                    if(~isempty(attributeArgumentNode.Left))
                        attributes=addAttributeName(attributes,attributeArgumentNode);
                    end
                    attributeArgumentNode=attributeArgumentNode.Next;
                end
            end
        end

        function[methodNames,methodNodes]=getMethodBlockMethods(methodsBlock)






            methodNodes={};
            methodNames={};
            functionNode=methodsBlock.Body;
            while~isnull(functionNode)
                if~isCommentNode(functionNode)
                    methodNodes{end+1}=functionNode;
                    methodNames{end+1}=string(functionNode.Fname);
                end
                functionNode=functionNode.Next;
            end
        end

        function methodNode=getMethodNode(classdefNode,methodName)




            methodNode=mtfind(subtree(classdefNode),'Kind','FUNCTION',...
            'Fname.String',methodName);





            if~isnull(methodNode)&&(methodNode.count>1||~strcmp(methodNode.trueparent.kind,'METHODS'))
                methodBlocks=mtfind(subtree(classdefNode),'Kind','METHODS');
                methodNode=[];
                for methodBlockIndex=indices(methodBlocks)
                    methodBlock=select(methodBlocks,methodBlockIndex);
                    [blockMethodNames,blockMethodNodes]=matlab.system.editor.internal.ParseTreeUtils.getMethodBlockMethods(methodBlock);
                    [foundMethodName,k]=intersect(blockMethodNames,methodName);
                    if~isempty(foundMethodName)
                        methodNode=blockMethodNodes{k};
                        return;
                    end
                end
            end
        end

        function[L,C]=getCodePreInsertionPosition(blockNode)



            [L,C]=pos2lc(blockNode,lefttreepos(blockNode));



            if isBlockCommentNode(blockNode)
                C=regexp(string(blockNode),'^\s*%','end');
            end


            Lnew=L;
            Cnew=C;
            commentNode=blockNode.previous;
            isClassComment=false;
            while isStandAloneCommentAboveLine(commentNode,Lnew)&&~isClassComment

                [Lnew,Cnew]=pos2lc(commentNode,lefttreepos(commentNode));
                if isBlockCommentNode(commentNode)
                    Cnew=regexp(string(commentNode),'^\s*%','end');
                end


                parentNode=commentNode.Parent;
                if~isnull(parentNode)&&strcmp(parentNode.kind,'CLASSDEF')
                    exprNode=parentNode.Cexpr;
                    Lparent=pos2lc(exprNode,righttreepos(exprNode));
                    isClassComment=(Lnew==Lparent)||(Lnew==Lparent+1);
                end


                commentNode=commentNode.previous;
            end

            if~isClassComment
                L=Lnew;
                C=Cnew;
            end
        end

        function testNode=getNextNonCommentNode(initialNode,testNode)


            L=pos2lc(initialNode,righttreepos(initialNode));
            if~isnull(testNode)&&isCommentNode(testNode)
                Lcommentstart=pos2lc(testNode,lefttreepos(testNode));
                if(Lcommentstart==L)||(Lcommentstart==L+1)
                    testNode=matlab.system.editor.internal.ParseTreeUtils.getNextNonCommentNode(testNode,testNode.Next);
                end
            end
        end
        function isNonDirect=hasNonDirectAuthoringMethods(classdefNode)




            isNonDirect=~isempty(mtfind(subtree(classdefNode),'Kind','FUNCTION',...
            'Fname.String',{'outputImpl','updateImpl'}));
        end

        function isConstantReturn=methodWithConstantReturn(classdefNode,mutableMethodName)


            isConstantReturn=false;
            methodNode=matlab.system.editor.internal.ParseTreeUtils.getMethodNode(classdefNode,mutableMethodName);


            methodBody=mtree(methodNode.Body.tree2str);
            if isempty(methodBody)




                return
            end
            methodBodyNode=methodBody.select(1);
            if(strcmpi(kind(methodBodyNode),'EXPR')&&...
                isempty(methodBodyNode.Next)&&...
                strcmpi(kind(methodBodyNode.Arg),'EQUALS'))



                outArg=methodNode.Outs;
                exprNode=methodBodyNode.Arg;
                if strcmpi(kind(exprNode.Left),'CELL')
                    varName=exprNode.Left.Left.string;
                elseif(strcmpi(kind(exprNode.Left),'ID'))
                    varName=exprNode.Left.string;
                else
                    return;

                end
                isConstantReturn=strcmpi(varName,outArg.string)&&...
                strcmpi(exprNode.Right.Left.string,'false');
            end
        end

        function isStrictDefaults=hasStrictDefaults(mt)

            isStrictDefaults=ismember('StrictDefaults',...
            matlab.system.editor.internal.ParseTreeUtils.getClassAttributes(mt));
            if~(isStrictDefaults)




                superClassNames=...
                matlab.system.editor.internal.ParseTreeUtils.getSuperClasses(mt);
                superClassNames(strcmp(superClassNames,'matlab.System'))=[];

                superClassNames=...
                superClassNames(cellfun(@(x)~startsWith(x,{'matlab.system.mixin.'}),superClassNames));
                for Count=1:length(superClassNames)
                    try
                        metaClassData=meta.class.fromName(superClassNames{Count});
                        if(~isempty(metaClassData))&&metaClassData.StrictDefaults
                            isStrictDefaults=metaClassData.StrictDefaults;
                            if(isStrictDefaults)
                                break;
                            end
                        end
                    catch Excep

                    end
                end
            end
        end
    end
end

function isPrecedingComment=isStandAloneCommentAboveLine(testNode,L)



    isPrecedingComment=false;
    if~isnull(testNode)&&isCommentNode(testNode)
        Lcommentend=pos2lc(testNode,righttreepos(testNode));
        if Lcommentend==L-1


            preCommentNode=testNode.previous;
            if isnull(preCommentNode)
                parentNode=testNode.Parent;
                if~isnull(parentNode)&&strcmp(parentNode.kind,'METHODS')
                    preCommentNode=parentNode.Attr;
                end
            end


            if isnull(preCommentNode)
                isPrecedingComment=true;
            else
                Lprecommentend=pos2lc(preCommentNode,righttreepos(preCommentNode));
                isPrecedingComment=(Lprecommentend~=Lcommentend);
            end
        end
    end
end

function isComment=isCommentNode(node)
    isComment=ismember(node.kind,{'COMMENT','BLKCOM','CELLMARK'});
end

function isComment=isBlockCommentNode(node)
    isComment=ismember(node.kind,{'BLKCOM','CELLMARK'});
end

function access=getAccessValue(attribute)


    try
        access=string(attribute.Right);
        if strcmp(access(1),'''')&&length(access)>2&&strcmp(access(end),'''')
            access=access(2:end-1);
        end
    catch e %#ok<NASGU>

        access='friends';
    end
end

function attributesList=addAttributeName(attributesList,attributeNode)




    attributeValue=attributeNode.Right;
    isAttributeTrue=isnull(attributeValue)||...
    (~strcmp(attributeValue.kind,'NOT')&&strcmp(string(attributeValue),'true'));
    if isAttributeTrue
        attributesList{end+1}=string(attributeNode.Left);
    end
end

function[names,nodes]=getArgumentListNames(argNode)


    names={};
    nodes={};
    while~isnull(argNode)
        if argNode.iskind('NOT')
            name='~';
        else
            name=string(argNode);
        end
        names{end+1}=name;
        nodes{end+1}=argNode;
        argNode=argNode.Next;
    end
end
