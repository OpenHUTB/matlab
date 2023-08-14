
classdef Parser
    properties(Constant)
        ScanFcn=1;
        ScanFcnArgList=2;
        KnownDataTypes={...
        'double','single','int32','uint32',...
        'int8','uint8','int16','uint16','int64',...
        'uint64','cdouble','csingle',...
        'cint32','cuint32','cint8','cuint8','cint16',...
        'cuint16','cint64','cuint64',...
        'integer','long','long_long',...
        'uinteger','ulong','ulong_long',...
        'cuinteger','culong','culong_long',...
        'cinteger','clong','clong_long',...
        'cuinteger','culong','culong_long',...
        'boolean','logical','size_t','csize_t',...
        'ptrdiff_t','char','void','int','cint',...
        'half'};
        KnownValidTrailingChars={'*',' ','[','&'};
        KnownQualifiers={'const'};

        ScanningStart=1;
        Scanning=2;
        ScanningOp=3;
        ScanningArgName=4;
        ScanningAfterDataType=5;
        ScanningDimensions=6;
        ScanningDimensionsEnd=7;
        ScanningAfterArg=8;
        ScanningForArgRename=9;
        ScanningMergedIO=10;
        ScanningFcnArgList=11;
        ScanningFixdt=12;
        ScanningQualifier=13;
        ScanningLastChar=14;
    end
    methods(Static)
        function aF=doit(inStr)
            aF=[];
            if~isempty(inStr)
                aF=coder.parser.Parser.parseStr(inStr,coder.parser.Parser.ScanFcn);
            end
        end



        function aFcn=parseStr(aStr,mode)
            aFcn=coder.parser.Function;

            strParts=strsplit(aStr,'=','CollapseDelimiters',false);



            lhs='';
            lenParts=length(strParts);
            if lenParts>4
                DAStudio.error('CoderFoundation:parser:IncorrectFormat',aStr);
            elseif lenParts==4

                lhs=strtrim(strParts{1});
                rhs=strtrim([strParts{2},'==',strParts{4}]);
            elseif lenParts==3

                lhs=strtrim(strParts{1});
                rhs=strtrim([strParts{2},'=',strParts{3}]);
            elseif lenParts==2
                lhs=strtrim(strParts{1});
                rhs=strtrim(strParts{2});
            else
                rhs=strtrim(strParts{1});
            end
            if~isempty(lhs)
                aFcn.returnArguments=coder.parser.Parser.parseLHS(lhs,mode);
            end
            [aFcn.name,aFcn.arguments]=coder.parser.Parser.parseSubStr(rhs,mode);

        end






        function args=parseLHS(lhsStr,mode)

            if lhsStr(1)=='['
                lhsStr=lhsStr(2:end);
                if lhsStr(end)==']'
                    lhsStr=lhsStr(1:end-1);
                else
                    DAStudio.error('CoderFoundation:parser:MissingCloseBracket',lhsStr);
                end
            end
            lhsStr=strtrim(lhsStr);
            [~,args]=coder.parser.Parser.parseSubStr(lhsStr,mode);
        end




        function[name,args]=parseSubStr(aStr,mode)

            args={};
            name='';
            subStr='';
            qualifierStr='';
            current=1;
            state=coder.parser.Parser.ScanningStart;
            currentArg=coder.parser.Argument;
            lengthStr=length(aStr);
            ignoreLeadingSpace=true;
            expectAComma=false;
            skipNextClose=false;
            dollarDetected=false;

            while current<=lengthStr
                lastState=state;
                aChar=aStr(current);
                if current==lengthStr&&...
                    state~=coder.parser.Parser.ScanningFcnArgList
                    state=coder.parser.Parser.ScanningLastChar;
                end
                switch state
                case coder.parser.Parser.ScanningStart
                    subStr='';
                    dollarDetected=false;
                    switch aChar
                    case ' '
                    case 'f'
                        k=regexp(aStr(current:end),'fixdt\s*(');
                        if~isempty(k)&&k(1)==1
                            state=coder.parser.Parser.ScanningFixdt;
                            subStr='fixdt';
                            current=current+4;
                        else
                            state=coder.parser.Parser.Scanning;
                            current=current-1;
                        end
                    case 'c'
                        k=regexp(aStr(current:end),'cfixdt\s*(');
                        if~isempty(k)&&k(1)==1
                            state=coder.parser.Parser.ScanningFixdt;
                            subStr='cfixdt';
                            current=current+5;
                        else
                            state=coder.parser.Parser.Scanning;
                            current=current-1;
                        end
                    otherwise
                        state=coder.parser.Parser.Scanning;
                        current=current-1;
                    end
                case coder.parser.Parser.Scanning
                    switch aChar
                    case '"'
                        state=coder.parser.Parser.ScanningArgName;
                        subStr='';
                    case ')'
                        DAStudio.error('CoderFoundation:parser:MissingOpenParen',aStr);
                    case '('
                        if coder.parser.Parser.validateCurrentArg(currentArg,aStr)
                            args{end+1}=currentArg;
                            currentArg=coder.parser.Argument;
                        end
                        name=strtrim(subStr);
                        state=coder.parser.Parser.ScanningFcnArgList;
                        subStr='';
                    case ','
                        if coder.parser.Parser.isKnownDataType(subStr)
                            DAStudio.error('CoderFoundation:parser:MissingArgName',aStr,subStr);
                        elseif coder.parser.Parser.isKnownQualifier(subStr)
                            DAStudio.error('CoderFoundation:parser:MissingArgName',aStr,subStr);
                        else
                            if strcmp(subStr,'*')
                                DAStudio.error('CoderFoundation:parser:MissingArgName',aStr,subStr);
                            elseif strcmp(subStr,'&')
                                DAStudio.error('CoderFoundation:parser:MissingArgName',aStr,subStr);
                            else
                                if~strcmp(subStr,'void')
                                    currentArg.name=subStr;
                                    args{end+1}=currentArg;
                                    currentArg=coder.parser.Argument;
                                    subStr='';
                                end
                                state=coder.parser.Parser.ScanningStart;
                            end
                        end
                    case ' '
                        if coder.parser.Parser.isKnownDataType(subStr)
                            if~isempty(currentArg.dataTypeString)
                                DAStudio.error('CoderFoundation:parser:DataTypeAlreadySet',aStr,subStr,currentArg.dataTypeString);
                            end
                            currentArg.dataTypeString=subStr;
                            state=coder.parser.Parser.ScanningAfterDataType;
                        elseif coder.parser.Parser.isKnownQualifier(subStr)
                            qualifierStr=subStr;
                            state=coder.parser.Parser.ScanningQualifier;
                        else
                            if strcmp(subStr,'*')
                                currentArg.passBy=coder.parser.PassByEnum.Pointer;
                            elseif strcmp(subStr,'&')
                                currentArg.passBy=coder.parser.PassByEnum.Reference;
                            else

                                tempIdx=current+1;
                                while tempIdx<=lengthStr&&...
                                    aStr(tempIdx)==' '
                                    tempIdx=tempIdx+1;
                                end
                                if aStr(tempIdx)=='('
                                    name=strtrim(subStr);
                                    state=coder.parser.Parser.ScanningFcnArgList;
                                    current=tempIdx;
                                else



                                    if~strcmp(subStr,'void')
                                        currentArg.name=subStr;
                                        state=coder.parser.Parser.ScanningAfterArg;
                                    end
                                end
                            end
                        end
                        subStr='';
                    case '&'

                        tempIdx=current+1;
                        while tempIdx<=lengthStr&&...
                            aStr(tempIdx)==' '
                            tempIdx=tempIdx+1;
                        end
                        if aStr(tempIdx)=='&'

                            if~isempty(subStr)
                                currentArg.mergedWith{end+1}=subStr;
                            else
                                if~isempty(currentArg.name)
                                    currentArg.mergedWith{end+1}=currentArg.name;
                                    currentArg.name='';
                                else

                                    assert(0);
                                end
                            end
                            state=coder.parser.Parser.ScanningMergedIO;
                            subStr='';
                            current=tempIdx;
                            ignoreLeadingSpace=true;
                        else
                            currentArg.passBy=coder.parser.PassByEnum.Reference;
                            state=coder.parser.Parser.ScanningStart;
                        end
                    case coder.parser.Function.OpLeadChar
                        isOp=true;
                        if~isempty(subStr)

                            if coder.parser.Parser.isKnownDataType(subStr)
                                if aChar=='*'
                                    if~isempty(currentArg.dataTypeString)
                                        DAStudio.error('CoderFoundation:parser:DataTypeAlreadySet',aStr,subStr,currentArg.dataTypeStr);
                                    end

                                    if aStr(current+1)~=' '
                                        errorStr=[subStr,aChar,aStr(current+1)];
                                        DAStudio.error('CoderFoundation:parser:UnsupportedDataType',aStr,errorStr);
                                    end
                                    currentArg.dataTypeString=subStr;
                                    currentArg.passBy=coder.parser.PassByEnum.Pointer;
                                    isOp=false;
                                    state=coder.parser.Parser.ScanningStart;
                                else


                                    DAStudio.error('CoderFoundation:parser:InvalidCharAfterDT',aStr,aChar,subStr);
                                end
                            elseif coder.parser.Parser.isKnownQualifier(subStr)
                                qualifierStr=subStr;
                                subStr='';
                                isOp=false;
                                current=current-1;
                                state=coder.parser.Parser.ScanningQualifier;
                            else
                                currentArg.name=subStr;
                                args{end+1}=currentArg;
                                currentArg=coder.parser.Argument;
                                subStr='';
                                state=coder.parser.Parser.ScanningStart;
                            end
                        else
                            if aChar=='*'&&mode==coder.parser.Parser.ScanFcnArgList
                                currentArg.passBy=coder.parser.PassByEnum.Pointer;
                                isOp=false;
                                state=coder.parser.Parser.ScanningStart;
                            end
                        end

                        if isOp
                            subStr=aChar;
                            state=coder.parser.Parser.ScanningOp;
                        end
                    case '['
                        if~dollarDetected
                            currentArg.name=subStr;
                            subStr='';
                            currentArg.dimensionString=aChar;
                            state=coder.parser.Parser.ScanningDimensions;
                        else
                            subStr(end+1)=aChar;
                        end
                    case '$'
                        dollarDetected=true;
                        subStr(end+1)=aChar;
                    otherwise
                        subStr(end+1)=aChar;
                    end
                case coder.parser.Parser.ScanningOp
                    switch aChar
                    case ' '
                        name=[name,subStr];
                        state=coder.parser.Parser.ScanningStart;
                    case coder.parser.Function.OpLeadChar
                        subStr=[subStr,aChar];
                    case{'s','w','u','f','c','z','n','m','v'}
                        subStr=[subStr,aChar];
                    otherwise
                        DAStudio.error('CoderFoundation:parser:InvalidCharAfterOperator',[subStr,aChar]);
                    end
                case coder.parser.Parser.ScanningArgName
                    switch aChar
                    case '"'
                        state=coder.parser.Parser.Scanning;
                    otherwise
                        subStr(end+1)=aChar;%#ok<*AGROW>
                    end
                case coder.parser.Parser.ScanningAfterDataType
                    switch aChar
                    case ' '
                    case '*'
                        if currentArg.passBy==coder.parser.PassByEnum.Pointer

                            DAStudio.error('CoderFoundation:parser:UnsupportedDataType',aStr,[currentArg.dataTypeString,'**']);
                        end
                        if currentArg.passBy==coder.parser.PassByEnum.Reference

                            DAStudio.error('CoderFoundation:parser:UnsupportedDataType',aStr,[currentArg.dataTypeString,'&*']);
                        end
                        currentArg.passBy=coder.parser.PassByEnum.Pointer;
                    case '&'
                        if currentArg.passBy==coder.parser.PassByEnum.Pointer

                            DAStudio.error('CoderFoundation:parser:UnsupportedDataType',aStr,[currentArg.dataTypeString,'*&']);
                        end
                        if currentArg.passBy==coder.parser.PassByEnum.Reference

                            DAStudio.error('CoderFoundation:parser:UnsupportedDataType',aStr,[currentArg.dataTypeString,'&&']);
                        end
                        currentArg.passBy=coder.parser.PassByEnum.Reference;
                    case ','
                        DAStudio.error('CoderFoundation:parser:MissingArgName',aStr,subStr);
                    case coder.parser.Function.OpLeadChar
                        DAStudio.error('CoderFoundation:parser:MissingArgName',aStr,subStr);
                    otherwise
                        subStr='';
                        current=current-1;
                        state=coder.parser.Parser.Scanning;
                    end
                case coder.parser.Parser.ScanningDimensions
                    switch aChar
                    case ']'
                        currentArg.dimensionString=[currentArg.dimensionString,aChar];
                        state=coder.parser.Parser.ScanningDimensionsEnd;
                    otherwise
                        currentArg.dimensionString=[currentArg.dimensionString,aChar];
                    end
                case coder.parser.Parser.ScanningDimensionsEnd
                    switch aChar
                    case ' '
                    case '['
                        currentArg.dimensionString=[currentArg.dimensionString,aChar];
                        state=coder.parser.Parser.ScanningDimensions;
                    otherwise
                        currentArg.dimensionString=strtrim(currentArg.dimensionString);
                        args{end+1}=currentArg;
                        currentArg=coder.parser.Argument;
                        if aChar~=','
                            current=current-1;
                        end
                        state=coder.parser.Parser.ScanningStart;
                    end
                case coder.parser.Parser.ScanningAfterArg
                    switch aChar
                    case ' '
                    case '['
                        currentArg.dimensionString=aChar;
                        state=coder.parser.Parser.ScanningDimensions;
                    case coder.parser.Function.OpLeadChar
                        subStr=aChar;
                        state=coder.parser.Parser.ScanningOp;
                        args{end+1}=currentArg;
                        currentArg=coder.parser.Argument;
                    case ','
                        args{end+1}=currentArg;
                        currentArg=coder.parser.Argument;
                        state=coder.parser.Parser.ScanningStart;
                    case '&'

                        state=coder.parser.Parser.Scanning;
                        current=current-1;
                    case '$'
                        dollarDetected=true;
                        state=coder.parser.Parser.ScanningForArgRename;
                        subStr=aChar;
                        ignoreLeadingSpace=false;
                        expectAComma=false;
                    otherwise
                        state=coder.parser.Parser.ScanningForArgRename;
                        subStr=aChar;
                        ignoreLeadingSpace=false;
                        expectAComma=false;
                    end
                case coder.parser.Parser.ScanningForArgRename
                    switch aChar
                    case ' '




                        if~ignoreLeadingSpace
                            expectAComma=true;
                        end
                    case ','
                        if~isempty(currentArg.name)
                            currentArg.mappedFrom{end+1}=currentArg.name;
                        end
                        currentArg.name=subStr;
                        args{end+1}=currentArg;
                        currentArg=coder.parser.Argument;
                        subStr='';
                        state=coder.parser.Parser.ScanningStart;
                    case '('
                        DAStudio.error('CoderFoundation:parser:MissingEqual',aStr);
                    case '$'
                        dollarDetected=true;
                        if expectAComma
                            DAStudio.error('CoderFoundation:parser:MissingEqualOrComma',aStr);
                        end
                        ignoreLeadingSpace=false;
                        subStr(end+1)=aChar;
                    otherwise
                        if expectAComma
                            DAStudio.error('CoderFoundation:parser:MissingEqualOrComma',aStr);
                        end
                        ignoreLeadingSpace=false;
                        subStr(end+1)=aChar;
                    end
                case coder.parser.Parser.ScanningMergedIO




                    switch aChar
                    case{' '}
                        if~isempty(subStr)&&~ignoreLeadingSpace


                            currentArg.name=subStr;
                            subStr='';
                            ignoreLeadingSpace=true;
                            expectAComma=false;
                            state=coder.parser.Parser.ScanningForArgRename;
                        end
                    case{','}
                        if~isempty(subStr)


                            currentArg.name=subStr;
                            subStr='';
                            args{end+1}=currentArg;
                            currentArg=coder.parser.Argument;
                            state=coder.parser.Parser.ScanningStart;
                        end
                    case '&'
                        DAStudio.error('CoderFoundation:parser:MisplacedAmpersandAfterMergedIO',aStr);
                    otherwise
                        subStr(end+1)=aChar;
                        ignoreLeadingSpace=false;
                    end
                case coder.parser.Parser.ScanningFcnArgList
                    switch aChar
                    case '('

                        skipNextClose=true;
                        subStr(end+1)=aChar;
                    case ')'
                        if~skipNextClose
                            [~,args]=coder.parser.Parser.parseSubStr(strtrim(subStr),coder.parser.Parser.ScanFcnArgList);
                            state=coder.parser.Parser.ScanningStart;
                        else
                            subStr(end+1)=aChar;
                        end
                        skipNextClose=false;
                    otherwise
                        subStr(end+1)=aChar;
                        if current==lengthStr

                            DAStudio.error('CoderFoundation:parser:MissingCloseParen',aStr);
                        end
                    end
                case coder.parser.Parser.ScanningFixdt
                    switch aChar
                    case ' '


                    case ')'
                        subStr(end+1)=aChar;
                        if~isempty(currentArg.dataTypeString)
                            DAStudio.error('CoderFoundation:parser:DataTypeAlreadySet',aStr,subStr,currentArg.dataTypeString);
                        end
                        currentArg.dataTypeString=subStr;
                        state=coder.parser.Parser.ScanningAfterDataType;
                    case{'(','.','*','~',',','-','^','f','a','l','s','e','t','r','u'}
                        subStr(end+1)=aChar;
                    otherwise
                        if all(isstrprop(aChar,'digit'))
                            subStr(end+1)=aChar;
                        else
                            DAStudio.error('CoderFoundation:parser:MissingCloseParen',aStr);
                        end
                    end
                case coder.parser.Parser.ScanningQualifier
                    switch aChar
                    case ' '

                    case{'*','&'}
                        qualifierStr=[qualifierStr,aChar];
                    otherwise


                        tempSubStr='';
                        if lengthStr>=current+4
                            tempSubStr=aStr(current:current+4);
                        end
                        if coder.parser.Parser.isKnownQualifier(tempSubStr)&&...
                            (lengthStr==current+4||aStr(current+5)==' ')
                            if lengthStr==current+4
                                DAStudio.error('CoderFoundation:parser:MissingArgName',aStr,aStr);
                            end
                            if qualifierStr(end)~='*'




                                DAStudio.error('CoderFoundation:parser:InvalidQualifier',aStr);
                            end
                            qualifierStr=[qualifierStr,tempSubStr];
                            current=current+5;
                        else


                            current=current-1;
                        end
                        state=coder.parser.Parser.ScanningStart;
                        [currentArg.qualifier,currentArg.passBy]=...
                        coder.parser.Parser.convertQualifierStr(qualifierStr,currentArg);
                        qualifierStr='';
                    end
                case coder.parser.Parser.ScanningLastChar
                    switch aChar
                    case ')'
                        DAStudio.error('CoderFoundation:parser:MissingOpenParen',aStr);
                    case '"'
                        assert(isempty(currentArg.name));
                        currentArg.name=subStr;
                        args{end+1}=currentArg;
                    case ']'
                        subStr(end+1)=aChar;
                        if~dollarDetected
                            assert(~isempty(currentArg.dimensionString));
                            currentArg.dimensionString=[currentArg.dimensionString,aChar];
                        else
                            if~isempty(currentArg.name)
                                currentArg.mappedFrom{end+1}=currentArg.name;
                            end
                            currentArg.name=subStr;
                            if~isempty(qualifierStr)
                                [currentArg.qualifier,currentArg.passBy]=...
                                coder.parser.Parser.convertQualifierStr(qualifierStr,currentArg);
                            end
                        end
                        args{end+1}=currentArg;
                    case ''''
                        if subStr=='.'
                            name=[name,subStr,aChar];
                        else
                            if isempty(currentArg.name)&&~isempty(subStr)
                                currentArg.name=subStr;
                            end
                            name=[name,aChar];
                        end
                        if~isempty(currentArg.name)
                            args{end+1}=currentArg;
                        end
                    otherwise
                        if lastState==coder.parser.Parser.ScanningDimensions
                            DAStudio.error('CoderFoundation:parser:MissingCloseBracket',aStr);
                        elseif lastState==coder.parser.Parser.ScanningQualifier
                            if aChar=='*'||aChar=='&'
                                DAStudio.error('CoderFoundation:parser:MissingArgName',aStr,aStr);
                            end
                        end
                        subStr(end+1)=aChar;


                        if~isempty(currentArg.name)
                            currentArg.mappedFrom{end+1}=currentArg.name;
                        end
                        isVoid=strcmp(subStr,'void');
                        if coder.parser.Parser.isKnownDataType(subStr)&&...
                            ~isVoid
                            DAStudio.error('CoderFoundation:parser:MissingArgName',aStr,subStr);
                        elseif~isVoid
                            if~isempty(qualifierStr)
                                [currentArg.qualifier,currentArg.passBy]=...
                                coder.parser.Parser.convertQualifierStr(qualifierStr,currentArg);
                            else



                                tempArg=coder.parser.Argument;
                                [tempArg.qualifier,tempArg.passBy]=...
                                coder.parser.Parser.convertQualifierStr(subStr,tempArg);
                                if tempArg.qualifier~=coder.parser.Qualifier.None||...
                                    tempArg.passBy~=coder.parser.PassByEnum.Value
                                    DAStudio.error('CoderFoundation:parser:MissingArgName',aStr,subStr);
                                end
                            end
                            currentArg.name=subStr;
                            if isempty(currentArg.name)
                                DAStudio.error('CoderFoundation:parser:MissingArgName',aStr,aStr);
                            end
                            args{end+1}=currentArg;
                        end
                    end
                otherwise


                    assert(0);
                end
                current=current+1;
            end
        end

        function isDT=isKnownDataType(aStr)
            isDT=ismember(aStr,coder.parser.Parser.KnownDataTypes);
        end

        function isQual=isKnownQualifier(aStr)
            isQual=ismember(aStr,coder.parser.Parser.KnownQualifiers);
        end

        function[qualifier,passBy]=convertQualifierStr(aStr,currentArg)
            qualifier=coder.parser.Qualifier.None;
            passBy=currentArg.passBy;
            switch aStr
            case 'const'
                if currentArg.qualifier==coder.parser.Qualifier.None
                    if currentArg.passBy==coder.parser.PassByEnum.Pointer
                        qualifier=coder.parser.Qualifier.ConstPointer;
                    else
                        qualifier=coder.parser.Qualifier.Const;
                    end
                elseif currentArg.qualifier==coder.parser.Qualifier.Const&&...
                    currentArg.passBy==coder.parser.PassByEnum.Pointer
                    qualifier=coder.parser.Qualifier.ConstPointerToConstData;
                end
            case 'const*'
                qualifier=coder.parser.Qualifier.Const;
                passBy=coder.parser.PassByEnum.Pointer;
            case 'const&'
                qualifier=coder.parser.Qualifier.Const;
                passBy=coder.parser.PassByEnum.Reference;
            case 'const*const'
                qualifier=coder.parser.Qualifier.ConstPointerToConstData;
                passBy=coder.parser.PassByEnum.Pointer;
            case '*'
                passBy=coder.parser.PassByEnum.Pointer;
            case '&'
                passBy=coder.parser.PassByEnum.Reference;
            end
        end

        function doCommit=validateCurrentArg(currentArg,aStr)
            doCommit=false;
            if isempty(currentArg.name)&&~isempty(currentArg.dataTypeString)&&...
                ~strcmp(currentArg.dataTypeString,'void')
                DAStudio.error('CoderFoundation:parser:MissingArgName',aStr,currentArg.dataTypeString);
            end
            if~isempty(currentArg.name)||strcmp(currentArg.dataTypeString,'void')
                doCommit=true;
            end
        end
    end
end



