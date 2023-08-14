
function hEnt=createCRLEntry(hThis,aConStr,aImplStr)









    locValidateInputs(aConStr,aImplStr);

    words=regexp(aConStr,'[^ ]\s+[^ ]','once');
    if~isempty(aConStr)&&isempty(words)

        conceptF=coder.parser.Function;
        conceptF.name=aConStr;
    else
        conceptF=coder.parser.Parser.doit(aConStr);
    end
    words=regexp(aImplStr,'[^ ][\s+\(\)][^ ]','once');
    if isempty(words)

        implF=coder.parser.Function;
        implF.name=aImplStr;
    else
        implF=coder.parser.Parser.doit(aImplStr);
    end

    if length(implF.returnArguments)>1
        DAStudio.error('CoderFoundation:tfl:TooManyReturnArgsInImpl',aImplStr);
    end

    [conceptF,implF]=copyMissingArguments(conceptF,implF,aConStr,aImplStr);
    [conceptF,implF]=copyMissingDataTypes(conceptF,implF,aConStr);

    concepName=conceptF.name;
    isFunction=false;
    if~isempty(concepName)
        isFunction=isstrprop(concepName(1),'alpha');
    end
    satMode='';
    rndMode='';
    if~isFunction



        if length(concepName)>2
            lastTwo=concepName(end-1:end);
            lastTwoAlpha=isstrprop(lastTwo,'alpha');
            if lastTwoAlpha
                satMode=locConvertSaturation(lastTwo(1),concepName);
                rndMode=locConvertRounding(lastTwo(2),concepName);
                concepName=concepName(1:end-2);
            end
        end

        hEnt=locGetEntry(conceptF,isFunction);


        switch concepName
        case '+'
            hEnt.Key='RTW_OP_ADD';
        case '-'
            hEnt.Key='RTW_OP_MINUS';
        case '*'
            hEnt.Key='RTW_OP_MUL';
        case '.*'
            hEnt.Key='RTW_OP_ELEM_MUL';
        case '/'
            hEnt.Key='RTW_OP_DIV';
        case '\'
            hEnt.Key='RTW_OP_LDIV';
        case '/'''
            hEnt.Key='RTW_OP_RDIV';
        case '*/'
            hEnt.Key='RTW_OP_MULDIV';
        case '*>>'
            hEnt.Key='RTW_OP_MUL_SRA';
        case ''
            hEnt.Key='RTW_OP_CAST';
        case '<<'
            hEnt.Key='RTW_OP_SL';
        case '>>'
            hEnt.Key='RTW_OP_SRA';
        case '.>>'
            hEnt.Key='RTW_OP_SRL';
        case '.'''
            hEnt.Key='RTW_OP_TRANS';
        case ''''
            hEnt.Key='RTW_OP_HERMITIAN';
        case{'.''*','*.'''}
            hEnt.Key='RTW_OP_TRMUL';
        case{'''*','*'''}
            hEnt.Key='RTW_OP_HMMUL';
        case '>'
            hEnt.Key='RTW_OP_GREATER_THAN';
        case '<'
            hEnt.Key='RTW_OP_LESS_THAN';
        case '>='
            hEnt.Key='RTW_OP_GREATER_THAN_OR_EQUAL';
        case '<='
            hEnt.Key='RTW_OP_LESS_THAN_OR_EQUAL';
        case '=='
            hEnt.Key='RTW_OP_EQUAL';
        case '!='
            hEnt.Key='RTW_OP_NOT_EQUAL';
        otherwise
            DAStudio.error('CoderFoundation:tfl:InvalidConOp',concepName,aConStr);
        end
        if~isempty(satMode)
            hEnt.SaturationMode=satMode;
        end
        if~isempty(rndMode)
            hEnt.RoundingModes={rndMode};
        end
    else
        hEnt=locGetEntry(conceptF,isFunction);
        hEnt.Key=conceptF.name;
    end
    for idx=1:length(conceptF.returnArguments)
        thisArg=conceptF.returnArguments{idx};
        if isempty(thisArg.name)
            thisArg.name=['y',num2str(idx)];
            conceptF.returnArguments{idx}.name=thisArg.name;
        end
        arg=locGetTflArg(hThis,thisArg,false);
        arg.IOType='RTW_IO_OUTPUT';
        hEnt.addConceptualArg(arg);
    end
    for idx=1:length(conceptF.arguments)
        thisArg=conceptF.arguments{idx};
        if isempty(thisArg.name)
            thisArg.name=['u',num2str(idx)];
        end
        arg=locGetTflArg(hThis,thisArg,false);
        hEnt.addConceptualArg(arg);
    end



    for idx=1:length(implF.arguments)
        thisArg=implF.arguments{idx};
        arg=locGetTflArg(hThis,thisArg,true);
        if~isempty(thisArg.mergedWith)
            if length(thisArg.mergedWith)>1
                DAStudio.error('CoderFoundation:tfl:TooManyInPlaceArgsSpecified',thisArg.name);
            end
            if~isa(arg,'RTW.TflArgPointer')
                DAStudio.error('CoderFoundation:tfl:NonPointerInPlaceArgSpecified',thisArg.name);
            end
            arg.ArgumentForInPlaceUse=thisArg.mergedWith{1};
            arg.IOType='RTW_IO_INPUT_OUTPUT';
        else
            for idy=1:length(conceptF.returnArguments)
                if strcmp(conceptF.returnArguments{idy}.name,thisArg.name)
                    arg.IOType='RTW_IO_OUTPUT';
                    break;
                end
            end
        end
        hEnt.Implementation.addArgument(arg);
    end


    assert(length(implF.returnArguments)<2);
    for idx=1:length(implF.returnArguments)
        thisArg=implF.returnArguments{idx};
        arg=locGetTflArg(hThis,thisArg,true);
        arg.IOType='RTW_IO_OUTPUT';
        if isempty(thisArg.dimensionString)

            hEnt.Implementation.setReturn(arg);
        else

            hEnt.Implementation.addArgument(arg);
        end
    end
    if isempty(hEnt.Implementation.Return)
        arg=hThis.getTflArgFromString('unused','void');
        arg.IOType='RTW_IO_OUTPUT';
        hEnt.Implementation.setReturn(arg);
        hEnt.SideEffects=true;
    end
    hEnt.Implementation.Name=implF.name;


    function locValidateInputs(aConStr,aImplStr)
        if isempty(aConStr)
            DAStudio.error('CoderFoundation:tfl:EmptyConSpec');
        end
        if isempty(aImplStr)
            DAStudio.error('CoderFoundation:tfl:EmptyImpSpec');
        end


        function locValidateCharForDimension(aStr)
            for idx=1:length(aStr)
                aChar=aStr(idx);
                i=regexp('-;infINF []0123456789',aChar,'once');
                if isempty(i)
                    DAStudio.error('CoderFoundation:tfl:InvalidCharInDimStr',aStr);
                end
            end


            function dimRange=locGetDimRange(aStr)
                locValidateCharForDimension(aStr);
                parts=strsplit(aStr,'[');
                if length(parts)>2

                    if length(parts)>3
                        DAStudio.error('CoderFoundation:tfl:InvalidDimStr',aStr);
                    end
                    dimStr=regexprep(aStr,'\]\s*\[',' ');
                    dimRange=str2num(dimStr);%#ok<ST2NM>
                else
                    if length(parts)~=2
                        DAStudio.error('CoderFoundation:tfl:InvalidDimStr',aStr);
                    end

                    parts=strsplit(aStr,';');
                    if length(parts)>2
                        DAStudio.error('CoderFoundation:tfl:InvalidDimStr',aStr);
                    end
                    dimRange=str2num(aStr);%#ok<ST2NM>
                end


                function arg=locGetTflArg(hThis,aParserArg,getBaseType)

                    if isempty(aParserArg.name)
                        DAStudio.error('CoderFoundation:tfl:MissingArgumentName');
                    end

                    if aParserArg.qualifier==coder.parser.Qualifier.ConstPointerToConstData
                        DAStudio.error('CoderFoundation:tfl:UnsupportedQualifierConstPtrToConstData',aParserArg.name);
                    end
                    if~isempty(aParserArg.mappedFrom)
                        DAStudio.error('CoderFoundation:tfl:UnsupportedDataTypeForArg',aParserArg.mappedFrom{1},aParserArg.name);
                    end

                    dtStr=aParserArg.dataTypeString;


                    dtStr=strrep(dtStr,'~','*');
                    isFixdt=any(strfind(dtStr,'fixdt'));
                    if strcmp(dtStr,'int')
                        dtStr='integer';
                    end
                    if strcmp(dtStr,'cint')
                        dtStr='cinteger';
                    end
                    if getBaseType&&isFixdt
                        dtStr=locGetBaseType(dtStr);
                    end
                    if isempty(dtStr)
                        DAStudio.error('CoderFoundation:tfl:MissingDataTypeInConStr','',aParserArg.name);
                    end

                    isMatrix=~isempty(aParserArg.dimensionString);
                    if isMatrix&&~getBaseType
                        arg=RTW.TflArgMatrix(aParserArg.name,'RTW_IO_INPUT',dtStr);
                        arg.DimRange=locGetDimRange(aParserArg.dimensionString);
                    else
                        if isMatrix||(aParserArg.passBy==coder.parser.PassByEnum.Pointer)
                            dtStr=[dtStr,'*'];
                        end
                        arg=hThis.getTflArgFromString(aParserArg.name,dtStr);
                    end
                    switch aParserArg.qualifier
                    case coder.parser.Qualifier.Const
                        if aParserArg.passBy==coder.parser.PassByEnum.Pointer
                            arg.Type.BaseType.ReadOnly=true;
                        else
                            arg.Type.ReadOnly=true;
                        end
                    case coder.parser.Qualifier.ConstPointer
                        arg.Type.ReadOnly=true;
                    case coder.parser.Qualifier.ConstPointerToConstData
                        arg.Type.ReadOnly=true;
                        arg.Type.BaseType.ReadOnly=true;
                    otherwise
                        arg.Type.ReadOnly=false;
                    end
                    if isFixdt&&~isempty(regexp(dtStr,'[\*]','once'))&&...
                        ~(aParserArg.passBy==coder.parser.PassByEnum.Pointer)

                        dtInfo=ParseDataTypeString(aParserArg.dataTypeString,aParserArg.name);



                        if(isfield(dtInfo,'FixedExponent'))
                            arg.CheckSlope=~(strcmp(dtInfo.FixedExponent,'*')...
                            ||strcmp(dtInfo.FixedExponent,'~'));
                            arg.CheckBias=~(strcmp(dtInfo.Bias,'*')...
                            ||strcmp(dtInfo.Bias,'~'));

                        else
                            arg.CheckSlope=~(strcmp(dtInfo.Slope,'*')...
                            ||strcmp(dtInfo.Slope,'~'));
                            arg.CheckBias=~(strcmp(dtInfo.Bias,'*')...
                            ||strcmp(dtInfo.Bias,'~'));
                        end
                    end

                    function dtStr=locGetBaseType(dtStr)
                        firstChar='';
                        if dtStr(1)=='c'
                            firstChar='c';
                        end
                        dtStr=regexprep(dtStr,[firstChar,'fixdt\s*\(|\)'],'');
                        parts=strsplit(dtStr,',');
                        assert(length(parts)>1);
                        sign=str2num(parts{1});%#ok<ST2NM>
                        dtStr=['int',parts{2}];
                        if~sign
                            dtStr=['u',dtStr];
                        end
                        dtStr=[firstChar,dtStr];


                        function mm=locConvertSaturation(aChar,aConName)
                            switch aChar
                            case 's'
                                mm='RTW_SATURATE_ON_OVERFLOW';
                            case 'w'
                                mm='RTW_WRAP_ON_OVERFLOW';
                            case 'u'
                                mm='RTW_SATURATE_UNSPECIFIED';
                            otherwise
                                DAStudio.error('CoderFoundation:tfl:InvalidSatChar',aChar,aConName);
                            end


                            function mm=locConvertRounding(aChar,aConName)
                                switch aChar
                                case 'f'
                                    mm='RTW_ROUND_FLOOR';
                                case 'c'
                                    mm='RTW_ROUND_CEILING';
                                case 'z'
                                    mm='RTW_ROUND_ZERO';
                                case 'n'
                                    mm='RTW_ROUND_NEAREST';
                                case 'm'
                                    mm='RTW_ROUND_NEAREST_ML';
                                case 's'
                                    mm='RTW_ROUND_SIMPLEST';
                                case 'v'
                                    mm='RTW_ROUND_CONV';
                                case 'u'
                                    mm='RTW_ROUND_UNSPECIFIED';
                                otherwise
                                    DAStudio.error('CoderFoundation:tfl:InvalidRndChar',aChar,aConName);
                                end


                                function hEnt=locGetEntry(conceptF,isFunction)
                                    containsAsterisk=false;
                                    SlopecontainsTilda=false;
                                    BiascontainsTilda=false;
                                    numarguments=numel(conceptF.arguments);
                                    for idx=1:numarguments
                                        thisArg=conceptF.arguments{idx};
                                        [argcontainsAsterisk,argSlopecontainsTilda,argBiascontainsTilda]=...
                                        findwildcard(thisArg,isFunction);
                                        containsAsterisk=containsAsterisk||argcontainsAsterisk;
                                        SlopecontainsTilda=SlopecontainsTilda||argSlopecontainsTilda;
                                        BiascontainsTilda=BiascontainsTilda||argBiascontainsTilda;
                                    end

                                    numreturn=numel(conceptF.returnArguments);
                                    for idx=1:numreturn
                                        thisArg=conceptF.returnArguments{idx};
                                        [argcontainsAsterisk,argSlopecontainsTilda,argBiascontainsTilda]=...
                                        findwildcard(thisArg,isFunction);
                                        containsAsterisk=containsAsterisk||argcontainsAsterisk;
                                        SlopecontainsTilda=SlopecontainsTilda||argSlopecontainsTilda;
                                        BiascontainsTilda=BiascontainsTilda||argBiascontainsTilda;
                                    end
                                    if containsAsterisk||SlopecontainsTilda||BiascontainsTilda
                                        if isFunction
                                            hEnt=RTW.TflCFunctionEntry;
                                        else
                                            hEnt=RTW.TflCOperationEntryGenerator_NetSlope;
                                        end
                                        if SlopecontainsTilda
                                            hEnt.SlopesMustBeTheSame=true;
                                        end


                                        if BiascontainsTilda
                                            hEnt.BiasMustBeTheSame=true;
                                        end
                                    else
                                        if isFunction
                                            hEnt=RTW.TflCFunctionEntry;
                                        else
                                            hEnt=RTW.TflCOperationEntry;
                                        end
                                    end


                                    function[containsAsterisk,SlopecontainsTilda,BiascontainsTilda]=findwildcard(thisArg,isFunction)
                                        containsAsterisk=false;
                                        SlopecontainsTilda=false;
                                        BiascontainsTilda=false;
                                        dtStr=thisArg.dataTypeString;

                                        if any(strfind(dtStr,'*'))
                                            containsAsterisk=true;
                                        end

                                        dtInfo=ParseDataTypeString(dtStr,thisArg.name);
                                        numberoffields=numel(fieldnames(dtInfo));







                                        if(numberoffields==4||numberoffields==5)


                                            if strcmp(dtInfo.Bias,'~')
                                                if(~isFunction)
                                                    DAStudio.error('CoderFoundation:tfl:OpEntryUnsupportedBiasMustBeTheSame'...
                                                    ,dtStr,thisArg.name);
                                                else
                                                    BiascontainsTilda=true;
                                                end
                                            end


                                            if(numberoffields==5)


                                                if strcmp(dtInfo.FixedExponent,'~')
                                                    SlopecontainsTilda=true;
                                                end
                                            else
                                                if strcmp(dtInfo.Slope,'~')
                                                    SlopecontainsTilda=true;
                                                end
                                            end

                                        end


                                        function[conceptF,implF]=copyMissingArguments(conceptF,implF,conceptStr,implStr)

                                            if isempty(conceptF.arguments)

                                                if isempty(conceptF.returnArguments)
                                                    conceptF.returnArguments=implF.returnArguments;
                                                end
                                                if~isempty(implF.arguments)
                                                    maxArgs=length(implF.arguments);
                                                    tempAs{maxArgs}=[];tempN{maxArgs}=[];aCnt=1;

                                                    for idx=1:length(implF.arguments)



                                                        if implF.arguments{idx}.name(1)=='y'&&...
                                                            isstrprop(implF.arguments{idx}.name(2:end),'digit')
                                                            DAStudio.error('CoderFoundation:tfl:ReturnArgNotAllowed',implStr);
                                                        elseif implF.arguments{idx}.name(1)=='u'&&...
                                                            isstrprop(implF.arguments{idx}.name(2:end),'digit')
                                                            if implF.arguments{idx}.passBy==coder.parser.PassByEnum.Pointer
                                                                DAStudio.error('CoderFoundation:tfl:AmbiguousImplStr',implStr);
                                                            end
                                                            tempAs{aCnt}=implF.arguments{idx};
                                                            tempN{aCnt}=implF.arguments{idx}.name;
                                                            aCnt=aCnt+1;
                                                        end
                                                    end

                                                    [~,I]=sort(tempN);
                                                    conceptF.arguments=tempAs(I);
                                                end

                                            elseif isempty(implF.arguments)&&isempty(implF.returnArguments)
                                                if length(conceptF.returnArguments)>1
                                                    DAStudio.error('CoderFoundation:tfl:TooManyReturnArgsInCon',conceptStr);
                                                end
                                                implF.returnArguments=conceptF.returnArguments;
                                                implF.arguments=conceptF.arguments;

                                                for idx=1:length(implF.arguments)
                                                    if~isempty(implF.arguments{idx}.dimensionString)
                                                        implF.arguments{idx}.passBy=coder.parser.PassByEnum.Pointer;
                                                        implF.arguments{idx}.dimensionString='';
                                                    end
                                                end
                                            end


                                            function[conceptF,implF]=copyMissingDataTypes(conceptF,implF,conceptStr)

                                                for idx=1:length(conceptF.arguments)
                                                    conArg=conceptF.arguments{idx};
                                                    conName=conArg.name;
                                                    if~isempty(conArg.dataTypeString)
                                                        for idy=1:length(implF.arguments)
                                                            implArg=implF.arguments{idy};
                                                            impName=implArg.name;
                                                            if strcmp(conName,impName)
                                                                if isempty(implArg.dataTypeString)
                                                                    implF.arguments{idy}.dataTypeString=conArg.dataTypeString;
                                                                    implF.arguments{idy}.dimensionString=conArg.dimensionString;
                                                                    implF.arguments{idy}.passBy=conArg.passBy;
                                                                    implF.arguments{idy}.qualifier=conArg.qualifier;
                                                                end
                                                                break;
                                                            end
                                                        end
                                                    else
                                                        DAStudio.error('CoderFoundation:tfl:MissingDataTypeInConStr',conceptStr,conName);
                                                    end
                                                end

                                                for idx=1:length(conceptF.returnArguments)
                                                    conArg=conceptF.returnArguments{idx};
                                                    conName=conArg.name;
                                                    argFound=false;
                                                    if~isempty(conArg.dataTypeString)
                                                        for idy=1:length(implF.returnArguments)
                                                            implArg=implF.returnArguments{idy};
                                                            impName=implArg.name;
                                                            if strcmp(conName,impName)
                                                                if isempty(implArg.dataTypeString)
                                                                    implF.returnArguments{idy}.dataTypeString=conArg.dataTypeString;
                                                                    implF.returnArguments{idy}.dimensionString=conArg.dimensionString;
                                                                    implF.returnArguments{idy}.passBy=conArg.passBy;
                                                                    implF.returnArguments{idy}.qualifier=conArg.qualifier;
                                                                    argFound=true;
                                                                end
                                                                break;
                                                            end
                                                        end
                                                        if~argFound

                                                            for idy=1:length(implF.arguments)
                                                                implArg=implF.arguments{idy};
                                                                impName=implArg.name;
                                                                if strcmp(conName,impName)
                                                                    if isempty(implArg.dataTypeString)
                                                                        implF.arguments{idy}.dataTypeString=conArg.dataTypeString;

                                                                        implF.arguments{idy}.passBy=coder.parser.PassByEnum.Pointer;
                                                                        implF.arguments{idy}.qualifier=conArg.qualifier;
                                                                    end
                                                                    break;
                                                                end
                                                            end
                                                        end
                                                    else
                                                        DAStudio.error('CoderFoundation:tfl:MissingDataTypeInConStr',conceptStr,conName);
                                                    end

                                                end



                                                function datatypeinfo=ParseDataTypeString(inputstring,argname)
                                                    isFixdt=any(strfind(inputstring,'fixdt'));

                                                    if~isFixdt
                                                        datatypeinfo=struct;
                                                        return;
                                                    else

                                                        argstring=regexprep(inputstring,'^\s*fixdt\s*\(','');
                                                        argstring=regexprep(argstring,'\)\s*$','');

                                                        splitstr=strtrim(strsplit(argstring,','));
                                                        numberofcells=numel(splitstr);



                                                        if(numberofcells==3)
                                                            datatypeinfo=struct('Signedness',splitstr{1},'WordLength',splitstr{2},...
                                                            'SlopeAdjustFactor',splitstr{3},'FixedExponent',splitstr{3},'Bias',{'0'});
                                                        elseif(numberofcells==4)
                                                            datatypeinfo=struct('Signedness',splitstr{1},'WordLength',splitstr{2},...
                                                            'Slope',splitstr{3},'Bias',splitstr{4});
                                                        elseif(numberofcells==5)
                                                            datatypeinfo=struct('Signedness',splitstr{1},'WordLength',splitstr{2},...
                                                            'SlopeAdjustFactor',splitstr{3},'FixedExponent',splitstr{4},'Bias',splitstr{5});


                                                            if strcmp(datatypeinfo.SlopeAdjustFactor,'*')||strcmp(datatypeinfo.SlopeAdjustFactor,'~')...
                                                                ||strcmp(datatypeinfo.FixedExponent,'*')||strcmp(datatypeinfo.FixedExponent,'~')
                                                                DAStudio.error('CoderFoundation:tfl:InvalidInputDataTypeString',inputstring,argname);
                                                            end
                                                        else
                                                            DAStudio.error('CoderFoundation:tfl:InvalidInputDataTypeString',inputstring,argname);
                                                        end

                                                        if strcmp(datatypeinfo.WordLength,'*')||strcmp(datatypeinfo.WordLength,'~')
                                                            DAStudio.error('CoderFoundation:tfl:InvalidInputDataTypeString',inputstring,argname);
                                                        end
                                                    end



