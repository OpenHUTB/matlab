function[codeTypeInfo,mdlTypeInfo]=getTypeInfo(systemName,coderID,sysCodeGenDir,sysSlprjDir)

    modelName=bdroot(systemName);
    configSet=getActiveConfigSet(modelName);
    mdlTypeInfo=iGetTypeInfo(configSet,coderID);

    codeTypeInfo=mdlTypeInfo;

    if nargin==4&&strcmp(coderID,pslink.verifier.ec.Coder.CODER_ID)
        hasError=false;
        typeInfo=fullfile(sysCodeGenDir,'rtwtypeschksum.mat');
        if exist(typeInfo,'file')
            try
                rtwTypeInfo=load(typeInfo);
                tmpInfo=codeTypeInfo;
                tmpInfo.CharNumBits=rtwTypeInfo.hardwareImp.CharNumBits;
                tmpInfo.ShortNumBits=rtwTypeInfo.hardwareImp.ShortNumBits;
                tmpInfo.IntNumBits=rtwTypeInfo.hardwareImp.IntNumBits;
                tmpInfo.LongNumBits=rtwTypeInfo.hardwareImp.LongNumBits;
                tmpInfo.LongLongNumBits=rtwTypeInfo.hardwareImp.LongLongNumBits;
                tmpInfo.FloatNumBits=32;
                tmpInfo.DoubleNumBits=64;
                tmpInfo.LongDoubleNumBits=64;
                if isfield(rtwTypeInfo.hardwareImp,'WordSize')
                    tmpInfo.WordNumBits=rtwTypeInfo.hardwareImp.WordSize;
                else
                    tmpInfo.WordNumBits=tmpInfo.IntNumBits;
                end
                tmpInfo.ShiftRightIntArith=rtwTypeInfo.hardwareImp.ShiftRightIntArith;
                tmpInfo.Endianess=rtwTypeInfo.hardwareImp.Endianess;
                tmpInfo.HWDeviceType=rtwTypeInfo.hardwareImp.HWDeviceType;
                codeTypeInfo=tmpInfo;
            catch Me %#ok<NASGU>
                hasError=true;
            end
            if~hasError
                return
            end
        end
        bInfo=fullfile(sysSlprjDir,'tmwinternal','binfo.mat');
        if exist(bInfo,'file')
            try
                rtwTypeInfo=load(bInfo);
                tmpInfo=iGetTypeInfo(rtwTypeInfo.infoStructConfigSet);
                codeTypeInfo=tmpInfo;
            catch Me %#ok<NASGU>
                hasError=true;
            end
            if~hasError
                return
            end
        end
    end


    function mdlTypeInfo=iGetTypeInfoFromFrontEndOptions(feOptions)
        target=feOptions.Target;
        switch target.Endianness
        case 'little'
            endianess='LittleEndian';
        case 'big'
            endianess='BigEndian';
        case 'middle'
            endianess='MiddleEndian';
        otherwise
            endianess='LittleEndian';
        end
        mdlTypeInfo=struct(...
        'IsCharSigned',true,...
        'CharNumBits',target.CharNumBits,...
        'ShortNumBits',target.ShortNumBits,...
        'IntNumBits',target.IntNumBits,...
        'LongNumBits',target.LongNumBits,...
        'LongLongNumBits',target.LongLongNumBits,...
        'FloatNumBits',target.FloatNumBits,...
        'DoubleNumBits',target.DoubleNumBits,...
        'LongDoubleNumBits',target.LongDoubleNumBits,...
        'WordNumBits',target.IntNumBits,...
        'PointerNumBits',target.PointerNumBits,...
        'Endianess',endianess,...
        'ShiftRightIntArith',true,...
        'HWDeviceType','Generic->MATLAB Host Computer'...
        );



        function mdlTypeInfo=iGetTypeInfo(configSet,coderID)
            if strcmp(coderID,pslink.verifier.sfcn.Coder.CODER_ID)
                feOpts=internal.cxxfe.util.getMexFrontEndOptions();
                mdlTypeInfo=iGetTypeInfoFromFrontEndOptions(feOpts);
                return
            elseif strcmp(coderID,pslink.verifier.slcc.Coder.CODER_ID)
                lang=get_param(configSet,'TargetLang');
                feOpts=CGXE.CustomCode.getFrontEndOptions(lang);
                mdlTypeInfo=iGetTypeInfoFromFrontEndOptions(feOpts);
                return
            end
            extraFlag=~strcmpi(get_param(configSet,'TargetHWDeviceType'),'Unspecified');
            if configSet.isValidParam('TargetUnknown')&&strcmp(get_param(configSet,'TargetUnknown'),'on')
                extraFlag=false;
            end

            if extraFlag&&strcmp(get_param(configSet,'ProdEqTarget'),'off')&&strcmp(coderID,pslink.verifier.ec.Coder.CODER_ID)
                mdlTypeInfo=struct(...
                'IsCharSigned',true,...
                'CharNumBits',get_param(configSet,'TargetBitPerChar'),...
                'ShortNumBits',get_param(configSet,'TargetBitPerShort'),...
                'IntNumBits',get_param(configSet,'TargetBitPerInt'),...
                'LongNumBits',get_param(configSet,'TargetBitPerLong'),...
                'LongLongNumBits',get_param(configSet,'TargetBitPerLongLong'),...
                'FloatNumBits',32,...
                'DoubleNumBits',64,...
                'LongDoubleNumBits',64,...
                'WordNumBits',get_param(configSet,'TargetBitPerInt'),...
                'PointerNumBits',get_param(configSet,'TargetBitPerInt'),...
                'Endianess',get_param(configSet,'TargetEndianess'),...
                'ShiftRightIntArith',strcmp(get_param(configSet,'TargetShiftRightIntArith'),'on'),...
                'HWDeviceType',get_param(configSet,'TargetHWDeviceType')...
                );
                if configSet.isValidParam('TargetWordSize')
                    mdlTypeInfo.WordNumBits=get_param(configSet,'TargetWordSize');
                end
                if configSet.isValidParam('TargetBitPerPointer')
                    mdlTypeInfo.PointerNumBits=get_param(configSet,'TargetBitPerPointer');
                end
                if configSet.isValidParam('TargetBitPerFloat')
                    mdlTypeInfo.FloatNumBits=get_param(configSet,'TargetBitPerFloat');
                end
                if configSet.isValidParam('TargetBitPerDouble')
                    mdlTypeInfo.DoubleNumBits=get_param(configSet,'TargetBitPerDouble');
                end
                if configSet.isValidParam('TargetBitPerDouble')
                    mdlTypeInfo.LongDoubleNumBits=get_param(configSet,'TargetBitPerDouble');
                end
            else
                mdlTypeInfo=struct(...
                'IsCharSigned',true,...
                'CharNumBits',get_param(configSet,'ProdBitPerChar'),...
                'ShortNumBits',get_param(configSet,'ProdBitPerShort'),...
                'IntNumBits',get_param(configSet,'ProdBitPerInt'),...
                'LongNumBits',get_param(configSet,'ProdBitPerLong'),...
                'LongLongNumBits',get_param(configSet,'ProdBitPerLongLong'),...
                'FloatNumBits',32,...
                'DoubleNumBits',64,...
                'LongDoubleNumBits',64,...
                'WordNumBits',get_param(configSet,'ProdBitPerInt'),...
                'PointerNumBits',get_param(configSet,'ProdBitPerInt'),...
                'Endianess',get_param(configSet,'ProdEndianess'),...
                'ShiftRightIntArith',strcmp(get_param(configSet,'ProdShiftRightIntArith'),'on'),...
                'HWDeviceType',get_param(configSet,'ProdHWDeviceType')...
                );
                if configSet.isValidParam('ProdWordSize')
                    mdlTypeInfo.WordNumBits=get_param(configSet,'ProdWordSize');
                end
                if configSet.isValidParam('ProdBitPerPointer')
                    mdlTypeInfo.PointerNumBits=get_param(configSet,'ProdBitPerPointer');
                end
                if configSet.isValidParam('ProdBitPerFloat')
                    mdlTypeInfo.FloatNumBits=get_param(configSet,'ProdBitPerFloat');
                end
                if configSet.isValidParam('ProdBitPerDouble')
                    mdlTypeInfo.DoubleNumBits=get_param(configSet,'ProdBitPerDouble');
                end
                if configSet.isValidParam('ProdBitPerDouble')
                    mdlTypeInfo.LongDoubleNumBits=get_param(configSet,'ProdBitPerDouble');
                end
            end


