function createSFunctionModel(isSFunctionCodeFormat,...
    modelName,...
    sFunctionCreateModel,...
    sFunctionUseParamValues,...
    isERTSfunction,generateCodeOnly)






    if generateCodeOnly||strcmp(get_param(modelName,'GenerateMakefile'),'off')
        return
    end




    bCreateSFunctionModel=0;
    isERTSILBlock=false;

    if isSFunctionCodeFormat


        if isempty(sFunctionCreateModel)
            bCreateSFunctionModel=0;
        else
            bCreateSFunctionModel=strcmp(sFunctionCreateModel,'1');
        end
    elseif isERTSfunction
        bCreateSFunctionModel=1;
        isERTSILBlock=true;
    end

    if bCreateSFunctionModel


        if isempty(sFunctionUseParamValues)
            useparamvalues=0;
        else
            useparamvalues=strcmp(sFunctionUseParamValues,'1');
        end
        newmodelname=rtwprivate('newmodelfromold',modelName);
        newblockname=[newmodelname,'/Generated S-Function'];
        currdir=pwd;
        restorePwd=onCleanup(@()cd(currdir));

        fgCfg=Simulink.fileGenControl('getConfig');
        lAnchorFolder=fgCfg.CodeGenFolder;
        cd(lAnchorFolder);




        cmd='load_system(''rtwlib'')';
        eval(cmd);
        add_block('rtwlib/S-Function Target/Generated S-Function',newblockname);
        if isERTSILBlock


            set_param(newblockname,'MaskHelp',...
            'helpview([docroot ''/toolbox/ecoder/helptargets.map''], ''SIL_block'');');
        end
        locSetupSfcnTunableParameters(modelName,...
        useparamvalues,newblockname);
        locSetupSfcnPortLabels(modelName,newblockname);
        open_system(newmodelname);
        cd(currdir);
    end

end










function locSetupSfcnTunableParameters(modelName,useparamvalues,block)
    rtwsfcnStruct=['rtwsfcn_',modelName];
    sfcnName=[modelName,'_sf'];


    maskVariables=get_param(block,'maskvariables');
    if isempty(maskVariables)
        maskValues={};
        origNumVars=0;
    else
        expectedVars='rtw_sf_name=&1;showVar=@2;';
        if~isequal(maskVariables,expectedVars)
            assertMsg=['Assert: Error in block ','',block,'',...
            'Unexpected mask variables in generated S-Function'];
            assert(false,assertMsg);
        end


        maskPrompts=get_param(block,'maskprompts');
        maskValues={sfcnName;'off'};
        origNumVars=2;
    end

    if evalin('base',['exist(''',rtwsfcnStruct,''')'])==1
        eval(['global ',rtwsfcnStruct]);
        rtwSfcnStr=eval(rtwsfcnStruct);
        rtwsfcnstructIsGlobal=true;
    else
        rtwSfcnStr=coder.internal.infoMATFileMgr('getrtwSfcnStr','binfo',...
        modelName,'NONE');
        rtwsfcnstructIsGlobal=false;
    end

    if~isempty(rtwSfcnStr)
        for idx=1:length(rtwSfcnStr)
            maskVarIdx=idx+origNumVars;
            maskPromptName=[rtwSfcnStr(idx).Name,':'];
            maskVarName=sprintf('sfcnParam%d',idx);
            if(useparamvalues||isempty(rtwSfcnStr(idx).NameStr))



                maskValue=rtwSfcnStr(idx).ValueStr;
            else

                maskValue=rtwSfcnStr(idx).NameStr;
            end

            if idx==1
                paramStr=maskVarName;
            else
                paramStr=[paramStr,', ',maskVarName];%#ok<AGROW>
            end
            maskPrompts{maskVarIdx,1}=maskPromptName;
            maskValues{maskVarIdx,1}=maskValue;%#ok<AGROW>
            maskVariables=[maskVariables,...
            maskVarName,'=@',num2str(maskVarIdx),';'];%#ok<AGROW>
        end

        if rtwsfcnstructIsGlobal
            evalin('base',['clear global ',rtwsfcnStruct]);
            coder.internal.infoMATFileMgr('setrtwSfcnStr','binfo',...
            modelName,'NONE',rtwSfcnStr);
        end
        set_param(block,'parameters',paramStr,...
        'maskprompts',maskPrompts,...
        'maskvariables',maskVariables,...
        'maskvalues',maskValues,...
        'FunctionName',sfcnName);
    else
        set_param(block,'maskvalues',maskValues,...
        'FunctionName',sfcnName);
    end


    maskValueStr=get_param(block,'MaskValueString');%#ok<NASGU>
    whosResult=whos('maskValueStr');
    if(whosResult.bytes>65534)
        MSLDiagnostic('RTW:buildProcess:maskValueStringToLarge',...
        block,whosResult.bytes).reportAsWarning;
    end
end






function locSetupSfcnPortLabels(modelName,newblockname)
    try
        if contains(get_param(modelName,'TLCOptions'),'ExportFunctionsMode=1')
            return;
        end

        inportBlks=find_system(modelName,'SearchDepth',1,...
        'BlockType','Inport');
        outportBlks=find_system(modelName,'SearchDepth',1,...
        'BlockType','Outport');
        inportBlkNames=get_param(inportBlks,'Name');
        outportBlkNames=get_param(outportBlks,'Name');

        inportLabels='';
        for i=1:length(inportBlkNames)
            thisLabel=strrep(inportBlkNames{i},newline,' ');
            inportLabels=sprintf('%s\nport_label(''input'',%d,''%s'');',...
            inportLabels,i,thisLabel);
        end
        outportLabels='';
        for i=1:length(outportBlkNames)
            thisLabel=strrep(outportBlkNames{i},newline,' ');
            outportLabels=sprintf('%s\nport_label(''output'',%d,''%s'');',...
            outportLabels,i,thisLabel);
        end


        maskdisp=sprintf('%s%s',inportLabels,outportLabels);
        set_param(newblockname,'MaskDisplay',maskdisp);


        oldPos=get_param(newblockname,'Position');
        newSize=(max(length(inportBlkNames),length(outportBlkNames))*15)+10;
        set_param(newblockname,'Position',[oldPos(1:3),oldPos(2)+newSize]);
    catch exc %#ok<NASGU>

    end
end

