



function extraOpts=instrumentFile(this,srcFile,origFrontEndOptions,extraOpts)

    if nargin<4
        extraOpts=struct();
    end

    if isfield(extraOpts,'customFeHandlerOnly')
        doCustomFeHandlerOnly=extraOpts.customFeHandlerOnly;
    else
        doCustomFeHandlerOnly=false;
    end

    if isfield(extraOpts,'extraFeHandlers')
        extraFeHandlers=extraOpts.extraFeHandlers;
    else
        extraFeHandlers={};
    end

    if doCustomFeHandlerOnly
        assert(~isempty(extraFeHandlers));
    end

    fine(polyspace.internal.logging.Logger.getLogger('Instrumenter'),...
    'Instrumenting "%s"...',srcFile);

    srcFile=polyspace.internal.getAbsolutePath(srcFile);

    if~isempty(this.dbFilePath)
        this.InstrumImpl.traceabilityData.deleteFile(srcFile);
    end

    [fpath,fname,fext]=fileparts(srcFile);

    if~isempty(this.outInstrDir)
        currOutInstrDir=this.outInstrDir;
        if~exist(currOutInstrDir,'dir')
            mkdir(currOutInstrDir);
        end
    else
        currOutInstrDir=fpath;
    end



    if isfield(extraOpts,'ppFile')
        ppFile=extraOpts.ppFile;
        if strcmp(ppFile,'<default>')
            ppFile=fullfile(currOutInstrDir,[fname,fext,'i']);
            extraOpts.ppFile=ppFile;
        end
        polyspace.internal.makeParentDir(ppFile);
    else
        ppFile='';
    end



    if isfield(extraOpts,'instrXmlFile')&&~doCustomFeHandlerOnly
        instrXmlFile=extraOpts.instrXmlFile;
        if strcmp(instrXmlFile,'<default>')
            instrXmlFile=fullfile(currOutInstrDir,[fname,'.xml']);
            extraOpts.instrXmlFile=instrXmlFile;
        end
        polyspace.internal.makeParentDir(instrXmlFile);
    else
        instrXmlFile='';
    end


    if isfield(extraOpts,'ilHtmlFile')
        ilHtmlFile=extraOpts.ilHtmlFile;
        if strcmp(ilHtmlFile,'<default>')
            ilHtmlFile=fullfile(currOutInstrDir,fname);
            extraOpts.ilHtmlFile=ilHtmlFile;
        end
        polyspace.internal.makeParentDir(ilHtmlFile);
    else
        ilHtmlFile='';
    end


    if isfield(extraOpts,'ilDisplayFile')
        ilDisplayFile=extraOpts.ilDisplayFile;
        if strcmp(ilDisplayFile,'<default>')
            ilDisplayFile=fullfile(currOutInstrDir,[fname,'.disp']);
            extraOpts.ilDisplayFile=ilDisplayFile;
        end
        polyspace.internal.makeParentDir(ilDisplayFile);
    else
        ilDisplayFile='';
    end


    if isfield(extraOpts,'instrumentedSrcFile')&&~strcmp(extraOpts.instrumentedSrcFile,'<default>')
        instrumentedSrcFile=extraOpts.instrumentedSrcFile;
    else
        instrumentedSrcFile=fullfile(currOutInstrDir,[fname,'.',this.instrPrefix,fext(2:end)]);
        extraOpts.instrumentedSrcFile=instrumentedSrcFile;
    end
    polyspace.internal.makeParentDir(instrumentedSrcFile);


    frontEndOptions=origFrontEndOptions.deepCopy();
    frontEndOptions.Language.LanguageExtra=cat(1,frontEndOptions.Language.LanguageExtra,...
    {'--no_warnings'});

    if~isempty(this.booleanTypes)
        frontEndOptions.ExtraOptions{end+1}=['--boolean_types=',strjoin(this.booleanTypes,',')];
    end

    if~doCustomFeHandlerOnly
        frontEndOptions.Language.LanguageExtra=cat(1,frontEndOptions.Language.LanguageExtra,...
        {'--record_functions_pretty_names'});

        dirToIgnore={};
        if isfield(extraOpts,'dirToIgnore')
            dirToIgnore=extraOpts.dirToIgnore;
        end

        tmpFileToIgnore={};
        if isfield(extraOpts,'fileToIgnore')
            tmpFileToIgnore=extraOpts.fileToIgnore;
        end
        tmpInternalFileToIgnore={};
        if isfield(extraOpts,'internalFileToIgnore')
            tmpInternalFileToIgnore=extraOpts.internalFileToIgnore;
        end
        allFile=unique([tmpFileToIgnore(:);tmpInternalFileToIgnore(:)],'stable');
        if isfield(extraOpts,'fcnToIgnore')
            fctToIgnore=cat(1,this.Options.FunToIgnore(:),extraOpts.fcnToIgnore(:));
        else
            fctToIgnore=this.Options.FunToIgnore(:);
        end
        this.Options.DirToIgnore=dirToIgnore;
        this.Options.FileToIgnore=allFile;
        this.Options.FunToIgnore=fctToIgnore;


        feHandler=codeinstrum.internal.CodeInstrumenterFEHandler(this);
        feHandler.Code2ModelRecords=this.code2ModelRecords;
        if isfield(extraOpts,'isForSfcn')
            feHandler.IsForSfcn=extraOpts.isForSfcn;
        end
        feHandler.XmlFilePath=instrXmlFile;

    else
        feHandler=[];
    end


    frontEndOptions.RethrowException=true;
    frontEndOptions.RemoveUnneededEntities=false;
    frontEndOptions.DoGenOutput=true;
    frontEndOptions.GenOutput=instrumentedSrcFile;
    if~isempty(ilHtmlFile)
        frontEndOptions.DoDisplayIlHtml=true;
        frontEndOptions.DisplayIlOutput=ilHtmlFile;
    end
    if~isempty(ilDisplayFile)
        frontEndOptions.DoDisplayIl=true;
        frontEndOptions.DisplayIlOutput=ilDisplayFile;
    end


    frontEndOptions.Preprocessor.KeepComments=true;
    if~isempty(ppFile)&&~doCustomFeHandlerOnly
        frontEndOptions.Language.LanguageExtra=cat(1,frontEndOptions.Language.LanguageExtra,...
        {'--preprocess';'--output';ppFile;'--no_preproc_only'});
    end
    runInstrCommand(srcFile);

    if~isempty(this.dbFilePath)
        this.InstrumImpl.setBuildOptions(srcFile,frontEndOptions,tmpInternalFileToIgnore);
    end

    if~doCustomFeHandlerOnly
        this.InstrumImpl.finalizeFileInstrumentation(instrumentedSrcFile,srcFile,frontEndOptions);
    end

    if this.runCBeautifierOnInstrumentedFiles
        try
            c_beautifier(instrumentedSrcFile);
        catch exc
            warning(exc.identifier,'%s',exc.message);
        end
    end

    function runInstrCommand(filePath)
        if~isempty(this.dbFilePath)
            this.InstrumImpl.traceabilityData.commitTransaction();
        end

        feHandlers={};
        if~isempty(feHandler)
            feHandlers{end+1}=feHandler;
        end
        if~isempty(extraFeHandlers)
            feHandlers=horzcat(feHandlers,extraFeHandlers);
        end
        msgs=internal.cxxfe.FrontEnd.parseFile(filePath,frontEndOptions,feHandlers{:});

        hasError=internal.cxxfe.util.printFEMessages(msgs);
        if hasError
            codeinstrum.internal.error('CodeInstrumentation:instrumenter:instrumentationFailed',srcFile);
        end

        if~isempty(this.dbFilePath)
            this.InstrumImpl.traceabilityData.beginTransaction();
        end
    end
end
