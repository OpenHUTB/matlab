function[rtwOpts,genSet]=getSTFInfo(model,varargin)






    opts=locCheckArgs(model,varargin{:});

    reader=coder.internal.stf.FileReader.getInstance(opts.SysTgtFile);

    if~reader.Success
        if strcmp(opts.mdlRefTargetType,'SIM')

            opts.noTLCSettings=true;
        else
            DAStudio.error(reader.ErrorArguments{:});
        end
    end

    reader.parseSettings(model);
    genSet=reader.GenSettings;



    if opts.noTLCSettings
        genSet.PreCodeGenExecCompliant='1';
    else
        genSet=locGetTLCSettings(genSet,opts.rtwopts,reader.FileTextBuffer);
    end

    genSet.ModelReferenceTargetType=opts.mdlRefTargetType;


    genSet.model=locGetModelToUse(model,opts.doNotLoadModel);
    rtwOpts=reader.Options;

    if opts.csFieldsOnly

        genSet=coder.internal.getSTFInfoCSFields(genSet);
    end

end










function opts=locCheckArgs(model,varargin)

    opts=[];
    opts.mdlRefTargetType='NONE';
    opts.XILUpdating=false;
    systemTargetFile='';
    opts.rtwopts='';
    opts.doNotLoadModel=false;


    if isempty(model)
        opts.noTLCSettings=true;
        opts.csFieldsOnly=false;
    else

        opts.noTLCSettings=false;

        opts.csFieldsOnly=false;
    end


    if(mod(length(varargin),2)~=0)
        DAStudio.error('RTW:utility:propValListRequired',...
        'RTW.getSTFInfo');
    end

    for i=1:2:length(varargin)
        arg=lower(varargin{i});
        switch(arg)
        case 'modelreferencetargettype'
            if~ischar(varargin{i+1})
                DAStudio.error('RTW:utility:incorrectPropValType',...
                varargin{i},'char');
            end
            opts.mdlRefTargetType=varargin{i+1};
        case 'systemtargetfile'
            if~ischar(varargin{i+1})
                DAStudio.error('RTW:utility:incorrectPropValType',...
                varargin{i},'char');
            end

            systemTargetFile=strtrim(varargin{i+1});
            opts.doNotLoadModel=true;
        case 'notlcsettings'
            if~islogical(varargin{i+1})
                DAStudio.error('RTW:utility:incorrectPropValType',...
                varargin{i},'logical');
            end
            opts.noTLCSettings=varargin{i+1};
        case 'csfieldsonly'
            if~islogical(varargin{i+1})
                DAStudio.error('RTW:utility:incorrectPropValType',...
                varargin{i},'logical');
            end
            opts.csFieldsOnly=varargin{i+1};
        case 'xilupdating'

            if~islogical(varargin{i+1})
                DAStudio.error('RTW:utility:incorrectPropValType',...
                varargin{i},'logical');
            end
            opts.XILUpdating=varargin{i+1};
        otherwise



            DAStudio.error('RTW:utility:unknownProperty',varargin{i});
        end
    end

    if~isempty(model)&&~opts.noTLCSettings



        cs=getActiveConfigSet(model);



        opts.rtwopts=[cs.getStringRepresentation('full_no_extra_options')...
        ,locGetSpecialOptions(getProp(cs,'TLCOptions'))];
    end

    if(isempty(systemTargetFile)&&~isempty(model))
        systemTargetFile=get_param(model,'SystemTargetFile');
    end


    opts.SysTgtFile=systemTargetFile;


    if isempty(systemTargetFile)
        DAStudio.error('RTW:buildProcess:noSystemTargetFile');
    end

end









