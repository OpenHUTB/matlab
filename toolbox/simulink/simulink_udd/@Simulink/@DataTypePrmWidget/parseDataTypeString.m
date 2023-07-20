
function res=parseDataTypeString(udtString,dtaItems)













































































    res.indexSpecMethod=0;
    res.isInherit=false;
    res.indexInherit=-1;
    res.isBuiltin=false;
    res.indexBuiltin=-1;
    res.isFixPt=false;
    res.fixptProps=[];
    res.isEnumType=false;
    res.isBusType=false;
    if slfeature('SupportImageInDTA')==1
        res.isImageType=false;
        res.imageTypeProps=[];
    end
    res.isConnectionBusType=false;
    res.isConnectionType=false;
    if slfeature('SLValueType')==1
        res.isValueTypeType=false;
    end
    res.isExtra=false;
    res.extraProps=[];
    res.isExpress=false;
    res.errMsg.id='UDTNoError';
    res.errMsg.msg='';


    dtaItems=setDefaultDtaItems(dtaItems);


    singleSpaceUdtString=removeExtraSpaces(udtString);

    numSpecMethods=-1;

    [answer,index,errorId]=isInherit(singleSpaceUdtString,dtaItems.inheritRules);
    if~isempty(dtaItems.inheritRules)
        numSpecMethods=numSpecMethods+1;
    end
    if strcmp(errorId,'UDTNoError')
        if answer
            res.isInherit=true;
            res.indexInherit=index;
            res.indexSpecMethod=numSpecMethods;
            return
        end
    else
        res.errMsg.id=errorId;
        res.errMsg.msg=DAStudio.message(errorId);
        res.str=udtString;
        res.isExpress=true;
        return;
    end


    [answer,index,res.fixptProps,errorId]=isBuiltin(singleSpaceUdtString,dtaItems.builtinTypes);
    if~isempty(dtaItems.builtinTypes)
        numSpecMethods=numSpecMethods+1;
    end
    if strcmp(errorId,'UDTNoError')
        if answer
            res.isBuiltin=true;
            res.indexBuiltin=index;
            res.indexSpecMethod=numSpecMethods;
            return
        end
    else
        res.errMsg.id=errorId;
        res.errMsg.msg=DAStudio.message(errorId);
        res.str=udtString;
        res.isExpress=true;
        return;
    end



    [answer,res.fixptProps,errorId]=isSimpleFixdt(singleSpaceUdtString,...
    dtaItems.scalingModes,...
    dtaItems.signModes,...
    dtaItems.tattoos);
    if~isempty(dtaItems.scalingModes)
        numSpecMethods=numSpecMethods+1;
    end
    if strcmp(errorId,'UDTNoError')
        if answer





            res.isFixPt=true;
            res.indexSpecMethod=numSpecMethods;
            return
        end
    else
        res.errMsg.id=errorId;
        res.errMsg.msg=DAStudio.message(errorId);
        res.str=udtString;
        res.isExpress=true;
        return;
    end


    [answer,res.enumClassName,errorId]=isEnumType(singleSpaceUdtString,dtaItems.supportsEnumType);
    if dtaItems.supportsEnumType
        numSpecMethods=numSpecMethods+1;
    end
    if strcmp(errorId,'UDTNoError')
        if answer
            res.isEnumType=true;
            res.indexSpecMethod=numSpecMethods;
            return;
        end
    else
        res.errMsg.id=errorId;
        res.errMsg.msg=DAStudio.message(errorId);
        res.str=udtString;
        res.isExpress=true;
        return;
    end


    [answer,res.busObjectName,errorId]=isBusType(singleSpaceUdtString,dtaItems.supportsBusType);
    if(dtaItems.supportsBusType)
        numSpecMethods=numSpecMethods+1;
    end
    if strcmp(errorId,'UDTNoError')
        if answer
            res.isBusType=true;
            res.indexSpecMethod=numSpecMethods;
            return;
        end
    else
        if~(isfield(dtaItems,'supportsConnectionBusType')&&dtaItems.supportsConnectionBusType)
            res.errMsg.id=errorId;
            res.errMsg.msg=DAStudio.message(errorId);
            res.str=udtString;
            res.isExpress=true;
            return;
        end
    end


    if slfeature('SupportImageInDTA')==1
        [answer,res.imageTypeProps,errorId]=isImageType(singleSpaceUdtString,dtaItems.supportsImageDataType);
        if(dtaItems.supportsImageDataType)
            numSpecMethods=numSpecMethods+1;
        end
        if strcmp(errorId,'UDTNoError')
            if answer
                res.isImageType=true;
                res.indexSpecMethod=numSpecMethods;
                return;
            end
        else
            res.errMsg.id=errorId;
            res.errMsg.msg=DAStudio.message(errorId);
            res.str=udtString;
            res.isExpress=true;
            return;
        end
    end


    [answer,res.connectionBusObjectName,errorId]=isConnBusType(singleSpaceUdtString,dtaItems.supportsConnectionBusType);
    if(dtaItems.supportsConnectionBusType)
        numSpecMethods=numSpecMethods+1;
    end
    if strcmp(errorId,'UDTNoError')
        if answer
            res.isConnectionBusType=true;
            res.indexSpecMethod=numSpecMethods;
            return;
        end
    else
        res.errMsg.id=errorId;
        res.errMsg.msg=DAStudio.message(errorId);
        res.str=udtString;
        res.isExpress=true;
        return;
    end


    if slfeature('SLValueType')==1
        [answer,res.valueTypeName,errorId]=isValueTypeType(singleSpaceUdtString,dtaItems.supportsValueTypeType);
        if(dtaItems.supportsValueTypeType)
            numSpecMethods=numSpecMethods+1;
        end
        if strcmp(errorId,'UDTNoError')
            if answer
                res.isValueTypeType=true;
                res.indexSpecMethod=numSpecMethods;
                return;
            end
        else
            res.errMsg.id=errorId;
            res.errMsg.msg=DAStudio.message(errorId);
            res.str=udtString;
            res.isExpress=true;
            return;
        end
    end


    if slfeature('CUSTOM_BUSES')==1
        [answer,res.domainName,errorId]=isConnType(singleSpaceUdtString,dtaItems.supportsConnectionType);
        if(dtaItems.supportsConnectionType)
            numSpecMethods=numSpecMethods+1;
        end
        if strcmp(errorId,'UDTNoError')
            if answer
                res.isConnectionType=true;
                res.indexSpecMethod=numSpecMethods;
                return;
            end
        else
            res.errMsg.id=errorId;
            res.errMsg.msg=DAStudio.message(errorId);
            res.str=udtString;
            res.isExpress=true;
            return;
        end
    end




    if dtaItems.allowsExpression
        numSpecMethods=numSpecMethods+1;
        res.indexSpecMethod=numSpecMethods;
    end

    if isfield(dtaItems,'extras')

        [answer,res.extraProps,errorId]=isExtra(singleSpaceUdtString,dtaItems.extras);


        numSpecMethods=numSpecMethods+1;
        if strcmp(errorId,'UDTNoError')
            if answer
                res.isExtra=true;
                res.indexSpecMethod=numSpecMethods+res.extraProps.indexExtra;
                return;
            end
        else
            res.errMsg.id=errorId;
            res.errMsg.msg=DAStudio.message(errorId);
            res.str=udtString;
            res.isExpress=true;
            return;
        end
    end


    res.str=udtString;
    res.isExpress=true;





    if res.isExpress&&~dtaItems.allowsExpression
        res.errMsg.id='Simulink:dialog:UDTExprNotAllowedErr';
        res.errMsg.msg=DAStudio.message(res.errMsg.id);
        res.str=udtString;
    end





















    function[answer,index,errorId]=isInherit(udtString,inheritRules)

        answer=false;
        index=-1;
        errorId='UDTNoError';

        if~strncmp(udtString,'Inherit:',8)

            return;
        else
            idx=find(strcmp(udtString,inheritRules),1);

            if length(idx)==1
                idx=idx-1;
                answer=true;
                index=idx;
            else
                errorId='Simulink:dialog:UDTInvalidInheritErr';
            end
        end





















        function[answer,index,fixptProps,errorId]=isBuiltin(udtString,builtinTypes)

            answer=false;
            index=-1;
            fixptProps=[];
            errorId='UDTNoError';
            isDTOSet=false;

            idx=find(strcmp(udtString,builtinTypes));
            if isempty(idx)


                udtWithoutSpace=strrep(udtString,' ','');
                for i=1:length(builtinTypes)
                    matchStr=['fixdt(''',builtinTypes{i},''',''DataTypeOverride'',''Off'')'];
                    isMatchStr=find(strncmpi(udtWithoutSpace,matchStr,length(matchStr)));
                    if isMatchStr

                        isDTOSet=true;
                        idx=i;
                        break;
                    end
                end
            end

            if length(idx)==1
                idx=idx-1;
                answer=true;
                index=idx;
                if isDTOSet
                    fixptProps.datatypeoverride='''Off''';
                else
                    fixptProps.datatypeoverride='''Inherit''';
                end
            else
                allBuiltinTypes={'double','single','int8','uint8',...
                'int16','uint16','int32','uint32',...
                'int64','uint64','boolean'};
                if any(strcmp(udtString,allBuiltinTypes),1)
                    errorId='Simulink:dialog:UDTInvalidBuiltinErr';
                end

            end


























            function[answer,res,errorId]=isSimpleFixdt(udtString,scalingModes,signModes,tattoos)


                answer=false;

                res.signed=0;
                res.scalingMode=0;
                res.wordLength='16';
                res.fractionLength='0';
                res.slope='2^0';
                res.bias='0';
                res.datatypeoverride='Inherit';
                res.openAssistant=false;

                errorId='UDTNoError';


                if isequal(udtString,'Fixed point ...')
                    answer=true;
                    res.openAssistant=true;
                    return;
                end

                udtString=removeNonEssentialWhiteSpaces(udtString);


                T=mtree(udtString);
                if isempty(T)||~isempty(mtfind(T,'Kind','ERR'))
                    return;
                end




                if strcmp(T.root.kind,'DCALL')||strcmp(T.root.kind,'BANG')
                    return;
                end


                call=T.root.Arg;
                if~strcmp(call.kind,'CALL')
                    return;
                end


                if~strcmp(call.Left.string,'fixdt')
                    return;
                end


                if isempty(scalingModes)
                    errorId='Simulink:dialog:UDTFixedPointNotSupportedErr';
                    return;
                end


                arg=call.Right;
                numArgs=arg.List.count;
                if numArgs<2||numArgs>6
                    return;
                end


                arg=call.Right;
                if isempty(arg)
                    return;
                end

                switch arg.kind
                case 'INT'
                    switch arg.string
                    case '0'
                        sign='UDTUnsignedSign';
                    case '1'
                        sign='UDTSignedSign';
                    otherwise
                        return;
                    end
                case 'LB'

                    if~arg.Arg.Arg.isempty
                        return;
                    end
                    sign='UDTInheritSign';

                otherwise
                    return;
                end


                res.signed=find(strcmp(sign,signModes),1);
                if isempty(res.signed)
                    errorId='Simulink:dialog:UDTInvalidSignModeErr';
                    return;
                else
                    res.signed=res.signed-1;
                end

                arg2=arg.Next;
                res.wordLength=udtString(arg2.lefttreepos:arg2.righttreepos);
                if~isempty(tattoos.wordLength)&&~isequal(tattoos.wordLength,res.wordLength)
                    errorId='Simulink:dialog:UDTWordLengthFixedErr';
                    return;
                end

                arg3=arg2.Next;
                if isempty(arg3)
                    if length(scalingModes)==1&&strcmp(scalingModes{1},'UDTIntegerMode')
                        scalingMode='UDTIntegerMode';
                    else
                        scalingMode='UDTBestPrecisionMode';
                    end
                else
                    arg3_str=udtString(arg3.lefttreepos:arg3.righttreepos);

                    if isempty(arg3.Next)
                        scalingMode='UDTBinaryPointMode';
                        if~isempty(tattoos.fractionLength)&&~isequal(tattoos.fractionLength,arg3_str)
                            errorId='Simulink:dialog:UDTFractionLengthFixedErr';
                            return;
                        else
                            res.fractionLength=arg3_str;
                        end
                    else
                        if strcmpi(arg3_str,'''DataTypeOverride''')
                            scalingMode='UDTBestPrecisionMode';
                            if~isempty(arg3.Next)
                                arg4=arg3.Next;
                                arg4_str=udtString(arg4.lefttreepos:arg4.righttreepos);
                                res.datatypeoverride=arg4_str;
                            else
                                errorId='Simulink:dialog:UDTFractionLengthFixedErr';
                                return;
                            end
                        else
                            arg4=arg3.Next;
                            arg4_str=udtString(arg4.lefttreepos:arg4.righttreepos);

                            if strcmpi(arg4_str,'''DataTypeOverride''')
                                scalingMode='UDTBinaryPointMode';
                                if~isempty(tattoos.fractionLength)&&~isequal(tattoos.fractionLength,arg3_str)
                                    errorId='Simulink:dialog:UDTFractionLengthFixedErr';
                                    return;
                                else
                                    res.fractionLength=arg3_str;
                                end
                                if~isempty(arg4.Next)
                                    arg5=arg4.Next;
                                    arg5_str=udtString(arg5.lefttreepos:arg5.righttreepos);
                                    res.datatypeoverride=arg5_str;
                                end
                            else
                                scalingMode='UDTSlopeBiasMode';
                                if~isempty(tattoos.slope)&&~isequal(tattoos.slope,arg3_str)
                                    errorId='Simulink:dialog:UDTSlopeFixedErr';
                                    return;
                                else
                                    res.slope=arg3_str;
                                end
                                if~isempty(tattoos.bias)&&~isequal(tattoos.bias,arg4_str)
                                    errorId='Simulink:dialog:UDTBiasFixedErr';
                                    return;
                                else
                                    res.bias=arg4_str;
                                end
                                if~isempty(arg4.Next)
                                    arg5=arg4.Next;
                                    arg5_str=udtString(arg5.lefttreepos:arg5.righttreepos);
                                    if strcmpi(arg5_str,'''DataTypeOverride''')
                                        if~isempty(arg5.Next)
                                            arg6=arg5.Next;
                                            arg6_str=udtString(arg6.lefttreepos:arg6.righttreepos);
                                            res.datatypeoverride=arg6_str;
                                        end
                                    else


                                        return;
                                    end
                                end
                            end
                        end
                    end
                end

                idx=find(strcmp(scalingMode,scalingModes));

                if length(idx)==1
                    answer=true;
                    idx=idx-1;
                    res.scalingMode=idx;
                end





















                function[answer,enumClassName,errorId]=isEnumType(udtString,supportsEnumType)

                    answer=false;
                    errorId='UDTNoError';
                    enumClassName='<class name>';
                    enumHeader='Enum:';
                    enumHeaderLen=length(enumHeader);

                    if~strncmp(udtString,enumHeader,enumHeaderLen)

                        return;
                    end


                    if~supportsEnumType
                        errorId='Simulink:dialog:UDTEnumNotSupportedErr';
                        return;
                    end


                    if~strcmp(udtString,enumHeader)

                        enumClassName=removeExtraSpaces(udtString(enumHeaderLen+1:end));
                    end

                    answer=true;
                    return;





















                    function[answer,busObjectName,errorId]=isBusType(udtString,supportsBusType)

                        answer=false;
                        errorId='UDTNoError';
                        busObjectName='<object name>';
                        busHeader='Bus:';
                        busHeaderLen=length(busHeader);

                        if~strncmp(udtString,busHeader,busHeaderLen)

                            return;
                        end


                        if~supportsBusType
                            errorId='Simulink:dialog:UDTBusNotSupportedErr';
                            return;
                        end


                        if~strcmp(udtString,busHeader)

                            busObjectName=removeExtraSpaces(udtString(busHeaderLen+1:end));
                        end

                        answer=true;
                        return;





















                        function[answer,res,errorId]=isImageType(udtString,supportsImageType)

                            answer=false;

                            res.Rows='480';
                            res.Cols='640';
                            res.Channels='3';
                            res.ColorFormat=0;
                            res.Layout=0;
                            res.ClassUnderlying=0;

                            errorId='UDTNoError';

                            ImageHeader='Simulink.ImageType';
                            ImageHeaderLen=length(ImageHeader);

                            if~strncmp(udtString,ImageHeader,ImageHeaderLen)

                                return;
                            end


                            if~supportsImageType
                                errorId='Simulink:dialog:UDTImageNotSupportedErr';
                                return;
                            end


                            udtString=removeNonEssentialWhiteSpaces(udtString);


                            T=mtree(udtString);
                            if strcmp(T.root.kind,'DCALL')||strcmp(T.root.kind,'BANG')
                                return;
                            end


                            call=T.root.Arg;


                            arg=call.Right;
                            if isempty(arg)
                                return;
                            end

                            numArgs=arg.List.count;
                            if numArgs~=9&&numArgs~=3
                                return;
                            end

                            if~strcmp(arg.kind,'INT')&&~strcmp(arg.kind,'CALL')
                                return;
                            end
                            res.Rows=udtString(arg.lefttreepos:arg.righttreepos);


                            arg2=arg.Next;
                            if~strcmp(arg2.kind,'INT')&&~strcmp(arg2.kind,'CALL')
                                return;
                            end
                            res.Cols=udtString(arg2.lefttreepos:arg2.righttreepos);


                            arg3=arg2.Next;
                            if~strcmp(arg3.kind,'INT')&&~strcmp(arg3.kind,'CALL')
                                return;
                            end
                            res.Channels=udtString(arg3.lefttreepos:arg3.righttreepos);


                            if numArgs==3
                                answer=true;
                                return;
                            end


                            arg4=arg3.Next;
                            if~strcmp(arg4.kind,'CHARVECTOR')
                                return;
                            end
                            colorFormatAttribute=strip(arg4.string,'''');
                            if~strcmp('ColorFormat',colorFormatAttribute)
                                return;
                            end


                            arg5=arg4.Next;
                            if~strcmp(arg5.kind,'CHARVECTOR')
                                return;
                            end
                            colorFormats=getImageTypeFieldList('colorFormat');
                            colorFormat=find(strcmp(colorFormats,strip(arg5.string,'''')));
                            if isempty(colorFormat)
                                return;
                            end
                            res.ColorFormat=colorFormat-1;


                            arg6=arg5.Next;
                            if~strcmp(arg6.kind,'CHARVECTOR')
                                return;
                            end
                            layoutAttribute=strip(arg6.string,'''');
                            if~strcmp('Layout',layoutAttribute)
                                return;
                            end


                            arg7=arg6.Next;
                            if~strcmp(arg7.kind,'CHARVECTOR')
                                return;
                            end
                            layouts=getImageTypeFieldList('layout');
                            layout=find(strcmp(layouts,strip(arg7.string,'''')));
                            if isempty(layout)
                                return;
                            end
                            res.Layout=layout-1;


                            arg8=arg7.Next;
                            if~strcmp(arg8.kind,'CHARVECTOR')
                                return;
                            end
                            classUnderlyingAttribute=strip(arg8.string,'''');
                            if~strcmp('ClassUnderlying',classUnderlyingAttribute)
                                return;
                            end


                            arg9=arg8.Next;
                            if~strcmp(arg9.kind,'CHARVECTOR')
                                return;
                            end
                            classUnderlyings=getImageTypeFieldList('classUnderlying');
                            classUnderlying=find(strcmp(classUnderlyings,strip(arg9.string,'''')));
                            if isempty(classUnderlying)
                                return;
                            end
                            res.ClassUnderlying=classUnderlying-1;
                            answer=true;
                            return;







                            function fieldList=getImageTypeFieldList(fieldName)
                                switch fieldName
                                case 'colorFormat'
                                    fieldList={DAStudio.message('Simulink:dialog:UDTColorFormatRGB'),...
                                    DAStudio.message('Simulink:dialog:UDTColorFormatBGR'),...
                                    DAStudio.message('Simulink:dialog:UDTColorFormatBGRA'),...
                                    DAStudio.message('Simulink:dialog:UDTColorFormatGrayscale')};
                                case 'layout'
                                    fieldList={DAStudio.message('Simulink:dialog:UDTLayoutColumnMajorPlanar'),...
                                    DAStudio.message('Simulink:dialog:UDTLayoutRowMajorInterleaved')};
                                case 'classUnderlying'
                                    fieldList={DAStudio.message('Simulink:dialog:UDTClassUnderlyinguint8'),...
                                    DAStudio.message('Simulink:dialog:UDTClassUnderlyinguint16'),...
                                    DAStudio.message('Simulink:dialog:UDTClassUnderlyinguint32'),...
                                    DAStudio.message('Simulink:dialog:UDTClassUnderlyingint8'),...
                                    DAStudio.message('Simulink:dialog:UDTClassUnderlyingint16'),...
                                    DAStudio.message('Simulink:dialog:UDTClassUnderlyingint32'),...
                                    DAStudio.message('Simulink:dialog:UDTClassUnderlyingsingle'),...
                                    DAStudio.message('Simulink:dialog:UDTClassUnderlyingdouble')};
                                otherwise
                                end



















                                function[answer,connectionBusObjectName,errorId]=isConnBusType(udtString,supportsConnectionBusType)

                                    answer=false;
                                    errorId='UDTNoError';
                                    connectionBusObjectName='<object name>';
                                    busHeader='Bus:';
                                    busHeaderLen=length(busHeader);

                                    if~strncmp(udtString,busHeader,busHeaderLen)

                                        return;
                                    end


                                    if~supportsConnectionBusType
                                        errorId='Simulink:dialog:UDTConnectionBusNotSupportedErr';
                                        return;
                                    end


                                    if~strcmp(udtString,busHeader)

                                        connectionBusObjectName=removeExtraSpaces(udtString(busHeaderLen+1:end));
                                    end

                                    answer=true;
                                    return;





















                                    function[answer,valueTypeName,errorId]=isValueTypeType(udtString,supportsValueTypeType)

                                        answer=false;
                                        errorId='UDTNoError';
                                        valueTypeName='<object name>';
                                        valueTypeHeader='ValueType:';
                                        valueTypeHeaderLen=length(valueTypeHeader);

                                        if~strncmp(udtString,valueTypeHeader,valueTypeHeaderLen)

                                            return;
                                        end


                                        if~supportsValueTypeType
                                            errorId='Simulink:dialog:UDTValueTypeNotSupportedErr';
                                            return;
                                        end

                                        if~strcmp(udtString,valueTypeHeader)

                                            valueTypeName=removeExtraSpaces(udtString(valueTypeHeaderLen+1:end));
                                        end

                                        answer=true;
                                        return;




















                                        function[answer,domainName,errorId]=isConnType(udtString,supportsConnectionType)

                                            answer=false;
                                            errorId='UDTNoError';
                                            domainName='<object name>';
                                            connHeader='Connection:';
                                            connHeaderLen=length(connHeader);

                                            if~strncmp(udtString,connHeader,connHeaderLen)

                                                return;
                                            end


                                            if~supportsConnectionType
                                                errorId='Simulink:dialog:UDTConnectionNotSupportedErr';
                                                return;
                                            end


                                            if~strcmp(udtString,connHeader)

                                                domainName=removeExtraSpaces(udtString(connHeaderLen+1:end));
                                            end

                                            answer=true;
                                            return;





















                                            function[answer,res,errorId]=isExtra(udtString,extras)


                                                answer=false;
                                                res.indexExtra=-1;
                                                res.exprExtra='';

                                                errorId='UDTNoError';

                                                [extraStr,remainder]=strtok(udtString,':');
                                                if isempty(remainder)
                                                    return
                                                end
                                                for i=1:length(extras)
                                                    if strcmp(extraStr,extras(i).header)
                                                        res.indexExtra=i-1;
                                                        if length(remainder)>1
                                                            if remainder(2)==' '
                                                                res.exprExtra=remainder(3:end);
                                                            else
                                                                res.exprExtra=remainder(2:end);
                                                            end
                                                        end
                                                        answer=true;
                                                        return;
                                                    end
                                                end
                                                errorId='Simulink:dialog:UDTInvalidDataTypeModeErr';







                                                function newStr=removeExtraSpaces(oldStr)



                                                    newStr=regexprep(oldStr,'\s+',' ');


                                                    newStr=regexprep(newStr,'^ ','');


                                                    newStr=regexprep(newStr,' $','');







                                                    function newStr=removeNonEssentialWhiteSpaces(oldStr)



                                                        newStr=regexprep(oldStr,'\s*([\(,\)])\s*','$1');






