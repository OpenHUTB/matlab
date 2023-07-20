classdef EvalExpr





    methods(Static)

        function nodeDescriptor=NodeEval(node,argDescriptors,numOutputs,...
            constAnnotator)
            import internal.mtree.analysis.EvalExpr.*

            if numOutputs~=1
                assert(ismember(node.kind,{'CALL','SUBSCR','CELL'}),...
                ['Only one output possible for operator ',node.kind]);
            end

            argDescriptorsOrig=argDescriptors;
            argDescriptors=internal.mtree.analysis.expandDescriptors(argDescriptorsOrig);

            type=constAnnotator.getType(node);
            origTypeUnknown=type.isUnknown;
            if numOutputs==1&&type.isUnknown
                type=resolveUnknownType(node,argDescriptors,constAnnotator);
            end

            nodeDescriptor=NodeEvalImpl(node,argDescriptors,argDescriptorsOrig,type,...
            numOutputs,constAnnotator,origTypeUnknown);
        end

    end

    methods(Static,Access=protected)



        function nodeDescriptor=NodeEvalImpl(node,argDescriptors,argDescriptorsOrig,type,...
            numOutputs,constAnnotator,origTypeUnknown)
            import internal.mtree.analysis.EvalExpr.*

            switch node.kind
            case{'INT',...
                'DOUBLE',...
                'HEX',...
                'BINARY',...
                'NOT',...
                'TRANS',...
                'DOTTRANS',...
                'UPLUS',...
                'PARENS',...
                'PLUS',...
                'MINUS',...
                'MUL',...
                'DIV',...
                'LDIV',...
                'EXP',...
                'DOTMUL',...
                'DOTDIV',...
                'DOTLDIV',...
                'DOTEXP',...
                'AND',...
                'OR',...
                'DOTLP',...
                'LB',...
                'LC'}
                nodeDescriptor=evalExprDefault(...
                node,argDescriptors,argDescriptorsOrig,type);

            case 'UMINUS'
                argType=argDescriptors{1}.type;
                if~argDescriptors{1}.isConst&&...
                    (argType.isInt||argType.isFi)&&~argType.isSigned


                    val0=argType.castValueToType(0);
                    val0Str=internal.mtree.formatConstValStr(val0);

                    argDescriptors{1}=...
                    internal.mtree.analysis.VariableDescriptor(...
                    'IS_A_CONST',argType,val0,val0Str);
                end
                nodeDescriptor=evalExprDefault(...
                node,argDescriptors,argDescriptorsOrig,type);

            case{'LT',...
                'GT',...
                'LE',...
                'GE',...
                'EQ',...
                'NE'}
                nodeDescriptor=evalExprRelOp(...
                node,argDescriptors,argDescriptorsOrig,type);

            case{'ANDAND',...
                'OROR'}

                nodeDescriptor=evalExprLogicalOp(...
                node,argDescriptors,argDescriptorsOrig,type);

            case 'ROW'
                nodeDescriptor=evalExprRow(...
                node,argDescriptors,argDescriptorsOrig,type);

            case{'CALL','LP'}
                if numel(type)==1&&type.isSystemObject
                    nodeDescriptor=evalExprSystemObject(...
                    node,argDescriptors,argDescriptorsOrig,type);
                else

                    nodeDescriptor=evalExprCall(...
                    node,argDescriptors,argDescriptorsOrig,type,...
                    numOutputs,constAnnotator);
                end

            case 'SUBSCR'
                if internal.mtree.isPragma(node)


                    nodeDescriptor=evalExprCall(...
                    node,argDescriptors,argDescriptorsOrig,type,...
                    numOutputs,constAnnotator);
                elseif type.isSystemObject

                    assert(numOutputs==1,'more than one output for a system object');
                    nodeDescriptor=evalExprSystemObject(...
                    node,argDescriptors,argDescriptorsOrig,type);
                else
                    assert(numOutputs==1,'more than one output for a non-call subscr');
                    nodeDescriptor=evalExprSubscr(...
                    node,argDescriptors,argDescriptorsOrig,type);
                end

            case 'CELL'
                nodeDescriptor=evalExprCell(...
                node,argDescriptors,argDescriptorsOrig,type,numOutputs);

            case 'DOT'
                if type.isSystemObject

                    nodeDescriptor=evalExprSystemObject(...
                    node,argDescriptors,argDescriptorsOrig,type);
                else
                    nodeDescriptor=evalExprDot(...
                    node,argDescriptors,argDescriptorsOrig,type);
                end

            case 'COLON'
                nodeDescriptor=evalExprColon(...
                node,argDescriptors,argDescriptorsOrig,type,constAnnotator);

            case{'CHARVECTOR','STRING','FIELD'}



                assert(numel(argDescriptors)==0,...
                ['No arguments possible for node ',node.kind]);
                nodeDescriptor=evalExprString(node,type);

            case{'ANON',...
                'ANONID',...
                'AT',...
                'BANG',...
                'DCALL',...
                'ID',...
                'QUEST'}


                nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
                'NOT_A_CONST',type);

            case{'EXPR',...
                'PRINT',...
                'EQUALS',...
                'ERR',...
                'GLOBAL',...
                'PERSISTENT',...
                'BREAK',...
                'CONTINUE',...
                'RETURN',...
                'IF',...
                'IFHEAD',...
                'ELSEIF',...
                'ELSE',...
                'SWITCH',...
                'CASE',...
                'OTHERWISE',...
                'WHILE',...
                'FOR',...
                'PARFOR',...
                'SPMD',...
                'TRY',...
                'FUNCTION',...
                'CLASSDEF',...
                'ATTRIBUTES',...
                'ATTR',...
                'PROPERTIES',...
                'METHODS',...
                'PROTO',...
                'EVENTS',...
                'EVENT',...
                'ENUMERATION',...
                'ATBASE',...
                'COMMENT',...
                'BLKCOM',...
                'CELLMARK'}

                nodeDescriptor=[];

            otherwise
                error(['Tried to evaluate unknown node: ',node.kind])
            end

            if~strcmp(node.kind,'FIELD')


                nodeDescriptor=rationalizeConstDescriptorType(nodeDescriptor,origTypeUnknown);
            end
        end



        function nodeDescriptor=evalExprDefault(node,argDescriptors,argDescriptorsOrig,type)
            import internal.mtree.analysis.EvalExpr.*

            [isConst,nodeDescriptor]=checkArgsForNonConstness(argDescriptors,type);
            if~isConst
                return
            end



            switch node.kind
            case{'NOT','TRANS','DOTTRANS','UMINUS','UPLUS',...
                'PLUS','MINUS','MUL','DIV','LDIV','EXP',...
                'DOTMUL','DOTDIV','DOTLDIV','DOTEXP',...
                'AND','OR','ANDAND','OROR',...
                'LT','GT','LE','GE','EQ','NE'}
                addParens=true;
            otherwise
                addParens=false;
            end

            switch node.kind
            case{'INT','DOUBLE','HEX','BINARY'}

                assert(numel(argDescriptors)==0,...
                'literals should have no arguments')
                replacements={};

            case{'NOT','TRANS','DOTTRANS','UMINUS','UPLUS','PARENS'}

                assert(numel(argDescriptors)==1,...
                'unary operators should have one argument');
                replacements=getReplacements(...
                node.Arg,argDescriptors,argDescriptorsOrig,addParens);

            case{'PLUS','MINUS','MUL','DIV','LDIV','EXP',...
                'DOTMUL','DOTDIV','DOTLDIV','DOTEXP',...
                'AND','OR','ANDAND','OROR',...
                'LT','GT','LE','GE','EQ','NE',...
                'DOTLP'}

                assert(numel(argDescriptors)==2,...
                'binary operators should have two arguments');
                replacements=getReplacements(...
                {node.Left,node.Right},argDescriptors,argDescriptorsOrig,addParens);

            case{'LB','LC'}

                assert(numel(argDescriptorsOrig)==count(node.Arg.List),...
                'incorrect number of arguments for array operator');

                replacements=getReplacements(...
                node.Arg,argDescriptors,argDescriptorsOrig,addParens);

            otherwise
                error('unknown operator for default eval case');
            end

            evalStr=node.tree2str(0,1,replacements);
            [isConst,constVal]=performEval(evalStr);

            if isConst
                nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
                'IS_A_CONST',type,constVal,evalStr);
            else
                nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
                'NOT_A_CONST',type);
            end
        end

        function nodeDescriptor=evalExprRelOp(node,argDescriptors,argDescriptorsOrig,type)
            import internal.mtree.analysis.EvalExpr.*

            islc=argDescriptors{1}.isConst;
            op1=argDescriptors{1}.constVal;

            isrc=argDescriptors{2}.isConst;
            op2=argDescriptors{2}.constVal;

            fullyLogicalExpr=argDescriptors{1}.type.isLogical&&...
            argDescriptors{2}.type.isLogical;
            kindsLR=[kinds(node.Left.Tree);kinds(node.Right.Tree)];

            isConst=false;
            val=[];

            if strcmp(node.Left.tree2str,node.Right.tree2str)&&...
                ~ismember('CALL',kindsLR)






                isConst=true;
                val=ismember(node.kind,{'EQ','LE','GE'});

            elseif isrc&&fullyLogicalExpr&&...
                ((ismember(node.kind,{'LT','GE'})&&op2==0)||...
                (ismember(node.kind,{'LE','GT'})&&op2==1))



                isConst=true;
                val=ismember(node.kind,{'LE','GE'});

            elseif islc&&fullyLogicalExpr&&...
                ((ismember(node.kind,{'LT','GE'})&&op1==1)||...
                (ismember(node.kind,{'LE','GT'})&&op1==0))



                isConst=true;
                val=ismember(node.kind,{'LE','GE'});
            end

            if isConst
                valStr=internal.mtree.formatConstValStr(val);
                nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
                'IS_A_CONST',type,val,valStr);
            else
                nodeDescriptor=evalExprDefault(node,argDescriptors,argDescriptorsOrig,type);
            end
        end

        function nodeDescriptor=evalExprLogicalOp(node,argDescriptors,argDescriptorsOrig,type)
            import internal.mtree.analysis.EvalExpr.*

            islc=argDescriptors{1}.isConst;
            op1=logical(argDescriptors{1}.constVal);

            isrc=argDescriptors{2}.isConst;
            op2=logical(argDescriptors{2}.constVal);

            isConst=false;
            val=[];

            if isrc&&...
                ((strcmp(node.kind,'ANDAND')&&op2==false)||...
                (strcmp(node.kind,'OROR')&&op2==true))



                isConst=true;
                val=op2;

            elseif islc&&...
                ((strcmp(node.kind,'ANDAND')&&op1==false)||...
                (strcmp(node.kind,'OROR')&&op1==true))



                isConst=true;
                val=op1;
            end

            if isConst
                valStr=internal.mtree.formatConstValStr(val);
                nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
                'IS_A_CONST',type,val,valStr);
            else
                nodeDescriptor=evalExprDefault(node,argDescriptors,argDescriptorsOrig,type);
            end
        end

        function nodeDescriptor=evalExprRow(node,argDescriptors,argDescriptorsOrig,type)
            import internal.mtree.analysis.EvalExpr.*

            [isConst,nodeDescriptor]=checkArgsForNonConstness(argDescriptors,type);
            if~isConst
                return;
            end

            replacements=getReplacements(node.Arg,argDescriptors,argDescriptorsOrig,false);
            evalStr=node.tree2str(0,1,replacements);





            elemVals=cell(1,numel(argDescriptors));



            scalarElemVal=[];
            numCols=int32(0);

            if isempty(argDescriptors)
                numRows=int32(0);
                trailingDims=int32([]);
            else
                firstRowType=argDescriptors{1}.type;
                numRows=firstRowType.Dimensions(1);
                trailingDims=firstRowType.Dimensions(3:end);
            end

            for ii=1:numel(argDescriptors)
                elemVals{ii}=argDescriptors{ii}.constVal;
                numCols=numCols+argDescriptors{ii}.type.Dimensions(2);

                if isempty(scalarElemVal)&&~isempty(elemVals{ii})
                    scalarElemVal=elemVals{ii}(1);
                end
            end

            switch node.trueparent.kind
            case 'LB'


                if isempty(scalarElemVal)
                    val=type.castValueToType([]);
                else

                    val=repmat(scalarElemVal,[numRows,numCols,trailingDims]);


                    firstIdx=1:numRows;
                    secondIdxStart=1;

                    trailingIdxs=cell(1,numel(trailingDims));
                    for ii=1:numel(trailingDims)
                        trailingIdxs{ii}=1:trailingDims(ii);
                    end

                    for ii=1:numel(elemVals)
                        colsInElem=size(elemVals{ii},2);
                        if colsInElem~=0

                            val(firstIdx,...
                            secondIdxStart:secondIdxStart+colsInElem-1,...
                            trailingIdxs{:})=elemVals{ii};
                        end
                        secondIdxStart=secondIdxStart+colsInElem;
                    end
                end
            case 'LC'
                val=elemVals;
            otherwise
                error(['unknown ROW parent type: ',node.trueparent.kind]);
            end

            nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
            'IS_A_CONST',type,val,evalStr);
        end

        function nodeDescriptor=evalExprCall(node,argDescriptors,argDescriptorsOrig,type,...
            numOutputs,constAnnotator)
            import internal.mtree.analysis.*
            import internal.mtree.analysis.EvalExpr.*

            fcn=node.Left.tree2str(0,1);

            assert(numel(argDescriptorsOrig)==count(node.Right.List),...
            ['incorrect number of arguments supplied for function: ',fcn]);

            nonConstantFunctions={'rand','randi','randn',...
            'nargin','nargout','narginchk','nargoutchk',...
            'inputname','mfilename'};
            likeArgFunctions={...
            'cast',...
            'eye',...
            'ones',...
            'zeros'};
            sizeBasedFunctions={...
            'iscolumn',...
            'isempty',...
            'isrow',...
            'isscalar',...
            'isvector',...
            'length',...
            'ndims',...
            'numberofelements',...
            'numel',...
            'size'};
            typeBasedFunctions={...
            'class',...
            'isa',...
            'isboolean',...
            'ischar',...
            'isdouble',...
            'isfi',...
            'isfimath',...
            'isfixed',...
            'isfloat',...
            'isinteger',...
            'islogical',...
            'isnumeric',...
            'isnumerictype',...
            'isreal',...
            'isscaleddouble',...
            'isscaledtype',...
            'isscalingbinarypoint',...
            'isscalingslopebias',...
            'isscalingunspecified',...
            'issigned',...
            'issingle',...
            'lowerbound',...
            'upperbound',...
            'lsb',...
            'realmin',...
            'realmax'};
            iterationFunctions={...
            'step'};
            noopFunctions={...
            'assert'};

            isNonConstantFunction=ismember(fcn,nonConstantFunctions);
            isLikeArgFunction=ismember(fcn,likeArgFunctions);
            isSizeBasedFcn=ismember(fcn,sizeBasedFunctions);
            isIterationFunction=ismember(fcn,iterationFunctions);
            isNoopFunction=ismember(fcn,noopFunctions);


            if(strcmp(fcn,'numerictype')||strcmp(fcn,'fimath'))&&...
                numel(argDescriptors)==1


                argType=argDescriptors{1}.type;
                isTypeBasedFcn=argType.isFi;

            elseif strcmp(fcn,'uminus')


                argType=argDescriptors{1}.type;
                isTypeBasedFcn=(argType.isInt||argType.isFi)...
                &&~argType.isSigned;

            elseif strcmp(fcn,'eps')&&numel(argDescriptors)==1

                argType=argDescriptors{1}.type;
                isTypeBasedFcn=argType.isFi;

            elseif any(strcmp(fcn,{'isinf','isnan','isfinite'}))

                argType=argDescriptors{1}.type;
                isTypeBasedFcn=~argType.isFloat;

            else
                isTypeBasedFcn=ismember(fcn,typeBasedFunctions);
            end


            if isNoopFunction


                types=internal.mtree.type.Void;

            elseif numOutputs==1

                types=type;

            else


                equalsNode=node.Parent;
                lbNode=equalsNode.Left;
                assert(strcmp(equalsNode.kind,'EQUALS')&&strcmp(lbNode.kind,'LB'),...
                'multiple outputs require a list of output variables');


                types=repmat(internal.mtree.type.UnknownType,1,numOutputs);
                idx=1;
                outVarNode=lbNode.Arg;

                while~isempty(outVarNode)
                    types(idx)=constAnnotator.getType(outVarNode);

                    outVarNode=outVarNode.Next;
                    idx=idx+1;
                end
            end

            if isNonConstantFunction
                allOutDescriptors=cell(1,numOutputs);

                for ii=1:numOutputs
                    allOutDescriptors{ii}=internal.mtree.analysis.VariableDescriptor(...
                    'NOT_A_CONST',types(ii));
                end

                nodeDescriptor=cellToNodeDescriptor(allOutDescriptors);

            elseif strcmp(fcn,'end')
                assert(numOutputs==1&&numel(argDescriptors)==0,...
                'incorrect inputs/outputs for ''end'' function');

                parentNode=node.Parent;
                idxNode=node;




                while~isempty(parentNode)&&...
                    ~ismember(parentNode.kind,{'SUBSCR','CELL'})
                    idxNode=parentNode;
                    parentNode=parentNode.trueparent;
                end

                assert(ismember(parentNode.kind,{'SUBSCR','CELL'}),...
                'colon node found under non-subscripting node');

                val=getEndValueAtIdxNode(parentNode,idxNode,constAnnotator);
                evalStr=internal.mtree.formatConstValStr(val);

                nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
                'IS_A_CONST',types,val,evalStr);

            elseif strcmp(fcn,'coder.target')
                assert(numel(argDescriptors)==1&&numOutputs==1,...
                'coder.target should have exactly 1 input and 1 output');


                [isConst,nodeDescriptor]=checkArgsForNonConstness(argDescriptors,types);
                if~isConst
                    return
                end

                if strcmp(hdlfeature('TranslateInternal'),'on')


                    constVal=argDescriptors{1}.constVal;
                    outputVal=ischar(constVal)&&strcmpi(constVal,'hdl');
                    outputValStr=internal.mtree.formatConstValStr(outputVal);

                    nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
                    'IS_A_CONST',types,outputVal,outputValStr);
                else






                    nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
                    'NOT_A_CONST',types);
                end

            else













                if isLikeArgFunction


                    likeArgIdx=0;
                    for ii=1:numel(argDescriptors)
                        desc=argDescriptors{ii};

                        if desc.isConst&&ischar(desc.constVal)&&...
                            strcmp(desc.constVal,'like')

                            likeArgIdx=ii+1;
                            break;
                        end
                    end

                    if likeArgIdx>0&&likeArgIdx<=numel(argDescriptors)



                        likeArgDesc=argDescriptors{likeArgIdx};

                        if~likeArgDesc.isConst&&likeArgDesc.type.supportsExampleValues
                            argDescriptors{likeArgIdx}=internal.mtree.analysis.VariableDescriptor(...
                            'IS_A_CONST',...
                            likeArgDesc.type,...
                            likeArgDesc.type.getExampleValue,...
                            likeArgDesc.type.getExampleValueString);



                            replaceString=true;
                        else
                            replaceString=false;
                        end
                    else
                        replaceString=false;
                    end

                elseif isSizeBasedFcn&&numel(argDescriptors)>=1



                    firstArgDesc=argDescriptors{1};

                    if~firstArgDesc.isConst&&~firstArgDesc.type.isSizeDynamic
                        newFirstVal=ones(firstArgDesc.type.Dimensions);

                        argDescriptors{1}=internal.mtree.analysis.VariableDescriptor(...
                        'IS_A_CONST',...
                        internal.mtree.Type.fromValue(newFirstVal),...
                        newFirstVal,...
                        ['ones(',mat2str(firstArgDesc.type.Dimensions),')']);



                        replaceString=true;
                    else
                        replaceString=false;
                    end

                elseif isTypeBasedFcn&&numel(argDescriptors)>=1


                    firstArgDesc=argDescriptors{1};
                    firstArgType=firstArgDesc.type;

                    if~firstArgDesc.isConst&&firstArgType.supportsExampleValues
                        argDescriptors{1}=internal.mtree.analysis.VariableDescriptor(...
                        'IS_A_CONST',...
                        firstArgType,...
                        firstArgType.getExampleValue,...
                        firstArgType.getExampleValueString);



                        replaceString=true;
                    else
                        replaceString=false;
                    end

                elseif isIterationFunction&&numel(argDescriptors)>=1


                    firstArgDesc=argDescriptors{1};
                    firstArgType=firstArgDesc.type;

                    replaceString=false;

                    if firstArgType.isSystemObject&&~firstArgDesc.isIndeterminate
                        argDescriptors{1}=internal.mtree.analysis.VariableDescriptor(...
                        'NOT_A_CONST',firstArgType);
                    end
                else


                    replaceString=false;
                end


                [isConst,nodeDescriptor]=checkArgsForNonConstness(argDescriptors,types);
                if~isConst
                    return
                end

                replacements=getReplacements(...
                node.Right,argDescriptors,argDescriptorsOrig,false);

                evalStr=node.tree2str(0,1,replacements);
                [isConst,valsCell]=performMultiOutEval(evalStr,numOutputs);

                allOutDescriptors=cell(1,numOutputs);

                if isConst
                    for ii=1:numOutputs
                        if replaceString||numOutputs>1








                            valStr=internal.mtree.formatConstValStr(valsCell{ii});
                        else
                            valStr=evalStr;
                        end

                        allOutDescriptors{ii}=internal.mtree.analysis.VariableDescriptor(...
                        'IS_A_CONST',types(ii),valsCell{ii},valStr);
                    end
                else
                    for ii=1:numOutputs
                        allOutDescriptors{ii}=internal.mtree.analysis.VariableDescriptor(...
                        'NOT_A_CONST',types(ii));
                    end
                end

                nodeDescriptor=cellToNodeDescriptor(allOutDescriptors);
            end
        end

        function nodeDescriptor=evalExprSubscr(node,argDescriptors,argDescriptorsOrig,type)
            import internal.mtree.analysis.EvalExpr.*
            import internal.mtree.analysis.cellToNodeDescriptor

            assert(strcmp(node.kind,'SUBSCR'),...
            ['unexpected node kind found in subscr eval: ',node.kind]);

            [isConst,nodeDescriptor]=checkArgsForNonConstness(argDescriptors,type);
            if~isConst
                isLogicalIndexing=numel(argDescriptors)==2&&...
                argDescriptors{2}.type.isLogical;

                if type.isSizeDynamic&&~isLogicalIndexing


                    if numel(argDescriptors)>2
                        actualSize=zeros(numel(argDescriptors)-1,1);
                        for ii=1:numel(argDescriptors)-1
                            actualSize(ii)=prod(argDescriptors{ii+1}.type.Dimensions);
                        end
                    else
                        actualSize=argDescriptors{2}.type.Dimensions;
                    end

                    newType=nodeDescriptor.type.copy;
                    newType.setDimensions(actualSize);
                    nodeDescriptor.type=newType;
                end

                return;
            end




            mat=argDescriptors{1}.constVal;
            idxStr=getCommaSeparatedIdxStrs(node,argDescriptors,argDescriptorsOrig);

            [isConst,val]=performSubscrEval(mat,['(',idxStr,')']);

            if isConst
                evalStr=internal.mtree.formatConstValStr(val);

                nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
                'IS_A_CONST',type,val,evalStr);
            else
                nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
                'NOT_A_CONST',type);
            end
        end

        function nodeDescriptor=evalExprCell(node,argDescriptors,argDescriptorsOrig,type,numOutputs)
            import internal.mtree.analysis.EvalExpr.*
            import internal.mtree.analysis.cellToNodeDescriptor

            assert(strcmp(node.kind,'CELL'),...
            ['unexpected node kind found in cell eval: ',node.kind]);
            assert(numel(argDescriptors)>1,'not enough argDescriptors for a CELL node');

            if numOutputs==1

                types=type;
            else

                types=repmat(internal.mtree.type.UnknownType,1,numOutputs);
            end



            [isConst,nodeDescriptor]=checkArgsForNonConstness(argDescriptors(2:end),types);
            if~isConst
                return;
            end

            idxStr=getCommaSeparatedIdxStrs(node,argDescriptors,argDescriptorsOrig);

            if argDescriptors{1}.isListDesc




                [isConst,outDescs]=performSubscrEval(...
                argDescriptors{1}.descriptors,['(',idxStr,')']);
            else


                [isConst,nodeDescriptor]=checkArgsForNonConstness(argDescriptors(1),types);
                if~isConst
                    return;
                end

                cellArr=argDescriptors{1}.constVal;
                assert(iscell(cellArr),'non-cell constant found in CELL node');
                [isConst,outVals]=performSubscrEval(cellArr,['(',idxStr,')']);

                if isConst
                    assert(numel(outVals)==numOutputs);
                    outDescs=cell(1,numOutputs);

                    for i=1:numOutputs
                        val=outVals{i};
                        outDescs{i}=internal.mtree.analysis.VariableDescriptor(...
                        'IS_A_CONST',...
                        internal.mtree.Type.fromValue(val),...
                        val,...
                        internal.mtree.formatConstValStr(val));
                    end
                end
            end



            if~isConst



                outDescs=cell(1,numOutputs);

                for i=1:numOutputs
                    outDescs{i}=internal.mtree.analysis.VariableDescriptor(...
                    'NOT_A_CONST',types(i));
                end
            end


            assert(numel(outDescs)==numOutputs);

            nodeDescriptor=cellToNodeDescriptor(outDescs);
        end

        function nodeDescriptor=evalExprDot(~,argDescriptors,argDescriptorsOrig,type)
            import internal.mtree.analysis.EvalExpr.*

            assert(numel(argDescriptors)==2&&numel(argDescriptorsOrig)==2,...
            'DOT node should have 2 arguments');







            firstType=argDescriptors{1}.type;
            if firstType.isFi


                [isConst,nodeDescriptor]=checkArgsForNonConstness(argDescriptors(2),type);
                if~isConst
                    return;
                end

                structVal=firstType.getExampleValue;
                fieldVal=argDescriptors{2}.constVal;
            else


                [isConst,nodeDescriptor]=checkArgsForNonConstness(argDescriptors,type);
                if~isConst
                    return
                end

                structVal=argDescriptors{1}.constVal;
                fieldVal=argDescriptors{2}.constVal;
            end

            try
                value=structVal.(fieldVal);
                evalStr=internal.mtree.formatConstValStr(value);
            catch
                isConst=false;
            end

            if isConst
                nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
                'IS_A_CONST',type,value,evalStr);
            else
                nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
                'NOT_A_CONST',type);
            end
        end

        function nodeDescriptor=evalExprColon(node,argDescriptors,argDescriptorsOrig,...
            type,constAnnotator)
            import internal.mtree.analysis.EvalExpr.*

            if isempty(argDescriptors)
                if ismember(node.trueparent.kind,{'SUBSCR','CELL'})
                    valLimit=getEndValueAtIdxNode(node.trueparent,node,constAnnotator);

                    val=(1:valLimit)';
                    nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
                    'IS_A_CONST',type,val,sprintf('(1:%d)''',valLimit));
                else
                    nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
                    'NOT_A_CONST',type);
                end
            else

                if numel(argDescriptors)==2

                    argNodes={node.Left,node.Right};
                    replacements=getReplacements(...
                    argNodes,argDescriptors,argDescriptorsOrig,false);

                elseif numel(argDescriptors)==3

                    argNodes={node.Left.Left,node.Left.Right,node.Right};
                    replacements=getReplacements(...
                    argNodes,argDescriptors,argDescriptorsOrig,false);
                else

                    error('A colon node should have 0, 2, or 3 arguments');
                end

                evalStr=node.tree2str(0,1,replacements);
                [isConst,val]=performEval(evalStr);

                if isConst
                    nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
                    'IS_A_CONST',type,val,evalStr);
                else
                    nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
                    'NOT_A_CONST',type);
                end
            end
        end

        function nodeDescriptor=evalExprString(node,type)
            import internal.mtree.analysis.EvalExpr.*

            evalStr=node.string;

            if strcmp(node.kind,'CHARVECTOR')&&~startsWith(evalStr,'''')


                evalStr=['''',strrep(evalStr,'''''',''),''''];
            elseif strcmp(node.kind,'FIELD')


                evalStr=['''',evalStr,''''];
            end

            [isConst,val]=performEval(evalStr);

            if isConst
                nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
                'IS_A_CONST',type,val,evalStr);
            else
                nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
                'NOT_A_CONST',type);
            end
        end

        function nodeDescriptor=evalExprSystemObject(node,argDescriptors,~,type)




            import internal.mtree.analysis.EvalExpr.*



            switch node.kind
            case 'DOT'

                evalStr=node.tree2str;
                [isConst,val]=performEval(evalStr);
            case 'SUBSCR'
                argIdxBegin=2;
                [isConst,val,evalStr]=evalExprSystemObjectWithArguments(node,argDescriptors,argIdxBegin);
            case 'CALL'
                argIdxBegin=1;
                [isConst,val,evalStr]=evalExprSystemObjectWithArguments(node,argDescriptors,argIdxBegin);
            case 'CELL'


                isConst=false;
            otherwise
                error('unexpected evaluation of node kind for system object');
            end

            if isConst
                nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
                'IS_A_CONST',type,val,evalStr);
            else
                nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
                'NOT_A_CONST',type);
            end

        end

        function[isConst,val,evalStr]=evalExprSystemObjectWithArguments(node,argDescriptors,argIdxBegin)
            import internal.mtree.analysis.EvalExpr.*


            evalStr=getExampleConstantCallEvalStr(node,argDescriptors,argIdxBegin);

            [isConst,val]=performEval(evalStr);
        end

        function evalStr=getExampleConstantCallEvalStr(node,argDescriptors,argIdxBegin)

            if nargin<3
                argIdxBegin=1;
            end

            evalStr=node.Left.tree2str;

            for ii=argIdxBegin:numel(argDescriptors)
                if ii==argIdxBegin

                    evalStr=strcat(evalStr,'(');
                end

                if argDescriptors{ii}.isConst

                    argStr=argDescriptors{ii}.evaluateableString;
                elseif~argDescriptors{ii}.type.supportsExampleValues


                    evalStr='[]';
                    break;
                else


                    argStr=argDescriptors{ii}.type.getExampleValueString;
                end
                evalStr=strcat(evalStr,argStr);
                if ii~=numel(argDescriptors)

                    evalStr=strcat(evalStr,',');
                else

                    evalStr=strcat(evalStr,')');
                end
            end
        end

        function type=resolveUnknownType(node,argDescriptors,constAnnotator)



            import internal.mtree.analysis.EvalExpr.*

            type=internal.mtree.type.UnknownType;
            switch node.kind
            case{'ANDAND','OROR','NOT','EQ','NE','LT','LE','GT','GE'}
                type=internal.mtree.Type.makeType('logical',[1,1]);

            case{'AND','OR'}
                lhsDim=argDescriptors{1}.type.Dimensions;
                rhsDim=argDescriptors{2}.type.Dimensions;
                if prod(lhsDim)>prod(rhsDim)
                    dim=lhsDim;
                else
                    dim=rhsDim;
                end

                type=internal.mtree.Type.makeType('logical',dim);

            case{'INT','DOUBLE'}

                type=internal.mtree.Type.makeType('double',[1,1]);

            case{'PARENS'}
                type=argDescriptors{1}.type.copy;

            case{'ROW'}
                if strcmp(node.trueparent.kind,'LC')



                    type=internal.mtree.type.UnknownType('cell',...
                    [1,numel(argDescriptors)]);

                else



                    if numel(argDescriptors)==0

                        return
                    end

                    type=argDescriptors{1}.type.copy;
                    if type.isUnknown


                        return
                    end


                    dims=type.Dimensions;
                    for ii=2:numel(argDescriptors)
                        dims(2)=dims(2)+argDescriptors{ii}.type.Dimensions(2);
                    end
                    type.setDimensions(dims);
                end

            case{'CALL'}
                arg=node.Right;
                if~isempty(arg)




                    callName=node.Left.tree2str;
                    argType=argDescriptors{1}.type.copy;
                    if~argType.isChar&&strcmp(callName,argType.getMLName)




                        type=argType;
                    elseif strcmp(callName,'real')&&~argType.isComplex


                        type=argType;
                    elseif strcmp(callName,'fi')


                        type=argType;
                    elseif strcmp(callName,'cast')


                        type=argType;
                    elseif~argType.isUnknown&&~strcmp(callName,'struct')




                        potentialType=internal.mtree.Type.makeType(callName,argType.Dimensions,argType.isComplex);
                        if~potentialType.isUnknown
                            type=potentialType;
                        end
                    end
                end
            case{'DOT'}




                if argDescriptors{1}.type.isStructType&&argDescriptors{2}.isConst&&strcmp(node.Right.kind,'FIELD')
                    type=argDescriptors{1}.type.fields.(argDescriptors{2}.constVal);
                else

                    type=checkParentTyping(node);
                end
            case{'FIELD'}



                if~isempty(node.trueparent)
                    type=constAnnotator.getType(node.trueparent);
                end
            case{'SUBSCR'}
                if internal.mtree.isPragma(node)


                    evalStr=getExampleConstantCallEvalStr(node,argDescriptors);

                    [isConst,val]=performEval(evalStr);
                    if isConst
                        type=internal.mtree.Type.fromValue(val);
                    end
                    return
                end


                type=checkParentTyping(node);
                if type.isSystemObject
                    return
                end



                type=argDescriptors{1}.type.copy;


                indexDescriptors=argDescriptors(2:end);
                numIndex=numel(indexDescriptors);
                if numIndex==1

                    type.setDimensions(indexDescriptors{1}.type.Dimensions);
                else

                    dims=type.Dimensions;
                    for ii=1:numIndex
                        dims(ii)=prod(indexDescriptors{ii}.type.Dimensions);
                    end
                    type.setDimensions(dims);
                end
            case{'CELL'}

                if numel(argDescriptors)>=2&&argDescriptors{1}.isListDesc


                    idxStrs=cell(1,numel(argDescriptors)-1);
                    for ii=2:numel(argDescriptors)
                        if~argDescriptors{ii}.isConst
                            return
                        end
                        idxStrs{ii-1}=argDescriptors{ii}.evaluateableString;
                    end



                    try
                        outDescs=cell(0);
                        idxFullStr=strjoin(idxStrs,',');
                        evalc(['outDescs = argDescriptors{1}.descriptors(',idxFullStr,')']);

                        if numel(outDescs)==1
                            type=outDescs{1}.type.copy;
                        end
                    catch
                        return
                    end
                end
            case{'LB'}



                if numel(argDescriptors)==1
                    type=argDescriptors{1}.type.copy;
                else

                    type=checkParentTyping(node);
                end
            case{'TRANS','DOTTRANS'}


                if numel(argDescriptors)==1&&argDescriptors{1}.type.isScalar
                    type=argDescriptors{1}.type.copy;
                else

                    type=checkParentTyping(node);
                end
            case{'DOTMUL'}

                if numel(argDescriptors)==2
                    lhsType=argDescriptors{1}.type;
                    rhsType=argDescriptors{2}.type;

                    if lhsType.supportsExampleValues&&rhsType.supportsExampleValues
                        exOutVal=lhsType.getExampleValue.*rhsType.getExampleValue;
                        type=internal.mtree.Type.fromValue(exOutVal);
                    else
                        type=checkParentTyping(node);
                    end
                else
                    type=checkParentTyping(node);
                end
            otherwise




                type=checkParentTyping(node);
            end

            function type=checkParentTyping(node)
                type=internal.mtree.type.UnknownType;
                parentNode=node.trueparent;
                if strcmp(parentNode.kind,'EQUALS')


                    type=constAnnotator.getType(parentNode);
                    if type.isUnknown


                        type=constAnnotator.getType(parentNode.Left);
                    end
                elseif strcmp(parentNode.kind,'ROW')&&strcmp(parentNode.Parent.kind,'LB')



                    type=constAnnotator.getType(parentNode.Parent);
                end
            end
        end





        function nodeDescriptor=rationalizeConstDescriptorType(nodeDescriptor,origTypeUnknown)
            import internal.mtree.analysis.EvalExpr.*

            if isa(nodeDescriptor,'internal.mtree.analysis.NodeDescriptor')
                for i=1:numel(nodeDescriptor.getLength)
                    varDesc=nodeDescriptor.getVarDesc(i);
                    rationalizedDesc=rationalizeConstDescriptorType(varDesc,origTypeUnknown);
                    nodeDescriptor.setVarDesc(rationalizedDesc,i);
                end
            elseif nodeDescriptor.isConst
                type=nodeDescriptor.type;
                valType=internal.mtree.Type.fromValue(nodeDescriptor.constVal);

                if type.isUnknown||origTypeUnknown
                    nodeDescriptor.type=valType;
                else


                    nodeDescriptor.type.setDimensions(valType.Dimensions);

                    if~isTypeEqual(type,valType)


                        if isa(nodeDescriptor.constVal,'struct')&&...
                            isequal(nodeDescriptor.constVal,struct)



                            if type.supportsExampleValues
                                nodeDescriptor.constVal=type.getExampleValue;
                            else



                                nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
                                'NOT_A_CONST',type);
                            end
                        else
                            nodeDescriptor.constVal=type.castValueToType(nodeDescriptor.constVal);
                        end
                    end
                end
            end
        end

        function[isConst,nodeDescriptor]=checkArgsForNonConstness(argDescriptors,types)
            import internal.mtree.analysis.cellToNodeDescriptor

            nonConst=false;
            indeterminate=false;

            for ii=1:numel(argDescriptors)
                if argDescriptors{ii}.isIndeterminate
                    indeterminate=true;
                    break
                elseif~argDescriptors{ii}.isConst
                    nonConst=true;
                end
            end

            if indeterminate
                isConst=false;
                constnessStr='INDETERMINABLE_IF_CONST';
            elseif nonConst
                isConst=false;
                constnessStr='NOT_A_CONST';
            else
                isConst=true;
            end

            if~isConst
                allDescriptors=cell(1,numel(types));

                for ii=1:numel(types)
                    allDescriptors{ii}=internal.mtree.analysis.VariableDescriptor(...
                    constnessStr,types(ii));
                end

                nodeDescriptor=cellToNodeDescriptor(allDescriptors);
            else
                nodeDescriptor=[];
            end
        end


















        function replacements=getReplacements(nodes,descriptors,descriptorsOrig,addParens)
            numReplacements=numel(descriptorsOrig);
            replacements=cell(1,2*numReplacements);



            if iscell(nodes)
                assert(numel(nodes)==numel(descriptorsOrig),...
                'number of args and arg descriptors do not match');

                for ii=1:numReplacements
                    replIdx=2*(ii-1)+1;
                    replacements{replIdx}=nodes{ii};
                end
            else
                assert(count(nodes.List)==numel(descriptorsOrig),...
                'number of arg descriptors and args in list do not match');

                arg=nodes;
                for ii=1:numReplacements
                    replIdx=2*(ii-1)+1;
                    replacements{replIdx}=arg;
                    arg=arg.Next;
                end
            end


            if addParens
                prefix='(';
                suffix=')';
            else
                prefix='';
                suffix='';
            end

            descIdx=1;

            for ii=1:numReplacements
                origDesc=descriptorsOrig{ii};

                if origDesc.isNodeDesc
                    replStrCell=cell(1,origDesc.getLength);

                    for jj=1:origDesc.getLength
                        replStrCell{jj}=[prefix,descriptors{descIdx}.evaluateableString,suffix];
                        descIdx=descIdx+1;
                    end

                    replStr=strjoin(replStrCell,', ');
                else
                    replStr=[prefix,descriptors{descIdx}.evaluateableString,suffix];
                    descIdx=descIdx+1;
                end

                replIdx=2*(ii-1)+2;
                replacements{replIdx}=replStr;
            end
        end
















        function idxStr=getCommaSeparatedIdxStrs(node,argDescriptors,argDescriptorsOrig)
            assert(numel(argDescriptors)>1&&numel(argDescriptorsOrig)>1&&...
            ~argDescriptorsOrig{1}.isNodeDesc);

            idxStrCell=cell(1,numel(argDescriptors)-1);
            idxStrCellIdx=1;

            idxNode=node.Right;
            for ii=2:numel(argDescriptorsOrig)
                origDesc=argDescriptorsOrig{ii};

                if origDesc.isNodeDesc




                    for jj=1:origDesc.getLength
                        idxStrCell{idxStrCellIdx}=argDescriptors{idxStrCellIdx+1}.evaluateableString;
                        idxStrCellIdx=idxStrCellIdx+1;
                    end

                else



                    if strcmp(idxNode.kind,'COLON')&&...
                        isempty(idxNode.Right)&&isempty(idxNode.Left)
                        idxStrCell{idxStrCellIdx}=':';
                    else
                        idxStrCell{idxStrCellIdx}=argDescriptors{idxStrCellIdx+1}.evaluateableString;
                    end

                    idxStrCellIdx=idxStrCellIdx+1;
                end

                idxNode=idxNode.Next;
            end

            idxStr=strjoin(idxStrCell,', ');
        end

        function[isConst,val]=performEval(evalStr)
            try
                [~,val]=evalc(evalStr);

                isConst=true;
            catch
                val=[];
                isConst=false;
            end
        end

        function[isConst,val]=performSubscrEval(mat,allIdxStrs)%#ok<INUSL>
            try
                [~,val]=evalc(sprintf('mat%s',allIdxStrs));

                isConst=true;
            catch
                val=[];
                isConst=false;
            end
        end

        function[isConst,valCell]=performMultiOutEval(evalStr,numOut)
            valCell=cell(1,numOut);

            try
                [~,valCell{:}]=evalc(evalStr);

                isConst=true;
            catch
                valCell=[];
                isConst=false;
            end
        end

        function endVal=getEndValueAtIdxNode(subscrNode,idxNode,constAnnotator)

            matType=constAnnotator.getType(subscrNode.Left);
            matDims=matType.Dimensions;


            if count(subscrNode.Right.List)==1

                endVal=prod(matDims);
            else

                idx=1;
                node=subscrNode.Right;
                while~isequal(idxNode,node)&&~isempty(node)
                    idx=idx+1;
                    node=node.Next;
                end

                if idx>numel(matDims)
                    endVal=1;
                else
                    endVal=matDims(idx);
                end
            end
        end
    end

end