function genSet=locGetTLCSettings(genSet,rtwopts,STFContents)

    optsArray=rtwprivate('optstr_struct',rtwopts);



    paramsNeedingQuotes={'TargetPreCompLibLocation'};
    [~,idx]=ismember(paramsNeedingQuotes,{optsArray(:).name});
    idx=idx(idx>0);
    for i=1:length(idx)
        if(optsArray(idx(i)).value(1)~='"')
            optsArray(idx(i)).value=['"',optsArray(idx(i)).value,'"'];
        end
    end

    tlcH=tlc('new');



    optsArray=coder.internal.excludeGeneratedFileNamingRules(optsArray);
    for i=1:length(optsArray)
        tlc('execstring',tlcH,...
        ['%assign ',optsArray(i).name,'=',optsArray(i).value]);
    end


    try
        tlc('execstring',tlcH,STFContents);
    catch exc %#ok<NASGU>

    end

    try
        genSet.tlcTargetType=tlc('query',tlcH,'TargetType');
    catch exc
        tlc('close',tlcH);
        DAStudio.error('RTW:buildProcess:unspecifiedTargetType',...
        genSet.SystemTargetFile);
    end

    try
        genSet.tlcLanguage=tlc('query',tlcH,'Language');
    catch exc
        tlc('close',tlcH);
        DAStudio.error('RTW:buildProcess:unspecifiedLanguage',...
        genSet.SystemTargetFile);
    end



    try
        codeFormat=tlc('query',tlcH,'CodeFormat');
        if strcmp(codeFormat,'S-Function')
            try
                accelerator=tlc('query',tlcH,'Accelerator');
            catch exc %#ok<NASGU>
                accelerator=0;
            end
            if accelerator


                codeFormat='Accelerator_S-Function';
            end
        end
    catch exc %#ok<NASGU>
        codeFormat='RealTime';
    end
    genSet.CodeFormat=codeFormat;







    if(isfield(genSet,'UsingMalloc')&&...
        strcmp(genSet.UsingMalloc,'if_RealTimeMalloc'))
        if contains(rtwopts,'RealTimeMalloc')
            genSet.UsingMalloc='yes';
            genSet.CodeFormat='RealTimeMalloc';
        else
            genSet.UsingMalloc='no';
        end
    end

    try
        matFileLogging=tlc('query',tlcH,'MatFileLogging');
    catch exc %#ok<NASGU>
        warnStatus=[warning;warning('query','backtrace')];
        warning off backtrace;
        warning on;
        MSLDiagnostic('RTW:buildProcess:matFileLoggingWarning',genSet.SystemTargetFile).reportAsWarning;
        warning(warnStatus);
        matFileLogging=0;
    end
    genSet.matFileLogging=num2str(matFileLogging);

    try
        excstr=['%if !EXISTS("MaxStackSize")',newline,'%assign MaxStackSize = inf',newline,'%endif'];
        tlc('execstring',tlcH,excstr);
        maxStackSize=tlc('query',tlcH,'MaxStackSize');
    catch exc %#ok<NASGU>
        if any(strfind(STFContents,'%assign MaxStackSize = '))
            warnStatus=[warning;warning('query','backtrace')];
            warning off backtrace;
            warning on;
            MSLDiagnostic('RTW:buildProcess:maxStackSizeWarning',genSet.SystemTargetFile).reportAsWarning;
            warning(warnStatus);
        end
        maxStackSize=inf;
    end
    genSet.MaxStackSize=num2str(maxStackSize);

    try
        excstr=['%if !EXISTS("MaxStackVariableSize")',newline,'%assign MaxStackVariableSize = 4096',newline,'%endif'];
        tlc('execstring',tlcH,excstr);
        maxStackVariableSize=tlc('query',tlcH,'MaxStackVariableSize');
    catch exc %#ok<NASGU>
        if any(strfind(STFContents,'%assign MaxStackVariableSize'))
            warnStatus=[warning;warning('query','backtrace')];
            warning off backtrace;
            warning on;
            MSLDiagnostic('RTW:buildProcess:maxStackVariableSize',genSet.SystemTargetFile).reportAsWarning;
            warning(warnStatus);
        end
        maxStackVariableSize=4096;
    end
    genSet.MaxStackVariableSize=num2str(maxStackVariableSize);

    try
        excstr=['%if !EXISTS("DivideStackByRate")',newline,'%assign DivideStackByRate = 0',newline,'%endif'];
        tlc('execstring',tlcH,excstr);
        divideStackByRate=tlc('query',tlcH,'DivideStackByRate');
    catch exc %#ok<NASGU>
        if any(strfind(STFContents,'%assign DivideStackByRate'))
            warnStatus=[warning;warning('query','backtrace')];
            warning off backtrace;
            warning on;
            MSLDiagnostic('RTW:buildProcess:divideStackByRateWarning',genSet.SystemTargetFile).reportAsWarning;
            warning(warnStatus);
        end
        divideStackByRate=0;
    end
    genSet.DivideStackByRate=num2str(divideStackByRate);

    try
        excstr=['%if !EXISTS("GenerateEnableDisable")',newline,'%assign GenerateEnableDisable = 0',newline,'%endif'];
        tlc('execstring',tlcH,excstr);
        generateEnableDisable=tlc('query',tlcH,'GenerateEnableDisable');
    catch exc %#ok<NASGU>
        if any(strfind(STFContents,'%assign GenerateEnableDisable'))
            warnStatus=[warning;warning('query','backtrace')];
            warning off backtrace;
            warning on;
            MSLDiagnostic('RTW:buildProcess:generateEnableDisableWarning',genSet.SystemTargetFile).reportAsWarning;
            warning(warnStatus);
        end
        generateEnableDisable=0;
    end
    genSet.GenerateEnableDisable=num2str(generateEnableDisable);

    try
        excstr=['%if !EXISTS("MaxConstBOSize")',newline,'%assign MaxConstBOSize = inf',newline,'%endif'];
        tlc('execstring',tlcH,excstr);
        maxConstBOSize=tlc('query',tlcH,'MaxConstBOSize');
    catch exc %#ok<NASGU>
        if any(strfind(STFContents,'%assign MaxConstBOSize = '))
            warnStatus=[warning;warning('query','backtrace')];
            warning off backtrace;
            warning on;
            MSLDiagnostic('RTW:buildProcess:maxConstBOSizeWarning',genSet.SystemTargetFile).reportAsWarning;
            warning(warnStatus);
        end
        maxConstBOSize=inf;
    end
    genSet.MaxConstBOSize=num2str(maxConstBOSize);

    try
        excstr=['%if !EXISTS("ProtectCallInitFcnTwice")',newline,'%assign ProtectCallInitFcnTwice = 0',newline,'%endif'];
        tlc('execstring',tlcH,excstr);
        result=tlc('query',tlcH,'ProtectCallInitFcnTwice');

        if~isfinite(result)

            protectCallInitFcnTwice=0;
        else
            if strcmpi(result,'false')
                protectCallInitFcnTwice=0;
            elseif strcmpi(result,'true')
                protectCallInitFcnTwice=1;
            else
                protectCallInitFcnTwice=result;
            end
        end
    catch exc %#ok<NASGU>
        if any(strfind(STFContents,'%assign ProtectCallInitFcnTwice'))
            warnStatus=[warning;warning('query','backtrace')];
            warning off backtrace;
            warning on;
            MSLDiagnostic('RTW:buildProcess:protectCallInitFcnTwiceWarning',genSet.SystemTargetFile).reportAsWarning;
            warning(warnStatus);
        end
        protectCallInitFcnTwice=0;
    end
    genSet.ProtectCallInitFcnTwice=num2str(protectCallInitFcnTwice);

    try
        excstr=['%if !EXISTS("ProfileGenCode")',newline,'%assign ProfileGenCode = 0',newline,'%endif'];
        tlc('execstring',tlcH,excstr);
        result=tlc('query',tlcH,'ProfileGenCode');

        if~isfinite(result)

            profileGenCode=0;
        else
            if strcmpi(result,'false')
                profileGenCode=0;
            elseif strcmpi(result,'true')
                profileGenCode=1;
            else
                profileGenCode=result;
            end
        end
    catch exc %#ok<NASGU>
        if any(strfind(STFContents,'%assign ProfileGenCode'))
            warnStatus=[warning;warning('query','backtrace')];
            warning off backtrace;
            warning on;
            MSLDiagnostic('RTW:buildProcess:profileGenCodeWarning',genSet.SystemTargetFile).reportAsWarning;
            warning(warnStatus);
        end
        profileGenCode=0;
    end
    genSet.ProfileGenCode=num2str(profileGenCode);

    if strcmp(codeFormat,'Embedded-C')

        genRTModel=1;
    else
        try
            excstr=['%if !EXISTS("GenRTModel")',newline,'%assign GenRTModel = 0',newline,'%endif'];
            tlc('execstring',tlcH,excstr);
            genRTModel=tlc('query',tlcH,'GenRTModel');
        catch exc %#ok<NASGU>
            if any(strfind(STFContents,'%assign GenRTModel = '))
                warnStatus=[warning;warning('query','backtrace')];
                warning off backtrace;
                warning on;
                MSLDiagnostic('RTW:buildProcess:genRTModelWarning',genSet.SystemTargetFile).reportAsWarning;
                warning(warnStatus);
            end
            genRTModel=0;
        end
    end
    genSet.GenRTModel=num2str(genRTModel);

    try
        excstr=['%if !EXISTS("PreCodeGenExecCompliant")',newline,'%assign PreCodeGenExecCompliant = 0',newline,'%endif'];
        tlc('execstring',tlcH,excstr);
        preCodeGenExecCompliant=tlc('query',tlcH,'PreCodeGenExecCompliant');
    catch exc %#ok<NASGU>
        if any(strfind(STFContents,'%assign PreCodeGenExecCompliant = '))
            warnStatus=[warning;warning('query','backtrace')];
            warning off backtrace;
            warning on;
            MSLDiagnostic('RTW:buildProcess:PreCodeGenExecCompliant',genSet.SystemTargetFile).reportAsWarning;
            warning(warnStatus);
        end
        preCodeGenExecCompliant=0;
    end
    genSet.PreCodeGenExecCompliant=num2str(preCodeGenExecCompliant);

    try
        excstr=['%if !EXISTS("RetainObsoletedRTWFileRecords")',newline,'%assign RetainObsoletedRTWFileRecords = 0',newline,'%endif'];
        tlc('execstring',tlcH,excstr);
        preCodeGenExecCompliant=tlc('query',tlcH,'RetainObsoletedRTWFileRecords');
    catch exc %#ok<NASGU>
        if any(strfind(STFContents,'%assign RetainObsoletedRTWFileRecords = '))
            warnStatus=[warning;warning('query','backtrace')];
            warning off backtrace;
            warning on;
            MSLDiagnostic('RTW:buildProcess:RetainObsoletedRTWFileRecords',genSet.SystemTargetFile).reportAsWarning;
            warning(warnStatus);
        end
        preCodeGenExecCompliant=0;
    end
    genSet.RetainObsoletedRTWFileRecords=num2str(preCodeGenExecCompliant);

    tlc('close',tlcH);

    if~any(strcmp(genSet.tlcTargetType,{'RT','NRT'}))
        DAStudio.error('RTW:buildProcess:invalidTargetType',...
        genSet.SystemTargetFile);
    end

end










function y=locGetSpecialOptions(options)

    y='';
    stackOptions={'MaxStackSize',...
    'MaxStackVariableSize',...
    'DivideStackByRate',...
    'GenerateEnableDisable',...
    'ProtectCallInitFcnTwice',...
    'ProfileGenCode',...
    'MaxConstBOSize'};

    optionsStruct=rtwprivate('optstr_struct',options);
    for i=1:size(optionsStruct,2)
        for j=1:size(stackOptions,2)
            if strcmp(optionsStruct(i).name,stackOptions{j})
                y=[y,'-a',stackOptions{j},'=',optionsStruct(i).value,' '];%#ok<AGROW>
            end
        end
    end
end











function modelToUse=locGetModelToUse(model,doNotLoadModel)
    if isempty(model)||doNotLoadModel
        modelToUse=model;
        return;
    end

    if(ischar(model))
        name=model;
    else
        name=get_param(model,'Name');
    end



    if(isequal(get_param(name,'ModelReferenceMultiInstanceNormalModeCopy'),'on'))

        modelToUse=get_param(name,'ModelReferenceNormalModeOriginalModelName');
    else

        modelToUse=name;
    end
end



