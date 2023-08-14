function cfg=tlmgenerator_getconfigset(modelName,sysName)




























    try

        if(~exist('sysName','var'))
            cs=getActiveConfigSet(modelName);
        else
            cs=getActiveConfigSet(sysName);
        end
        tlmcc=cs.getPropOwner('tlmgComponentAddressing');
        pp=fieldnames(tlmcc.get());
        tlmg_props=pp(strmatch('tlmg',pp));
        tlmg_vals=cellfun(@(p)(tlmcc.getProp(p)),tlmg_props,'UniformOutput',false);

        tlmg_props{end+1}='tlmgCrossTargetOnOff';
        tlmg_vals{end+1}=tlmcc.getProp('tlmgCrossTargetOnOff');
        cfg=cell2struct(tlmg_vals,tlmg_props,1);






        if(strcmp(cfg.tlmgComponentSocketMapping,'One combined TLM socket for input data, output data, and control'))
            if(strcmp(cfg.tlmgComponentAddressing,'No memory map'))
                cfg.tlmgCommandStatusRegOnOff='off';
                cfg.tlmgTestAndSetRegOnOff='off';
                cfg.tlmgTunableParamRegOnOff='off';
            end
            cfg.tlmgComponentAddressingInput=cfg.tlmgComponentAddressing;
            cfg.tlmgComponentAddressingOutput=cfg.tlmgComponentAddressing;
            cfg.tlmgAutoAddressSpecTypeInput=cfg.tlmgAutoAddressSpecType;
            cfg.tlmgAutoAddressSpecTypeOutput=cfg.tlmgAutoAddressSpecType;

            cfg.tlmgCommandStatusRegOnOffInoutput=cfg.tlmgCommandStatusRegOnOff;
            cfg.tlmgTestAndSetRegOnOffInoutput=cfg.tlmgTestAndSetRegOnOff;
            cfg.tlmgTunableParamRegOnOffInoutput=cfg.tlmgTunableParamRegOnOff;

            cfg.tlmgFirstWriteTimeInput=cfg.tlmgFirstWriteTime;
            cfg.tlmgSubsequentWritesInBurstTimeInput=cfg.tlmgSubsequentWritesInBurstTime;
            cfg.tlmgFirstReadTimeOutput=cfg.tlmgFirstReadTime;
            cfg.tlmgSubsequentReadsInBurstTimeOutput=cfg.tlmgSubsequentReadsInBurstTime;
            cfg.tlmgFirstWriteTimeCtrl=cfg.tlmgFirstWriteTime;
            cfg.tlmgSubsequentWritesInBurstTimeCtrl=cfg.tlmgSubsequentWritesInBurstTime;
            cfg.tlmgFirstReadTimeCtrl=cfg.tlmgFirstReadTime;
            cfg.tlmgSubsequentReadsInBurstTimeCtrl=cfg.tlmgSubsequentReadsInBurstTime;
        end

        if(strcmp(cfg.tlmgComponentSocketMapping,'Defined by imported IP-XACT file'))
            cfg.tlmgCommandStatusRegOnOff='off';
            cfg.tlmgTestAndSetRegOnOff='off';
            cfg.tlmgTunableParamRegOnOff='off';
            cfg.tlmgIrqPortOnOff='off';

            cfg.tlmgCommandStatusRegOnOffInoutput=cfg.tlmgCommandStatusRegOnOff;
            cfg.tlmgTestAndSetRegOnOffInoutput=cfg.tlmgTestAndSetRegOnOff;
            cfg.tlmgTunableParamRegOnOffInoutput=cfg.tlmgTunableParamRegOnOff;

            cfg.tlmgFirstWriteTimeInput=cfg.tlmgFirstWriteTime;
            cfg.tlmgSubsequentWritesInBurstTimeInput=cfg.tlmgSubsequentWritesInBurstTime;
            cfg.tlmgFirstReadTimeOutput=cfg.tlmgFirstReadTime;
            cfg.tlmgSubsequentReadsInBurstTimeOutput=cfg.tlmgSubsequentReadsInBurstTime;
            cfg.tlmgFirstWriteTimeCtrl=cfg.tlmgFirstWriteTime;
            cfg.tlmgSubsequentWritesInBurstTimeCtrl=cfg.tlmgSubsequentWritesInBurstTime;
            cfg.tlmgFirstReadTimeCtrl=cfg.tlmgFirstReadTime;
            cfg.tlmgSubsequentReadsInBurstTimeCtrl=cfg.tlmgSubsequentReadsInBurstTime;

            if(~exist(cfg.tlmgIPXactPath,'file'))
                error(message('TLMGenerator:TLMTargetCC:BadIPXactPath',cfg.tlmgIPXactPath));
            end

        else
            cfg.tlmgSCMLOnOff='off';
            cfg.tlmgIPXactUnmapped='off';
            cfg.tlmgIPXactUnmappedSig='off';
        end

        if(strcmp(cfg.tlmgSCMLOnOff,'on'))
            cfg.tlmgExt='_scml';
        else
            cfg.tlmgExt='_tlm';
        end

        if(strcmp(cfg.tlmgCrossTargetOnOff,'on'))
            cfg.tlmgGenerateTestbenchOnOff='off';
        end

        cfg.tlmgTbExt=[cfg.tlmgExt,'_tb'];
        cfg.tlmgDocExt=[cfg.tlmgExt,'_doc'];



        if(~isempty(cfg.tlmgUserTagForNaming)),prefix='_';
        else prefix='';
        end
        userExt=[prefix,cfg.tlmgUserTagForNaming,cfg.tlmgExt];
        userTbExt=[prefix,cfg.tlmgUserTagForNaming,cfg.tlmgTbExt];
        userDocExt=[prefix,cfg.tlmgUserTagForNaming,cfg.tlmgDocExt];

        cfg.tlmgRtwCompName=modelName;
        cfg.tlmgTlmCompName=[modelName,userExt];
        cfg.tlmgTbCompName=[modelName,userTbExt];
        cfg.tlmgDocCompName=[modelName,userDocExt];



        cfg.tlmgMatlabIncludePath=fullfile(matlabroot,'extern','include');
        cfg.tlmgSimulinkIncludePath=fullfile(matlabroot,'simulink','include');
        cfg.tlmgRTWIncludePath=fullfile(matlabroot,'rtw','c','src');
        cfg.tlmgMatlabLibPathGlnx=fullfile(matlabroot,'bin',computer('arch'));
        cfg.tlmgMatlabLibPathGlnx2=fullfile(matlabroot,'sys','os',computer('arch'));
        cfg.tlmgMatlabLibPathWin=fullfile(matlabroot,'extern','lib',computer('arch'),'microsoft');
        if(strcmp(computer,'PCWIN64'))
            cfg.tlmgWinDef='WIN64';
            cfg.tlmgWinMachine='X64';
            cfg.tlmgWinPlatform='x64';
        else
            cfg.tlmgWinDef='WIN32';
            cfg.tlmgWinMachine='X86';
            cfg.tlmgWinPlatform='Win32';
        end

        if(strcmp(cfg.tlmgVerboseTbMessagesOnOff,'on'))
            cfg.tlmgTbVerbosity='tlmgPrintAll';
        else
            cfg.tlmgTbVerbosity='tlmgPrintTerse';
        end


        cfg.tlmgOutDir=[cfg.tlmgRtwCompName,'_VP'];

        cfg.tlmgCoreOutDir=fullfile(cfg.tlmgOutDir,cfg.tlmgRtwCompName);
        cfg.tlmgCoreSrcDir=fullfile(cfg.tlmgCoreOutDir,'src');
        cfg.tlmgCoreIncDir=fullfile(cfg.tlmgCoreOutDir,'include');
        cfg.tlmgCoreUtilsDir=fullfile(cfg.tlmgCoreOutDir,'utils');
        cfg.tlmgCoreLibDir=fullfile(cfg.tlmgCoreOutDir,'lib');
        cfg.tlmgCoreObjDir=fullfile(cfg.tlmgCoreOutDir,'obj');

        cfg.tlmgCompOutDir=fullfile(cfg.tlmgOutDir,cfg.tlmgTlmCompName);
        cfg.tlmgCompSrcDir=fullfile(cfg.tlmgCompOutDir,'src');
        cfg.tlmgCompIncDir=fullfile(cfg.tlmgCompOutDir,'include');
        cfg.tlmgCompLibDir=fullfile(cfg.tlmgCompOutDir,'lib');
        cfg.tlmgCompObjDir=fullfile(cfg.tlmgCompOutDir,'obj');

        cfg.tlmgTbOutDir=fullfile(cfg.tlmgOutDir,cfg.tlmgTbCompName);
        cfg.tlmgTbSrcDir=fullfile(cfg.tlmgTbOutDir,'src');
        cfg.tlmgTbIncDir=fullfile(cfg.tlmgTbOutDir,'include');
        cfg.tlmgTbUtilsDir=fullfile(cfg.tlmgTbOutDir,'utils');
        cfg.tlmgTbVecDir=fullfile(cfg.tlmgTbOutDir,'vectors');
        cfg.tlmgTbObjDir=fullfile(cfg.tlmgTbOutDir,'obj');

        cfg.tlmgDocOutDir=fullfile(cfg.tlmgOutDir,cfg.tlmgDocCompName);
        cfg.tlmgDocHtmlDir=fullfile(cfg.tlmgDocOutDir,'html');


        cfg.ProdWordSize=cs.getProp('ProdWordSize');
        cfg.RTWVerbose=cs.getProp('RTWVerbose');
        cfg.GenerateReport=cs.getProp('GenerateReport');
        cfg.IsERTTarget=cs.getProp('IsERTTarget');
        if(strcmp(cfg.IsERTTarget,'on'))
            cfg.isReusableCode=cs.getProp('MultiInstanceERTCode');
        else
            cfg.isReusableCode='off';
        end

    catch ME
        l_me=MException('TLMGenerator:build','TLMG getconfigset: %s',ME.message);
        cfg=struct([]);
        setappdata(0,'tlmgME',l_me.message);
        throw(l_me);
    end
end
