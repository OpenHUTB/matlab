function[status,errMsg]=ec_replacetype_consistency_check(modelName)












    status=1;
    errMsg='';

    isReplacementOn=rtwprivate('rtwattic','AtticData','isReplacementOn');
    if~isReplacementOn

        return
    end


    [repTypes,slTypes,builtinRepTypes]=ec_get_replacetype_mapping_list(modelName);
    rdouble=builtinRepTypes.double;
    rsingle=builtinRepTypes.single;
    rint32=builtinRepTypes.int32;
    rint16=builtinRepTypes.int16;
    rint8=builtinRepTypes.int8;
    ruint32=builtinRepTypes.uint32;
    ruint16=builtinRepTypes.uint16;
    ruint8=builtinRepTypes.uint8;
    rboolean=builtinRepTypes.boolean;
    rint=builtinRepTypes.int;
    ruint=builtinRepTypes.uint;
    rchar=builtinRepTypes.char;
    ruint64=builtinRepTypes.uint64;
    rint64=builtinRepTypes.int64;

    nonExistentAlias='';
    misMatchList={};
    misMatchMsg='';
    dupErrTxt='';

    invalidHeader='';
    invalidDataScope='';

    if~isempty(repTypes)
        designDataLocation=get_param(modelName,'DataDictionary');
    end

    for i=1:length(repTypes)

        [aBaseType,aHeader,aDataScope,aIsNested]=coder.internal.findBaseType(designDataLocation,repTypes{i});
        if~isempty(aBaseType)
            misMsg=DAStudio.message('RTW:mpt:ReplacementConsistMsg1',...
            repTypes{i},slTypes{i},repTypes{i},aBaseType,repTypes{i},slTypes{i},slTypes{i});








            switch slTypes{i}
            case{'double','single'}
                if~strcmp(aBaseType,slTypes{i})
                    if~ismember(repTypes{i},misMatchList)
                        misMatchList{end+1}=repTypes{i};
                        misMatchMsg=[misMatchMsg,misMsg];
                    end
                end
            case{'int32','int16','int8','int64'}
                if~strcmp(aBaseType,slTypes{i})
                    if~ismember(repTypes{i},misMatchList)
                        misMatchList{end+1}=repTypes{i};
                        misMatchMsg=[misMatchMsg,misMsg];
                    end
                end
            case{'uint32','uint16','uint8','uint64'}
                if~strcmp(aBaseType,slTypes{i})
                    if~ismember(repTypes{i},misMatchList)
                        misMatchList{end+1}=repTypes{i};
                        misMatchMsg=[misMatchMsg,misMsg];
                    end
                end
            case 'boolean'


                if(~strcmp(aBaseType,slTypes{i}))&&(~strcmp(aBaseType,'uint8'))&&(~strcmp(aBaseType,'int8'))
                    if(strcmp(get_param(modelName,'CreateSILPILBlock'),'SIL')&&strcmp(silblocktype,'legacy'))
                        if~ismember(repTypes{i},misMatchList)
                            misMatchList{end+1}=repTypes{i};
                            misMsgBool=DAStudio.message('RTW:mpt:ReplacementConsistMsgBoolERTSfcn',...
                            repTypes{i},repTypes{i},aBaseType);
                            misMatchMsg=[misMatchMsg,misMsgBool];
                        end
                    elseif(~strcmp(repTypes(i),ruint))&&(~strcmp(repTypes(i),rint))
                        intBits=get_param(modelName,'TargetBitPerInt');
                        if(~strcmp(aBaseType,['int',num2str(intBits)]))&&...
                            (~strcmp(aBaseType,['uint',num2str(intBits)]))
                            if~ismember(repTypes{i},misMatchList)
                                misMatchList{end+1}=repTypes{i};
                                misMsgBool=DAStudio.message('RTW:mpt:ReplacementConsistMsgBool',...
                                repTypes{i},repTypes{i},aBaseType);
                                misMatchMsg=[misMatchMsg,misMsgBool];
                            end
                        end
                    end
                end
            case 'int'
                intBits=get_param(modelName,'TargetBitPerInt');
                if~strcmp(aBaseType,[slTypes{i},num2str(intBits)])
                    if~ismember(repTypes{i},misMatchList)
                        misMatchList{end+1}=repTypes{i};
                        misMsg=DAStudio.message('RTW:mpt:ReplacementConsistMsg2',...
                        repTypes{i},slTypes{i},repTypes{i},aBaseType,slTypes{i},num2str(intBits),repTypes{i},...
                        num2str(intBits),slTypes{i});
                        misMatchMsg=[misMatchMsg,misMsg];
                    end
                end
            case 'uint'
                intBits=get_param(modelName,'TargetBitPerInt');
                if~strcmp(aBaseType,[slTypes{i},num2str(intBits)])
                    if~ismember(repTypes{i},misMatchList)
                        misMatchList{end+1}=repTypes{i};
                        misMsg=DAStudio.message('RTW:mpt:ReplacementConsistMsg2',...
                        repTypes{i},slTypes{i},repTypes{i},aBaseType,slTypes{i},num2str(intBits),repTypes{i},...
                        num2str(intBits),slTypes{i});
                        misMatchMsg=[misMatchMsg,misMsg];
                    end
                end
            case 'char'
                charBits=get_param(modelName,'TargetBitPerChar');
                if(~strcmp(aBaseType,['int',num2str(charBits)]))&&...
                    (~strcmp(aBaseType,['uint',num2str(charBits)]))
                    if~ismember(repTypes{i},misMatchList)
                        misMatchList{end+1}=repTypes{i};
                        misMsg=DAStudio.message('RTW:mpt:ReplacementConsistMsg2',...
                        repTypes{i},slTypes{i},repTypes{i},aBaseType,slTypes{i},num2str(charBits),repTypes{i},...
                        num2str(charBits),slTypes{i});
                        misMatchMsg=[misMatchMsg,misMsg];
                    end
                end
            otherwise
            end


            if(strcmp(aDataScope,'Exported'))
                invalidDataScope=[invalidDataScope,DAStudio.message(...
                'RTW:mpt:ReplacementConsistMsg7',repTypes{i})];


            elseif(aIsNested&&strcmp(aDataScope,'Imported'))
                invalidDataScope=[invalidDataScope,DAStudio.message(...
                'RTW:mpt:ReplacementConsistMsg8',repTypes{i})];
            elseif(aIsNested&&~isempty(aHeader))
                invalidDataScope=[invalidDataScope,DAStudio.message(...
                'RTW:mpt:ReplacementConsistMsg9',repTypes{i})];
            else

                try
                    slprivate('check_headerfile_string',aHeader);
                catch e
                    invalidHeader=[invalidHeader,DAStudio.message(...
                    'RTW:mpt:ReplacementConsistMsg5',aHeader,e.message)];
                end
            end

        else
            nonExistentAlias=[nonExistentAlias,DAStudio.message('RTW:mpt:ReplacementConsistMsg6',repTypes{i}),' '];
        end
    end

    if~isempty(nonExistentAlias)
        errMsg=DAStudio.message('RTW:mpt:ReplacementConsistMsg4',nonExistentAlias(1:end-2));
        status=0;
    end
    if~isempty(dupErrTxt)
        errMsg=[errMsg,dupErrTxt];
        status=0;
    end
    if~isempty(misMatchList)
        errMsg=[errMsg,misMatchMsg];
        status=0;
    end
    if~isempty(invalidDataScope)
        errMsg=[errMsg,invalidDataScope];
        status=0;
    end
    if~isempty(invalidHeader)
        errMsg=[errMsg,invalidHeader];
        status=0;
    end





