function privimporthdl(hdlInSrc,varargin)






































    if(ismac)
        DAStudio.error('hdlcoder:hdlimport:parser:PlatformNotSupported',"Mac");
    end

    slhdlcoder.checkLicense;

    paramList={'topModule','clockBundle','blackBoxModule','language','debug','mode','autoPlace','sampleTime','DCE','recursiveFolders','autoPlaceTool'};
    argListSize=numel(varargin);


    if(mod(argListSize,2)||nargin==0)
        DAStudio.error('hdlcoder:hdlimport:parser:IncorrectNumOfValuePair');
    end

    for i=1:2:argListSize
        propertyName=varargin{i};

        if~(ischar(propertyName)||isstring(propertyName))
            DAStudio.error('hdlcoder:hdlimport:parser:InvalidPropertyType',string(propertyName));
        end

        try
            propertyName=validatestring(strtrim(propertyName),paramList);
        catch
            DAStudio.error('hdlcoder:hdlimport:parser:InvalidNameValuePair',string(propertyName));
        end
        varargin{i}=propertyName;
    end


    defaultTopModule='';
    defaultClock='';
    defaultBlackBoxModule='';
    defaultLang='verilog';
    defaultMode='default';
    defaultDebug='off';
    defaultLayout='on';
    defaultSampleTime=-1;
    defaultDCE='on';
    defaultRecursiveFolder='on';
    defaultArrangeTool='arrangesystem';


    modes={'AST','DFG','PIR','ALL'};
    languages={'vlog','vhdl','verilog'};
    debugValue={'on','off'};
    autoplaceValue={'on','off'};
    DCEValue={'on','off'};
    recursiveFolderValue={'on','off'};
    autoPlaceToolValue={'arrangesystem','graphviz'};


    parser=inputParser;


    isHdlInputSrcTypeCell=iscell(hdlInSrc);

    if(~isHdlInputSrcTypeCell)

        if(strlength(strtrim(hdlInSrc))==0)
            DAStudio.error('hdlcoder:hdlimport:parser:InvalidHdlSrc');
        end
    end


    validationForClkBundle=@(x)validateattributes(x,{'cell'},{'row','nonempty'});
    stringInputValidation=@(x)validateattributes(x,{'char','string'},{'nonempty'});
    stringArrayInputValidation=@(x)validateattributes(x,{'char','cell','string'},{'row','nonempty'});
    numericInputValidation=@(x)validateattributes(x,{'numeric'},{'scalar'});


    addRequired(parser,'hdlInSrc',stringArrayInputValidation);
    addParameter(parser,'topModule',defaultTopModule,stringInputValidation);
    addParameter(parser,'clockBundle',defaultClock,validationForClkBundle);
    addParameter(parser,'blackBoxModule',defaultBlackBoxModule,stringArrayInputValidation);
    addParameter(parser,'language','',stringInputValidation,'PartialMatchPriority',2);
    addParameter(parser,'mode',defaultMode,stringInputValidation,'PartialMatchPriority',2);
    addParameter(parser,'debug',defaultDebug,stringInputValidation,'PartialMatchPriority',2);
    addParameter(parser,'autoPlace',defaultLayout,stringInputValidation,'PartialMatchPriority',2);
    addParameter(parser,'sampleTime',defaultSampleTime,numericInputValidation,'PartialMatchPriority',2);
    addParameter(parser,'DCE',defaultDCE,stringInputValidation,'PartialMatchPriority',2);
    addParameter(parser,'recursiveFolders',defaultRecursiveFolder,stringInputValidation,'PartialMatchPriority',2);
    addParameter(parser,'autoPlaceTool',defaultArrangeTool,stringInputValidation,'PartialMatchPriority',2);

    parse(parser,hdlInSrc,varargin{:});


    arg=parser.Results;
    topModule=arg.topModule;
    clkBundle=arg.clockBundle;
    blkBoxModule=arg.blackBoxModule;
    lang=strtrim(arg.language);
    mode=strtrim(arg.mode);
    debug=strtrim(arg.debug);
    autoPlace=strtrim(arg.autoPlace);
    sampleTime=arg.sampleTime;
    DCE=strtrim(arg.DCE);
    recursiveFolders=strtrim(arg.recursiveFolders);
    autoPlaceTool=strtrim(arg.autoPlaceTool);

    if isHdlInputSrcTypeCell
        hdlInSrcSize=numel(hdlInSrc);
        for k=1:hdlInSrcSize
            inputsource=hdlInSrc{k};
            if(~(isstring(inputsource)||ischar(inputsource))||(strlength(inputsource)==0))
                DAStudio.error('hdlcoder:hdlimport:parser:InvalidPropertyValueType',"File/Folder");
            end
        end
    else
        hdlInSrcSize=1;
    end


    try
        recursiveFolders=validatestring(recursiveFolders,recursiveFolderValue);
    catch InvalidrecursiveFoldersException
        DAStudio.error('hdlcoder:hdlimport:parser:InvalidPropertyValue',"recursiveFolders",InvalidrecursiveFoldersException.message);
    end

    recursiveFoldersOption=true;
    if(strcmpi(recursiveFolders,'off')==1)
        recursiveFoldersOption=false;
    end


    if(recursiveFoldersOption)
        hdlInSrc=RecusriveFoldersCheck(isHdlInputSrcTypeCell,hdlInSrcSize,hdlInSrc);
        if(iscell(hdlInSrc))
            isHdlInputSrcTypeCell=iscell(hdlInSrc);
            hdlInSrcSize=numel(hdlInSrc);
        end
    end




    if(isempty(lang))

        if(isHdlInputSrcTypeCell)
            for k=1:hdlInSrcSize
                sourceName=hdlInSrc{k};

                if~isfolder(sourceName)
                    lang=DetectLanguage(sourceName);
                    if~isempty(lang)
                        break;
                    end
                end
            end

            if isempty(lang)
                lang=DetectLanguageForFolders(hdlInSrc,hdlInSrcSize,defaultLang);
            end
        else

            if isfolder(hdlInSrc)

                lang=DetectLanguagewithFileExtension(hdlInSrc,defaultLang);
            else

                lang=DetectLanguage(hdlInSrc);
            end
        end
        if(isempty(lang))

            lang=defaultLang;
        end
    end


    try
        lang=validatestring(lang,languages);
    catch InvalidLanguageException
        DAStudio.error('hdlcoder:hdlimport:parser:InvalidPropertyValue',"language",InvalidLanguageException.message);
    end



    if(strcmpi(lang,'vhdl')&&strcmp(hdlfeature('VHDLImport'),'off'))
        DAStudio.error('hdlcoder:hdlimport:parser:UnSupportedVHDL');
    end


    if(~(strcmp(mode,'default')==1))
        try
            mode=validatestring(mode,modes);
        catch InvalidModeException
            DAStudio.error('hdlcoder:hdlimport:parser:InvalidPropertyValue',"mode",InvalidModeException.message);
        end
    end


    try
        debug=validatestring(debug,debugValue);
    catch InvalidDebugException
        DAStudio.error('hdlcoder:hdlimport:parser:InvalidPropertyValue',"debug",InvalidDebugException.message);
    end


    try
        autoPlace=validatestring(autoPlace,autoplaceValue);
    catch InvalidAutoPlaceException
        DAStudio.error('hdlcoder:hdlimport:parser:InvalidPropertyValue',"autoPlace",InvalidAutoPlaceException.message);
    end


    try
        autoPlaceTool=validatestring(autoPlaceTool,autoPlaceToolValue);
    catch InvalidautoPlaceToolException
        DAStudio.error('hdlcoder:hdlimport:parser:InvalidPropertyValue',"autoPlaceTool",InvalidautoPlaceToolException.message);
    end


    if(isHdlInputSrcTypeCell)

        for k=1:hdlInSrcSize
            [folder_or_file,isValid]=validateSrc(hdlInSrc{k},lang);
            if(isValid)
                hdlInSrc{k}=folder_or_file;
            else
                hdlInSrc{k}='';
            end
        end
    else
        [folder_or_file,isValid]=validateSrc(hdlInSrc,lang);
        if isValid
            hdlInSrc=folder_or_file;
        else
            hdlInSrc='';
        end
    end




    clkBundleSize=numel(clkBundle);
    if(~isempty(clkBundle)&&(clkBundleSize~=3))
        DAStudio.error('hdlcoder:hdlimport:parser:InvalidClockBundle');


    else
        for k=1:clkBundleSize
            clkBundleValue=clkBundle{k};
            if(~(isstring(clkBundleValue)||ischar(clkBundleValue))||isempty(clkBundleValue))
                DAStudio.error('hdlcoder:hdlimport:parser:InvalidPropertyValueType',"clockbundle");
            end


            clkBundleValue=strtrim(clkBundleValue);


            if(contains(clkBundleValue," "))
                DAStudio.error('hdlcoder:hdlimport:parser:InvalidValueForParameter',clkBundleValue,"clockbundle");
            end
            clkBundle{k}=clkBundleValue;
        end
    end


    blkBoxModuleSize=numel(blkBoxModule);
    if(blkBoxModuleSize)
        if iscell(blkBoxModule)
            for k=1:blkBoxModuleSize
                blkBoxModuleValue=blkBoxModule{k};
                if(~(isstring(blkBoxModuleValue)||ischar(blkBoxModuleValue))||isempty(blkBoxModuleValue))
                    DAStudio.error('hdlcoder:hdlimport:parser:InvalidPropertyValueType',"blackboxmodule");
                end


                blkBoxModuleValue=strtrim(blkBoxModuleValue);


                if(contains(blkBoxModuleValue," "))
                    DAStudio.error('hdlcoder:hdlimport:parser:InvalidValueForParameter',blkBoxModuleValue,"blackboxmodule");
                end
                blkBoxModule{k}=blkBoxModuleValue;
            end
        else
            blkBoxModule=strtrim(blkBoxModule);
            if(contains(blkBoxModule," "))
                DAStudio.error('hdlcoder:hdlimport:parser:InvalidValueForParameter',blkBoxModule,"blackboxmodule");
            end
        end
    end


    try
        DCE=validatestring(DCE,DCEValue);
    catch InvalidDCEException
        DAStudio.error('hdlcoder:hdlimport:parser:InvalidPropertyValue',"DCE",InvalidDCEException.message);
    end


    topModule=strtrim(topModule);

    if(contains(topModule," "))
        DAStudio.error('hdlcoder:hdlimport:parser:InvalidValueForParameter',topModule,"topmodule");
    end


    HdlImportExec=['"',fullfile(matlabroot,'bin',computer('arch'),'hdlimport'),'"'];

    format='%s ';

    cmd=sprintf(format,HdlImportExec);



    if(~isempty(topModule))

        if(strcmpi(lang,'vhdl')==1)
            topModule=lower(topModule);
        end
        cmd=strcat(cmd,{' -t '},topModule);
    end



    if(clkBundleSize)
        clkvalues='';
        for k=1:clkBundleSize-1
            clkvalues=strcat(clkvalues,clkBundle{k},{','});
        end
        clkvalues=strcat(clkvalues,clkBundle{clkBundleSize});
        cmd=strcat(cmd,{' -c '},clkvalues{1});
    end



    blkBoxModuleSize=numel(blkBoxModule);
    if(blkBoxModuleSize)
        cmd=strcat(cmd,{' -b '});
        if(isstring(blkBoxModule)||iscellstr(blkBoxModule)||iscell(blkBoxModule))
            cmd=strcat(cmd,blkBoxModule{1});
            for k=2:blkBoxModuleSize
                cmd=strcat(cmd,{','},blkBoxModule{k});
            end
        else
            cmd=strcat(cmd,blkBoxModule);
        end
    end


    cmd=strcat(cmd,{' -l '},lower(lang));



    debugMode=false;
    if(~isempty(mode)&&(strcmpi(mode,'default')~=1))
        debugMode=true;
        if(strcmpi(mode,'pir')==1)

            cmd=strcat(cmd,{' -m all'});
        else
            cmd=strcat(cmd,{' -m '},mode);
        end
    end



    if(~isempty(debug)&&(strcmpi(debug,'off')~=1))
        if(strcmpi(debug,'on')==1)
            debugMode=true;
            cmd=strcat(cmd,{' -d on'});
        end
    end


    if(~isreal(sampleTime)||sampleTime<0&&sampleTime~=-1)
        DAStudio.error('hdlcoder:hdlimport:modelgen:InvalidSampleTime');
    end

    cmd=strcat(cmd,{' -s '},string(sampleTime));

    layoutFlag='yes';

    if(strcmpi(autoPlace,'off')==1)
        layoutFlag='no';
    end

    layoutTool='arrangesystem';

    if(strcmpi(autoPlaceTool,'graphviz')==1)
        layoutTool='graphviz';
    end



    DCEOption=true;
    if(strcmpi(DCE,'off')==1)
        DCEOption=false;
    end



    hdlSrc='';
    if(isHdlInputSrcTypeCell)
        for k=1:hdlInSrcSize
            if~isempty(hdlInSrc{k})
                hdlSrc=strcat(hdlSrc,{' '},'"',hdlInSrc{k},'"');
            end
        end
    else
        hdlSrc=strcat(hdlSrc,{' '},'"',hdlInSrc,'"');
    end

    if(isempty(hdlSrc))
        DAStudio.error('hdlcoder:hdlimport:parser:InvalidHdlSrc');
    end
    cmd=strcat(cmd,hdlSrc);


    [ret,cmdout]=system(cmd{1},'-echo');


    if(ret~=0)


        delete *.pp;
        DAStudio.error('hdlcoder:hdlimport:modelgen:ImportFailed');
    end


    if((strcmpi(mode,'ALL')~=1)&&(strcmpi(mode,'default')~=1))

        hdldisp(message('hdlcoder:hdlimport:modelgen:ImportCompleted'));
        return;
    end



    if(isempty(topModule)||length(topModule)>46)


        consolePrintForTp=regexp(cmdout,'Top Module name: [^\.]+.','match');


        mfile=regexp(consolePrintForTp{1},': ''','split');


        splitFileName=regexp(mfile{2},'''\.','split');


        topModule=splitFileName{1};
    end


    HdlImportPath=fullfile(pwd,'hdlimport',topModule);


    GeneratedPirFile=sprintf('%s_serialized',topModule);


    GeneratedModelSetUpFile=fullfile(HdlImportPath,sprintf('%s_model_setup.m',topModule));
    GeneratedModelName=fullfile(HdlImportPath,topModule);

    try

        CurDir=cd;
        cd(HdlImportPath);



        slxFile=sprintf("%s.slx",topModule);
        if isfile(slxFile)
            movefile(slxFile,sprintf("%s_old.slx",topModule));
        end
        mdlFile=sprintf("%s.mdl",topModule);
        if isfile(mdlFile)
            movefile(mdlFile,sprintf("%s_old.mdl",topModule));
        end



        p=pir();
        p.destroy;


        p=eval(GeneratedPirFile);

        flagValue=~debugMode;


        if(flagValue)
            delete(sprintf("%s.m",GeneratedPirFile));
        end


        cd(CurDir);



        if(DCEOption)
            hdldisp(message('hdlcoder:hdlimport:modelgen:InvokingDCE'));


            noOfCompsInNetWork=FindNoOfCompsInModel(p);

            gp=pir;
            gp.doDeadLogicElimination(true);


            afterDCENoOfComps=FindNoOfCompsInModel(p);


            if(noOfCompsInNetWork~=afterDCENoOfComps)
                hdldisp(message('hdlcoder:hdlimport:modelgen:EliminatedBlocks'));
            end
        end


        generateModel(p,layoutFlag,sampleTime,layoutTool);




        preLoadFcn=sprintf('addpath(''%s'');\n',HdlImportPath);
        set_param(topModule,'PreLoadFcn',preLoadFcn);


        closeFcn=sprintf('addpath(''%s'');\nrmpath(''%s'');\n',HdlImportPath,HdlImportPath);
        set_param(topModule,'CloseFcn',closeFcn);

        if isfile(GeneratedModelSetUpFile)
            hdldisp(message('hdlcoder:hdlimport:modelgen:ModelParamSetup'));
            run(GeneratedModelSetUpFile);

            if(flagValue)
                delete(GeneratedModelSetUpFile);
            end
        end
        evalc('hdlsetup(topModule)');




        GeneratedModelName=save_system(topModule,GeneratedModelName);


        hdldisp(message('hdlcoder:hdlimport:modelgen:GeneratedModelFile',hdlgetModellink(GeneratedModelName)));


        close_system(GeneratedModelName);

    catch ModelGenException


        p=pir();
        p.destroy;
        bdclose(topModule);

        cd(CurDir);



        if isfolder(HdlImportPath)
            rmdir(HdlImportPath,'s');
        end

        DAStudio.error('hdlcoder:hdlimport:modelgen:ModelGenFailed',ModelGenException.message,DAStudio.message('hdlcoder:hdlimport:modelgen:ImportFailed'));
    end


    p=pir();
    p.destroy;

    hdldisp(message('hdlcoder:hdlimport:modelgen:ImportCompleted'));
end


function generateModel(pirInstance,layoutFlag,sampleTime,layoutTool)


    pirInstance.doPreModelgenTasks;

    topNtwk=pirInstance.getTopNetwork;
    topNtwk.renderCodegenPir(true);
    infile='';
    verbose=false;
    openoutfile='no';
    outfile=topNtwk.Name;
    outfileprefix='';
    hiliteparents='yes';
    color='cyan';
    showCGPIR='on';
    sampletime=sampleTime;
    autoPlace='yes';
    autoroute='yes';
    arrangesystem='yes';

    if(strcmpi(layoutFlag,'no')==1)
        arrangesystem='no';
        autoPlace='no';
    else
        if(strcmpi(layoutTool,'graphviz')==1)
            arrangesystem='no';
        end
    end


    hb=slhdlcoder.SimulinkBackEnd(pirInstance,...
    'InModelFile',infile,...
    'OutModelFile',outfile,...
    'DUTMdlRefHandle',-1,...
    'ShowModel',openoutfile,...
    'OutModelFilePrefix',outfileprefix,...
    'ShowCodeGenPIR',showCGPIR,...
    'AutoRoute',autoroute,...
    'AutoPlace',autoPlace,...
    'HiliteAncestors',hiliteparents,...
    'HiliteColor',color,...
    'Verbose',verbose,...
    'MLMode',true,...
    'UseArrangeSystem',arrangesystem,...
    'SampleTime',sampletime,...
    'OverrideSampleTime',true);
    hb.generateModel;

end

function link=hdlgetModellink(fileName)




    if feature('hotlinks')
        if fileName(1)==filesep||...
            (fileName(2)==':'&&fileName(3)==filesep)||...
            (fileName(1)=='\'&&fileName(2)=='\')


            separators=strfind(fileName,filesep);
            displayName=fileName(separators(end)+1:end);
        else
            displayName=fileName;
        end
        link=sprintf('<a href="matlab:open_system(''%s'')">%s</a>',fileName,displayName);
    else
        link=fileName;
    end

end

function[isValidDir]=checkIfDirContainsValidFiles(hdlDir,lang)
    isValidDir=false;
    list=dir(hdlDir);
    [len,~]=size(list);


    for i=3:len
        fileName=strcat(list(i).folder,filesep,list(i).name);
        if(isfile(fileName))
            if(strcmpi(lang,'vhdl')==1)
                if isVhdlFile(fileName)
                    isValidDir=true;
                    return;
                end
            else
                if isVerilogFile(fileName)
                    isValidDir=true;
                    return;
                end
            end
        end
    end
end

function[isVhdlFile]=isVhdlFile(fileName)
    [~,~,fileExt]=fileparts(fileName);
    if(strcmpi(fileExt,'.vhd')||...
        strcmpi(fileExt,'.vhdl'))
        isVhdlFile=true;
    else
        isVhdlFile=false;
    end
end


function[isVlogFile]=isVerilogFile(fileName)
    [~,~,fileExt]=fileparts(fileName);
    if(strcmpi(fileExt,'.v'))
        isVlogFile=true;
    else
        isVlogFile=false;
    end
end


function[hdlInSrc,isValid]=validateSrc(hdlInSrc,lang)

    isValid=false;
    if isfolder(hdlInSrc)
        isValid=checkIfDirContainsValidFiles(hdlInSrc,lang);
        return;
    elseif isfile(hdlInSrc)
        if(strcmpi(lang,'vhdl')==1)
            if isVhdlFile(hdlInSrc)
                isValid=true;
            end
        else
            if isVerilogFile(hdlInSrc)
                isValid=true;
            end
        end
        return;
    end


    if(strcmpi(lang,'vhdl')==1)

        VhdlFileExtList={'.vhd','.VHD','.vhdl','.VHDL'};
        VhdlFileExtListSize=numel(VhdlFileExtList);
        for i=1:VhdlFileExtListSize
            temp=strcat(string(hdlInSrc),VhdlFileExtList{i});
            if isfile(temp)
                hdlInSrc=temp;
                isValid=true;
                return;
            end
        end
    else

        VerilogFileExtList={'.v','.V'};
        VerilogFileExtListSize=numel(VerilogFileExtList);
        for i=1:VerilogFileExtListSize
            temp=strcat(string(hdlInSrc),VerilogFileExtList{i});
            if isfile(temp)
                hdlInSrc=temp;
                isValid=true;
                return;
            end
        end
    end

    [path,fileName,fileExt]=fileparts(hdlInSrc);

    tempFile=strcat(path,fileName,lower(fileExt));
    if isfile(tempFile)
        hdlInSrc=tempFile;
        isValid=true;
        return;
    end

    tempFile=strcat(path,fileName,upper(fileExt));
    if isfile(tempFile)
        hdlInSrc=tempFile;
        isValid=true;
        return;
    end


    DAStudio.error('hdlcoder:hdlimport:parser:FileNotFound',string(hdlInSrc));

end


function lang=DetectLanguageForFolders(hdlInSrc,hdlInSrcSize,defaultLang)
    detectedLang='';
    for k=1:hdlInSrcSize
        sourceName=hdlInSrc{k};
        if isfolder(sourceName)
            lang=DetectLanguagewithFileExtension(sourceName,defaultLang);
            if~isempty(lang)
                if strcmpi(lang,defaultLang)
                    return;
                else
                    detectedLang=lang;
                end
            end
        end
    end

    lang=detectedLang;
end


function lang=DetectLanguagewithFileExtension(hdlInSrc,defaultLang)
    detectedLang='';
    list=dir(hdlInSrc);
    [len,~]=size(list);


    for i=3:len
        if(~list(i).isdir)
            lang=DetectLanguage(fullfile(list(i).folder,list(i).name));
            if~isempty(lang)
                if strcmpi(lang,defaultLang)
                    return;
                else
                    detectedLang=lang;
                end
            end
        end
    end

    lang=detectedLang;
end

function lang=DetectLanguage(hdlInSrc)


    lang='';
    [~,~,fileExt]=fileparts(hdlInSrc);
    if isfile(hdlInSrc)
        if strcmpi(fileExt,'.v')
            lang='verilog';
        elseif(strcmpi(fileExt,'.vhd')||...
            strcmpi(fileExt,'.vhdl'))
            lang='vhdl';
        end
    else
        if(isfile(strcat(hdlInSrc,'.v'))||...
            isfile(strcat(hdlInSrc,'.V')))
            lang='verilog';
        elseif(isfile(strcat(hdlInSrc,'.vhd'))||...
            isfile(strcat(hdlInSrc,'.VHD'))||...
            isfile(strcat(hdlInSrc,'.vhdl'))||...
            isfile(strcat(hdlInSrc,'.VHDL')))
            lang='vhdl';
        end
    end
end


function noOfComps=FindNoOfCompsInModel(dut)
    noOfComps=0;
    vNetworks=dut.Networks;
    for i=1:length(vNetworks)
        hC=vNetworks(i).Components;
        noOfComps=noOfComps+length(hC);
    end
end

function hdlSrcFiles=RecusriveFoldersCheck(isHdlInputSrcTypeCell,hdlInSrcSize,hdlInSrc)
    Index=1;

    if(isHdlInputSrcTypeCell)
        hdlSrcFiles={0};
        for j=1:hdlInSrcSize
            hdlSrcFiles(Index)=hdlInSrc(j);
            Index=Index+1;


            if(exist(hdlInSrc{j},'dir')==7)
                [hdlSrcFiles,Index]=AddSubDir(hdlSrcFiles,hdlInSrc{j},Index);
            end
        end
    else



        if(exist(hdlInSrc,'dir')==7)
            hdlSrcFiles={};
            hdlSrcFiles(Index)={hdlInSrc};
            Index=Index+1;
            [hdlSrcFiles,~]=AddSubDir(hdlSrcFiles,hdlInSrc,Index);
        else

            hdlSrcFiles=hdlInSrc;
        end
    end
end


function[out,Index]=AddSubDir(out,hdlDir,Index)

    list=dir(hdlDir);
    [len,~]=size(list);


    for i=3:len
        if(list(i).isdir)
            path=fullfile(list(i).folder,list(i).name);
            out(Index)={path};
            Index=Index+1;
            [out,Index]=AddSubDir(out,path,Index);
        end
    end
end


