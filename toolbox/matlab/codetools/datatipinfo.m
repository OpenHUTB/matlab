function datatipinfo(varName)





    if nargin~=1
        return;
    end



    varName=convertStringsToChars(varName);

    origFormat=get(0,'FormatSpacing');
    c=onCleanup(@()format(origFormat));
    format loose;










    variableExistsInWorkspace=evalin('caller',['exist(''',varName,''')']);

    if variableExistsInWorkspace~=1
        structOrObjectName=DataTipUtilities.getStructOrClassName(varName);
        variableExistsInWorkspace=evalin('caller',['exist(''',structOrObjectName,''')']);

        if variableExistsInWorkspace~=1
            return;
        end






        [objectPart,methodOrProperty]=DataTipUtilities.getVariableNameParts(varName);
        if evalin('caller',['ismethod(',objectPart,', ''',methodOrProperty,''')'])
            return;
        end
    end

    try
        val=evalin('caller',varName);
    catch
        return;
    end
    name=varName;

    if istall(val)



        callDisplay('val');
    elseif isstruct(val)


        displayStr=evalcWithHotlinksOff('display(val)');
        pat='\s*val\s*=\s*([^\n]*)\n+';
        rep=[name,': $1\n'];
        if isscalar(val)&&numel(fieldnames(val))>0
            pat='\s*val\s*=\s*\n+';
            rep=[name,':\n'];
        end
        disp(regexprep(displayStr,pat,rep,'once'));
    elseif isempty(val)
        callDisp('sizeType');
    elseif isa(size(val),'java.awt.Dimension')


        callDisp('[sizeType '' ='']');
        callDisp('val');
    else






        s=size(val);
        tooBig=max(s)>500||numel(val)>500;



        isBigMatrix=~ismatrix(val)||tooBig&&s(1)~=1&&s(2)~=1;
        if isBigMatrix
            callDisp('sizeType');
        else
            callDisp('[sizeType '' ='']');

            isString=isstring(val);
            isNotObjectExceptString=~isobject(val)||isString;
            isBigRowOrColumnMatrix=isNotObjectExceptString&&...
            ~issparse(val)&&tooBig;



            if isBigRowOrColumnMatrix
                val=val(1:500);
            end



            isBigVectorTable=tooBig&&istable(val)&&isvector(val);
            if isBigVectorTable
                if s(1)==1
                    val=val(1,1:500);
                elseif s(2)==1
                    val=val(1:500,1);
                end
            end



            if ischar(val)&&s(1)==1
                while~isempty(regexp(val,'[^\b]\b','once'))

                    val=regexprep(val,'[^\b]\b','');
                end


                val=regexprep(val,'\r','\n');
            end



            isScalarString=isString&&isscalar(val);
            if isScalarString
                tooBigString=strlength(val)>500;
                if tooBigString
                    val{1}=val{1}(1:500);
                end



                val='     "'+val+'"';
            end

            callDisp('val');
        end
    end

    function prefix=sizeType %#ok<DEFNU> All uses are in EVALC calls.



        header=matlab.internal.editor.VariableUtilities.getHeader(val);

        if isempty(header)
            s=size(val);
            D=numel(s);
            if D==2
                theSize=[num2str(s(1)),'x',num2str(s(2))];
            elseif D==3
                theSize=[num2str(s(1)),'x',num2str(s(2)),'x',...
                num2str(s(3))];
            else
                theSize=[num2str(D),'-D'];
            end

            classOfVal=class(val);



            complexType='';
            if strcmp(classOfVal,'double')&&~isreal(val)
                complexType='complex ';
            end

            if isempty(val)==0
                prefix=[name,': ',theSize,' ',complexType,classOfVal];
            else
                prefix=[name,': empty ',theSize,' ',classOfVal];
            end
        else
            prefix=[name,': ',header];
        end
    end

    function varargout=evalcWithHotlinksOff(cmdStr)
        evalStr=['feature(''hotlinks'', 0); ',cmdStr];
        varargout{1:nargout}=evalc(evalStr);
    end

    function callDisp(stringArg)
        evalStr=['disp(',stringArg,')'];
        dispStringWithHotLinksOff(evalStr);
    end

    function callDisplay(stringArg)
        evalStr=['display(',stringArg,', '''')'];
        dispStringWithHotLinksOff(evalStr);
    end

    function dispStringWithHotLinksOff(evalStr)
        evaledStr=evalcWithHotlinksOff(evalStr);

        evaledStr=truncateText(evaledStr);
        disp(evaledStr);
    end

    function text=truncateText(text)
        evaledStrLength=numel(text);
        truncatedLength=min(getTruncationLimit(),evaledStrLength);
        text=text(1:truncatedLength);

        if(truncatedLength<evaledStrLength)
            text=[text,'...'];
        end
    end

    function limit=getTruncationLimit()

        limit=30000;
    end
end
