function expression=toExpression(v,varargin)






    p=matlab.system.internal.getToExpressionInputParser;
    p.parse(varargin{:});
    doSplit=p.Results.Split;

    if matlab.system.isSystemObject(v)
        expression=v.toConstructorExpression(varargin{:});

    elseif isa(v,'embedded.numerictype')
        expression=v.tostring();

    elseif isa(v,'embedded.fi')
        ntStr=tostring(numerictype(v));
        hexStr=reduceZerosInHex(v.hex);
        expression=sprintf('fi(''numerictype'',%s,''hex'',%s)',...
        ntStr,mat2str(hexStr));

    elseif isobject(v)
        expression=class(v);

    elseif isstruct(v)
        validateattributes(v,{'struct'},{'scalar'},'matlab.system.internal.toExpression');


        if doSplit
            delim=[', ...',sprintf('\n')];
        else
            delim=',';
        end

        fvPairs='';
        fieldNames=fieldnames(v);
        numFields=numel(fieldNames);
        for k=1:numFields
            fieldName=fieldNames{k};
            fieldExpr=matlab.system.internal.toExpression(v.(fieldName),'Split',doSplit,'IncludeHidden',p.Results.IncludeHidden);
            fvPairs=[fvPairs,'''',fieldName,''',',fieldExpr];%#ok<*AGROW>
            if k<numFields
                fvPairs=[fvPairs,delim];
            end
        end
        expression=['struct(',fvPairs,')'];

    elseif iscell(v)
        validateattributes(v,{'cell'},{'2d'},'matlab.system.internal.toExpression');

        [nRows,nCols]=size(v);
        if nRows==0||nCols==0
            if(nRows==0&&nCols==0)
                expression='{}';
            else
                expression=['cell(',num2str(nRows),',',num2str(nCols),')'];
            end
            return;
        end

        cells='';
        for row=1:nRows
            for col=1:nCols
                cells=[cells,matlab.system.internal.toExpression(v{row,col},'Split',doSplit,'IncludeHidden',p.Results.IncludeHidden)];
                if col<nCols
                    cells=[cells,','];
                end
            end
            if row<nRows
                cells=[cells,'; '];
            end
        end
        expression=['{',cells,'}'];

    elseif isa(v,'function_handle')
        expression=func2str(v);


        if~isempty(expression)&&~strcmpi(expression(1),'@')
            expression=['@',expression];
        end

    elseif ischar(v)
        expression=mat2str(v);

    elseif islogical(v)||isnumeric(v)
        validateattributes(v,{'numeric','logical'},{},'matlab.system.internal.toExpression');


        v_size=size(v);
        if length(v_size)~=2
            v_size_expression=toCompressedNumericExpression(v_size);
            v=reshape(v,[1,prod(v_size)]);
        end


        if isreal(v)
            expression=toCompressedNumericExpression(v);
        else
            reV=real(v);
            isarr=~isempty(reV)&&~isscalar(reV);
            [realExpression,isConstRe]=toCompressedNumericExpression(reV);
            [imagExpression,isConstIm]=toCompressedNumericExpression(imag(v));



            if isarr&&isConstIm
                imagExpression=toCompressedNumericExpression(imag(v(1)));
            elseif isarr&&isConstRe
                realExpression=toCompressedNumericExpression(real(v(1)));
            end

            expression=sprintf('complex(%s,%s)',realExpression,imagExpression);
        end

        if length(v_size)~=2

            expression=sprintf('reshape(%s,%s)',expression,v_size_expression);
        end

        if doSplit
            expression=mat2strSplitter(expression,60);
        end

    elseif isa(v,'flow.utils.ArgDataType')



        expression=synthesizeExprChar(v);

    else
        expression=class(v);
    end
end

function[expression,isConst]=toCompressedNumericExpression(v)



    isConst=false;
    defaultExpression=toGeneralArrayExpression(v);





    try %#ok<TRYNC>
        constExpression=toConstantArrayExpression(v);
        if~isempty(constExpression)&&(length(constExpression)<length(defaultExpression))&&isequal(v,eval(constExpression))
            expression=constExpression;
            isConst=true;
            return;
        end

        colonExpression=toColonArrayExpression(v);
        if~isempty(colonExpression)&&(length(colonExpression)<length(defaultExpression))&&isequal(v,eval(colonExpression))
            expression=colonExpression;
            return;
        end
    end

    expression=defaultExpression;
end

function expression=toConstantArrayExpression(v)


    if isscalar(v)
        if isa(v,'double')
            expression=toCompressedScalarExpression(v);
        elseif islogical(v)
            if v
                expression='true';
            else
                expression='false';
            end
        else

            expression=sprintf('%s(%s)',class(v),toCompressedScalarExpression(double(v)));
        end
    else
        constV=isConstantArray(v);
        if isempty(constV)
            expression='';
        else
            dims=mat2str(size(v));
            if isa(constV,'double')
                if constV==0
                    expression=sprintf('zeros(%s)',dims);
                elseif constV==1
                    expression=sprintf('ones(%s)',dims);
                else
                    expression=sprintf('%s*ones(%s)',toCompressedScalarExpression(constV),dims);
                end
            elseif islogical(constV)
                if constV
                    expression=sprintf('true(%s)',dims);
                else
                    expression=sprintf('false(%s)',dims);
                end
            else

                if constV==0
                    expression=sprintf('zeros(%s,''%s'')',dims,class(v));
                elseif constV==1
                    expression=sprintf('ones(%s,''%s'')',dims,class(v));
                else




                    expression=sprintf('%s*ones(%s,''%s'')',toCompressedScalarExpression(constV),dims,class(v));
                end
            end
        end
    end
end

function x1=isConstantArray(x)




    numelOfX=numel(x);
    if numelOfX>1
        x1=x(1);
        for k=1:numelOfX
            if x1~=x(k)
                x1=[];
                return;
            end
        end
    else
        x1=[];
    end
end

function expression=toColonArrayExpression(v)



    if isnumeric(v)&&~isa(v,'double')
        expression=toColonArrayExpression(double(v));
        if~isempty(expression)
            expression=sprintf('%s(%s)',class(v),expression);
            return;
        end
    end

    expression='';
    if numel(v)>3



        cStart=[];
        cStep=[];
        cEnd=[];
        if isnumeric(v)&&isvector(v)&&isreal(v)
            d=diff(double(v));
            cStep=isConstantArray(d);
            if~isempty(cStep)&&cStep>0
                cStart=v(1);
                cEnd=v(end);
            end
        end


        if isempty(cStart)
            return;
        end

        startStr=toConstantArrayExpression(cStart);
        if cStep==1
            endStr=toConstantArrayExpression(cEnd);
            expression=sprintf('%s:%s',startStr,endStr);
        else
            skipStr=toConstantArrayExpression(cStep);
            endStr=toConstantArrayExpression(cEnd);
            expression=sprintf('%s:%s:%s',startStr,skipStr,endStr);
        end
        if iscolumn(v)


            expression=sprintf('(%s).''',expression);
        end
    end
end

function s=toGeneralArrayExpression(v)


    if isa(v,'double')||islogical(v)
        s=mat2str(v);
    else
        s=mat2str(v,'class');
    end





    if~isequal(v,eval(s))
        if isa(v,'double')||islogical(v)
            s=mat2str(v,17);
        else
            s=mat2str(v,17,'class');
        end
    end
end

function expression=toCompressedScalarExpression(v)




    assert(isscalar(v));
    if isreal(v)



        if v==0
            expression='0';
            return;
        elseif isinf(v)
            expression=mat2str(v);
            return;
        end


        m=v/pi;
        if(m==fix(m))&&(m>0)
            if m==1
                expression='pi';
            else
                expression=sprintf('%d*pi',m);
            end
            return
        end
        m=pi/v;
        if(m==fix(m))&&(m>0)
            expression=sprintf('pi/%d',m);
            return
        end


        m=log2(v);
        if(m==fix(m))&&(m>9)
            expression=sprintf('(2.^%d)',m);
            return
        end


        if v==sqrt(2)
            expression='sqrt(2)';
        elseif v==sqrt(3)
            expression='sqrt(3)';
        elseif v==1/sqrt(2)
            expression='1/sqrt(2)';
        elseif v==exp(1)
            expression='exp(1)';
        else
            expression=mat2str(v);
        end
    else

        sRe=toCompressedScalarExpression(real(v));
        sIm=toCompressedScalarExpression(imag(v));

        expression=sprintf('complex(%s,%s)',sRe,sIm);
    end
end

function hexIn=reduceZerosInHex(hexIn)


    N=numel(hexIn);

    removeZeros=false(N,1);
    zstart=0;

    inZeroStream=false;
    readyForNewStream=true;

    for i=1:N
        ci=hexIn(i);
        if isspace(ci)
            if inZeroStream






                zend=i-2;
                if zend>zstart
                    removeZeros(zstart:zend)=true;
                end
                inZeroStream=false;
                readyForNewStream=true;
            end
        else
            if ci=='0'
                if readyForNewStream&&~inZeroStream
                    inZeroStream=true;
                    readyForNewStream=false;
                    zstart=i;
                end
            else

                if inZeroStream



                    zend=i-1;
                    if zend>zstart
                        removeZeros(zstart:zend)=true;
                    end
                    inZeroStream=false;

                end
            end
        end
    end
    if inZeroStream
        zend=N-1;
        if zend>zstart
            removeZeros(zstart:zend)=true;
        end
    end


    hexIn(removeZeros)='';
end

function expression=mat2strSplitter(expression,NumCharsPerLine)










    if nargin<2
        NumCharsPerLine=60;
    end
    totalChars=numel(expression);
    if totalChars<=NumCharsPerLine
        return
    end











    splitStr=sprintf(' ...\n');


    s2='';








    chunkStart=1;
    chunkEnd=NumCharsPerLine;




    searchStart=chunkStart;
    searchEnd=chunkEnd;
    while chunkEnd<=totalChars



        tmp=expression(searchStart:searchEnd);


        idx1=find(tmp==';',1,'last');
        idx2=find(tmp==' ',1,'last');
        if isempty(idx1)
            if isempty(idx2)
                idx=[];
            else
                idx=idx2;
            end
        elseif isempty(idx2)
            idx=idx1;
        else
            idx=max(idx1,idx2);
        end
        if isempty(idx)



            searchStart=searchEnd+1;
            searchEnd=searchStart+NumCharsPerLine;
            chunkEnd=searchEnd;
            continue
        end



        copyStart=chunkStart;
        copyEnd=searchStart+idx-1;
        s2=[s2,expression(copyStart:copyEnd),splitStr];






        if copyEnd==chunkEnd

            chunkStart=chunkEnd+1;
            chunkEnd=chunkStart+NumCharsPerLine-1;
            searchStart=chunkStart;
            searchEnd=chunkEnd;
        else

            carryfwdStart=copyEnd+1;
            carryfwdEnd=chunkEnd;

            chunkStart=carryfwdStart;
            searchStart=carryfwdEnd+1;

            chunkEnd=chunkStart+NumCharsPerLine-1;
            searchEnd=chunkEnd;
        end
    end

    if copyEnd<totalChars
        s2=[s2,expression(copyEnd+1:end)];
    end
    expression=s2;
end
