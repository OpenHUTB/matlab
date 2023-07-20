function convertReport(h,tSource)








%#function ctfroot

    if(nargin<2||isempty(tSource))
        tSource=h.SrcFileName;
    end
    theFormat=h.getFormat();

    locInitIoFiles(h,tSource,theFormat);

    report=h.up;
    if~isempty(report)&&isa(report,'rptgen.cform_outline')&&report.isGenerateDocBookOnly

    else
        if rptgen.use_java
            formatXSLT='com.mathworks.toolbox.rptgencore.output.OutputFormatXSLT';
            formatDSSSL='com.mathworks.toolbox.rptgencore.output.OutputFormatDSSSL';
            formatDB2DOM='com.mathworks.toolbox.rptgencore.output.OutputFormatDB2DOM';
        else
            formatXSLT='rptgen.internal.output.OutputFormatXSLT';
            formatDSSSL='rptgen.internal.output.OutputFormatDSSSL';
            formatDB2DOM='rptgen.internal.output.OutputFormatDB2DOM';
        end

        if isa(theFormat,formatXSLT)
            locRunXsltEngine(h,tSource,theFormat);

        elseif isa(theFormat,formatDSSSL)
            locRunDSSSLEngine(h,tSource,theFormat);

        elseif isa(theFormat,formatDB2DOM)
            locRunDB2DOMEngine(h,tSource,theFormat);
        else

        end

    end


    function locInitIoFiles(h,tSource,theFormat)


        if isempty(h.SrcFileName)
            if rptgen.use_java
                h.SrcFileName=[tempname,'.',...
                char(com.mathworks.toolbox.rptgencore.output.OutputFormat.getExtension('db'))];%#ok<JAPIMATHWORKS> 
            else
                h.SrcFileName=[tempname,'.',...
                char(rptgen.internal.output.OutputFormat.getFileExtension('db'))];
            end
        end

        if isempty(h.DstFileName)
            if ischar(tSource)
                [sPath,sFile]=fileparts(tSource);
            else
                [sPath,sFile]=fileparts(h.SrcFileName);
            end
            h.DstFileName=fullfile(sPath,[sFile,'.',char(theFormat.getExtension)]);
        end


        function locRunDSSSLEngine(h,tSource,theFormat)

            if~ischar(tSource)
                rpt_xml.xmlwrite(tSource,h.SrcFileName);
            end


            if rptgen.use_java
                com.mathworks.toolbox.rptgencore.docbook.DocbookDocument.enableDoctype(h.SrcFileName,true);%#ok<JAPIMATHWORKS> 
            else
                rptgen.internal.docbook.DocbookDocument.enableDoctype(h.SrcFileName,true);
            end


            [h.DstFileName,messages]=h.convertToRTF(theFormat);


            if rptgen.use_java
                com.mathworks.toolbox.rptgencore.docbook.DocbookDocument.enableDoctype(h.SrcFileName,false);%#ok<JAPIMATHWORKS> 
            else
                rptgen.internal.docbook.DocbookDocument.enableDoctype(h.SrcFileName,false);
            end

            locProcessJadeMessages(messages);

            if h.ImportFiles


                h.importExternalFiles;
            end

            report=h.up;
            isView=~isempty(report)&&isa(report,'rptgen.coutline')&&report.isView;

            if strncmpi(h.Format,'doc',3)
                try
                    rptgen.displayMessage(getString(message('rptgen:rx_db_output:rtfToDocMsg')),3);
                    wdoc=mlreportgen.utils.word.load(h.DstFileName);
                    update(wdoc);
                    unlinkFields(wdoc,'wdFieldIncludePicture','wdFieldIncludeText');
                    saveAsDoc(wdoc);
                    if~isView
                        close(wdoc,0);
                        locCloseWordIfNoOpenDocs();
                    end
                catch ME
                    rptgen.displayMessage(getString(message('rptgen:rx_db_output:docConversionFailed')),2);

                    if strcmp(ME.identifier,"mlreportgen:utils:error:OfficeAutomationNoninteractiveSession")
                        rptgen.displayMessage(getString(message("rptgen:rx_db_output:DocumentNotUpdatedByNoninteractiveSession",h.DstFileName)),2);
                    elseif strcmp(ME.identifier,"mlreportgen:utils:error:OfficeAutomationRemoteClient")
                        rptgen.displayMessage(getString(message("rptgen:rx_db_output:DocumentNotUpdatedByRemoteSession",h.DstFileName)),2);
                    elseif strcmp(ME.identifier,"mlreportgen:utils:error:OfficeAutomationSession0")
                        rptgen.displayMessage(getString(message("rptgen:rx_db_output:DocumentNotUpdatedBySession0",h.DstFileName)),2);
                    else
                        rptgen.displayMessage(ME.message,2);
                    end

                    rptgen.displayMessage(getString(message("rptgen:rx_db_output:InstructionsToUpdateFields")),2);
                    rptgen.displayMessage(getString(message("rptgen:rx_db_output:InstructionsToUnlinkSubdocuments")),2);
                end
            elseif strncmpi(h.Format,'rtf',3)
                if mlreportgen.utils.word.isAvailable()
                    wdoc=mlreportgen.utils.word.load(h.DstFileName);
                    update(wdoc);
                    save(wdoc);
                    if~isView
                        close(wdoc,0);
                        locCloseWordIfNoOpenDocs();
                    end
                end
            end


            function locProcessJadeMessages(messages)

                for i=1:length(messages)
                    line=messages{i};
                    if~contains(line,'Link to missing ID')


                        colons=strfind(line,':');
                        if~isempty(colons)
                            character=line(colons(length(colons))-1);
                            switch upper(character)
                            case 'E'
                                priority=1;
                                if contains(line,'dbl1ja.dsl')
                                    priority=6;
                                end
                            case 'W'
                                priority=2;
                            case 'I'
                                priority=5;
                            case 'X'
                                priority=7;
                            case 'L'
                                priority=6;



                            otherwise
                                priority=4;
                            end
                        else
                            if contains(line,'builtins.dsl')
                                priority=6;
                            else
                                priority=1;
                            end
                        end
                        rptgen.displayMessage(line,priority)
                    end
                end


                function locRepackageDOMTemplate(templateDir,extension)
                    dirContents=dir(templateDir);

                    zipContents={};
                    for i=1:length(dirContents)
                        name=dirContents(i).name;
                        if~strcmp(name,'.')&&~strcmp(name,'..')
                            zipContents=[zipContents,{fullfile(templateDir,name)}];%#ok<AGROW>
                        end
                    end
                    zip(templateDir,zipContents);
                    templateFile=[templateDir,extension];

                    movefile([templateDir,'.zip'],templateFile);


                    function locRunDB2DOMEngine(h,tSource,format)


                        format=char(format.getID);




                        [outputPathDir,outputPathName,outputExt]=fileparts(h.DstFileName);
                        if strcmpi(outputExt,'.pdf')
                            outputPath=fullfile(outputPathDir,outputPathName);
                        else
                            outputPath=h.DstFileName;
                        end

                        isdocx2pdf=false;
                        isdocx=false;

                        switch format
                        case 'dom-docx'
                            domFormat='docx';
                            isdocx=true;
                        case 'dom-htmx'
                            domFormat='html';
                        case 'dom-html-file'
                            domFormat='html-file';
                        case 'dom-pdf'
                            if~ispc
                                error(message('rptgen:rptgenrptgen:pdfFromTemplateUnsupported'));
                            end
                            isdocx2pdf=true;
                            format='dom-docx';
                            domFormat='docx';
                        case 'dom-pdf-direct'
                            domFormat='pdf';
                        end

                        try
                            tID=h.getStylesheetID();


                            formatChar=char(h.getFormat().getID());
                            if strcmpi(formatChar,'dom-docx')||strcmpi(formatChar,'dom-pdf')
                                templateErr=h.checkWordTemplateOpen();
                                if~isempty(templateErr)
                                    error(templateErr);
                                end
                            end

%#function rptgen.db2dom.TemplateCache
                            templateCache=rptgen.db2dom.TemplateCache.getTheCache();

                            switch format
                            case 'dom-docx'
                                templatePath=getDOCXTemplate(templateCache,tID);
                            case 'dom-html-file'
                                templatePath=getHTMLFileTemplate(templateCache,tID);
                            case 'dom-htmx'
                                templatePath=getHTMLTemplate(templateCache,tID);
                            case 'dom-pdf-direct'
                                templatePath=getPDFTemplate(templateCache,tID);
                            end

                            if~isempty(templatePath)&&exist(templatePath,'file')==2


                                if strcmpi(domFormat,'html')
                                    [tParentDir,tName,~]=fileparts(templatePath);
                                    tDir=fullfile(tParentDir,tName);
                                    if exist(tDir,'dir')
                                        locRepackageDOMTemplate(tDir,'.htmtx');
                                    end
                                end


                                if strcmpi(domFormat,'pdf')
                                    [tParentDir,tName,~]=fileparts(templatePath);
                                    tDir=fullfile(tParentDir,tName);
                                    if exist(tDir,'dir')
                                        locRepackageDOMTemplate(tDir,'.pdftx');
                                    end
                                end



                                db=eval('mlreportgen.db2dom.DocBook');%#ok<EVLCS> 
                                db.OutputPath=outputPath;
                                if strcmpi(domFormat,'html')
                                    db.PackageType=h.PackageType;
                                end
                                db.Type=domFormat;

                                db.TemplatePath=templatePath;

                                db.Language=h.Language;

                                isCopiedTempl=strcmp(format,'dom-docx')&&hasDOCXTemplateCopy(templateCache);
                                if isCopiedTempl
                                    db.TemplatePath=getDOCXTemplateCopy(templateCache);
                                end

                                rgAd=rptgen.appdata_rg;
                                if rgAd.DebugMode||rgAd.RetainFO
                                    db.RetainFO=true;
                                end



                                appendDocBookXMLFile(db,tSource);
                                close(db);

                                if isCopiedTempl
                                    discardDOCXTemplateCopy(templateCache);
                                end


                                if isdocx2pdf
                                    try
                                        wdoc=mlreportgen.utils.word.load(db.OutputPath);
                                        update(wdoc);
                                        save(wdoc);
                                        exportToPDF(wdoc);
                                        close(wdoc,0);
                                        locCloseWordIfNoOpenDocs();
                                    catch ME
                                        rptgen.displayMessage(getString(message("rptgen:rx_db_output:UnableToConvertToPDF",ME.message)));
                                    end
                                end


                                if isdocx
                                    try
                                        wdoc=mlreportgen.utils.word.load(db.OutputPath);
                                        unlinkSubdocuments(wdoc);
                                        update(wdoc);
                                        save(wdoc);
                                        close(wdoc);
                                        locCloseWordIfNoOpenDocs();
                                    catch ME
                                        if strcmp(ME.identifier,"mlreportgen:utils:error:OfficeAutomationNoninteractiveSession")
                                            rptgen.displayMessage(getString(message("rptgen:rx_db_output:DocumentNotUpdatedByNoninteractiveSession",db.OutputPath)),2);
                                        elseif strcmp(ME.identifier,"mlreportgen:utils:error:OfficeAutomationRemoteClient")
                                            rptgen.displayMessage(getString(message("rptgen:rx_db_output:DocumentNotUpdatedByRemoteSession",db.OutputPath)),2);
                                        elseif strcmp(ME.identifier,"mlreportgen:utils:error:OfficeAutomationSession0")
                                            rptgen.displayMessage(getString(message("rptgen:rx_db_output:DocumentNotUpdatedBySession0",db.OutputPath)),2);
                                        else
                                            rptgen.displayMessage(ME.message,2);
                                        end

                                        rptgen.displayMessage(getString(message("rptgen:rx_db_output:InstructionsToUpdateFields")),2);
                                        rptgen.displayMessage(getString(message("rptgen:rx_db_output:InstructionsToUnlinkSubdocuments")),2);
                                    end
                                end

                            else
                                ME=MException('Rptgen:convertReport:templateNotFound',...
                                getString(message('rptgen:rx_db_output:noTemplateMsg',tID)));
                                throw(ME);
                            end

                        catch ME

                            rethrow(ME)
                        end


                        function locCloseWordIfNoOpenDocs()
                            if isempty(mlreportgen.utils.word.filenames())
                                mlreportgen.utils.word.close();
                            end


                            function locRunXsltEngine(h,tSource,theFormat)




                                prevDir=pwd;
                                targetDir=fileparts(h.DstFileName);
                                cd(targetDir);%#ok<MCCD>

                                try

                                    if rptgen.use_java
                                        formatFOP='com.mathworks.toolbox.rptgencore.output.OutputFormatFOP';
                                    else
                                        formatFOP='rptgen.internal.output.OutputFormatFOP';
                                    end

                                    if isa(theFormat,formatFOP)
                                        [compiledStylesheet,styleID,xsltDriverFile]=...
                                        locRunXsltPDF(h,tSource,theFormat);
                                    else
                                        [compiledStylesheet,styleID,xsltDriverFile]=...
                                        locRunXsltHTML(h,tSource,theFormat);
                                    end

                                    locSetCachedStylesheet(styleID,compiledStylesheet,xsltDriverFile);
                                    cd(prevDir);%#ok<MCCD>

                                catch ME


                                    cd(prevDir);%#ok<MCCD>
                                    rethrow(ME)
                                end



                                function[compiledStylesheet,styleID,xsltDriverFile]=...
                                    locRunXsltPDF(h,tSource,theFormat)

                                    adRG=rptgen.appdata_rg;

                                    xsltParameters=locGetXsltFoParameters();

                                    [stylesheet,styleID,xsltDriverFile]=locGetXsltStylesheet(...
                                    h,...
                                    theFormat,...
                                    xsltParameters);

                                    if rptgen.use_java

                                        errorListener=com.mathworks.toolbox.rptgencore.tools.TransformErrorListenerRG();%#ok<JAPIMATHWORKS> 
                                        xsltSource=locGetXsltSource(tSource,errorListener);


                                        if(~isempty(theFormat.getID)&&theFormat.getID.equalsIgnoreCase('fot'))

                                            [fpath,fname]=fileparts(h.DstFileName);
                                            foFile=fullfile(fpath,[fname,'.fo']);

                                            xsltDestination=java.io.File(foFile);
                                            [~,compiledStylesheet]=xslt(xsltSource,...
                                            stylesheet,...
                                            xsltDestination,...
                                            errorListener);
                                        else
                                            if isempty(getenv("USE_FOP"))

                                                [fpath,fname]=fileparts(h.DstFileName);
                                                foFile=fullfile(fpath,[fname,'.fo']);

                                                xsltDestination=java.io.File(foFile);

                                                [~,compiledStylesheet]=xslt(xsltSource,...
                                                stylesheet,...
                                                xsltDestination,...
                                                errorListener);

                                                scopeDeleteFO=onCleanup(@()delete(foFile));
                                                mlreportgen.internal.fop.foToPDF(...
                                                foFile,...
                                                h.DstFileName,...
                                                'DebugMode',adRG.DebugMode);
                                            else


                                                [fop,fopOutputStream]=rptgen.utils.FOPProxy.newFOP(h.DstFileName,adRG.Language);
                                                xsltDestination=javax.xml.transform.sax.SAXResult(getDefaultHandler(fop));
                                                [~,compiledStylesheet]=xslt(xsltSource,...
                                                stylesheet,...
                                                xsltDestination,...
                                                errorListener);
                                                fopOutputStream.close();
                                            end

                                        end
                                    else
                                        xsltSource=locGetXsltSource(tSource,[]);
                                        [fpath,fname]=fileparts(h.DstFileName);
                                        foFile=fullfile(fpath,[fname,'.fo']);
                                        xsltDestination=foFile;
                                        xfrmr=mlreportgen.re.internal.xml.transform.Transformer;
                                        transform(xfrmr,xsltSource,stylesheet,xsltDestination);
                                        compiledStylesheet=stylesheet;

                                        scopeDeleteFO=onCleanup(@()delete(foFile));

                                        mlreportgen.internal.fop.foToPDF(...
                                        foFile,...
                                        h.DstFileName,...
                                        'DebugMode',adRG.DebugMode);
                                    end



                                    function[compiledStylesheet,styleID,xsltDriverFile]=...
                                        locRunXsltHTML(h,tSource,theFormat)

                                        [stylesheet,styleID,xsltDriverFile]=locGetXsltStylesheet(...
                                        h,...
                                        theFormat,...
                                        {});

                                        if rptgen.use_java

                                            errorListener=com.mathworks.toolbox.rptgencore.tools.TransformErrorListenerRG();%#ok<JAPIMATHWORKS> 
                                            xsltSource=locGetXsltSource(tSource,errorListener);
                                            xsltDestination=java.io.File(h.DstFileName);

                                            [~,compiledStylesheet]=xslt(xsltSource,...
                                            stylesheet,...
                                            xsltDestination,...
                                            errorListener);
                                        else
                                            xsltSource=locGetXsltSource(tSource,[]);
                                            xsltDestination=h.DstFileName;

                                            xfrmr=matlab.io.xml.transform.Transformer;
                                            stylesheet=compileStylesheet(xfrmr,xsltDriverFile);

                                            transform(xfrmr,xsltSource,stylesheet,xsltDestination);
                                            compiledStylesheet=stylesheet;
                                        end

                                        h.importExternalFiles;


                                        function xsltSource=locGetXsltSource(tSource,errorListener)

                                            if isa(tSource,'rpt_xml.document')
                                                if rptgen.use_java

                                                    xsltSource=java(tSource);
                                                else
                                                    xsltSource=matlab.io.xml.tranform.DocumentSource(tSource.Document);
                                                end
                                            else
                                                if rptgen.use_java

                                                    saxParserFactory=javax.xml.parsers.SAXParserFactory.newInstance();


                                                    saxParserFactory.setValidating(false);


                                                    saxParserFactory.setNamespaceAware(true);

                                                    xmlReader=saxParserFactory.newSAXParser.getXMLReader();
                                                    xmlReader.setErrorHandler(errorListener);

                                                    try




                                                        uriResolver=com.mathworks.toolbox.rptgencore.tools.UriResolverRG();%#ok<JAPIMATHWORKS> 
                                                        xmlReader.setEntityResolver(uriResolver);
                                                    catch ME



                                                        rptgen.displayMessage(getString(message('rptgen:rx_db_output:missingResolverMsg')),2);
                                                        rptgen.displayMessage(ME.message,5);
                                                    end



                                                    tSourceURL=rptgen.file2urn(tSource);

                                                    saxInputSource=org.xml.sax.InputSource(tSourceURL);




                                                    saxSource=javax.xml.transform.sax.SAXSource(xmlReader,saxInputSource);
                                                    saxSource.setSystemId(tSourceURL);

                                                    xsltSource=saxSource;
                                                else
                                                    xsltSource=tSource;
                                                end
                                            end


                                            function styleID=locGetStylesheetID(h,xsltParameters)
                                                styleID=h.getStylesheetID();

                                                if(~isempty(xsltParameters))
                                                    styleID=[styleID,rptgen.toString(xsltParameters,inf,'')];
                                                end


                                                function[stylesheet,styleID,xsltDriverFile]=locGetXsltStylesheet(...
                                                    h,theFormat,xsltParameters)

                                                    styleID=locGetStylesheetID(h,xsltParameters);
                                                    stylesheet=locGetXsltCachedStylesheet(styleID);
                                                    xsltDriverFile='';

                                                    if isempty(stylesheet)
                                                        try
                                                            stylesheet=h.getStylesheet(theFormat,xsltParameters{:});

                                                            if rptgen.use_java
                                                                xsltDriverFile=char(stylesheet.getSystemId);
                                                                xsltDriverFile=rptgen.urn2file(xsltDriverFile);
                                                            else
                                                                xsltDriverFile=stylesheet;
                                                                stylesheet=mlreportgen.re.internal.xml.transform.CompiledStylesheet(xsltDriverFile);
                                                            end

                                                        catch cause1_ME
                                                            rptgen.displayMessage(getString(message('rptgen:rx_db_output:missingStylesheetMsg',styleID)),2);
                                                            rptgen.displayMessage(cause1_ME.message,5);

                                                            base_ME=MException('rptgen:rx_db_output:haltDocumentConversion',...
                                                            getString(message('rptgen:rx_db_output:haltDocumentConversion')));
                                                            new_ME=base_ME.addCause(cause1_ME);
                                                            throw(new_ME);
                                                        end
                                                    end


                                                    function cachedStylesheet=locGetXsltCachedStylesheet(styleID)

                                                        try
                                                            if rptgen.use_java
                                                                cachedStylesheet=com.mathworks.toolbox.rptgencore.output.StylesheetCache.getCachedStylesheet(styleID);%#ok<JAPIMATHWORKS> 
                                                            else
                                                                cachedStylesheet=rptgen.internal.output.StylesheetCache.getCachedStylesheet(styleID);
                                                            end
                                                        catch ME
                                                            rptgen.displayMessage(getString(message('rptgen:rx_db_output:noCachedStylesheetMsg')),3);
                                                            rptgen.displayMessage(ME.message,5);
                                                            cachedStylesheet=[];
                                                        end


                                                        function locSetCachedStylesheet(styleID,compiledStylesheet,xsltDriverFile)

                                                            try
                                                                if rptgen.use_java
                                                                    com.mathworks.toolbox.rptgencore.output.StylesheetCache.setCachedStylesheet(...
                                                                    styleID,compiledStylesheet);%#ok<JAPIMATHWORKS> 
                                                                else
                                                                    rptgen.internal.output.StylesheetCache.setCachedStylesheet(...
                                                                    styleID,compiledStylesheet);
                                                                end

                                                                if exist(xsltDriverFile,'file')

                                                                    delete(xsltDriverFile);
                                                                end

                                                            catch ME
                                                                rptgen.displayMessage(getString(message('rptgen:rx_db_output:unableToCacheStylesheet')),2);
                                                                rptgen.displayMessage(ME.message,5);
                                                            end


                                                            function xsltParameters=locGetXsltFoParameters()

                                                                xsltParameters={...


                                                                'draft.watermark.image','http://www.mathworks.com/namespace/docbook/v4/xsl/images/draft.png',...
                                                                'fop.extensions','0'...
                                                                ,'fop1.extensions','1'...
                                                                ,'callout.graphics.path','http://www.mathworks.com/namespace/docbook/v4/xsl/images/callouts/'};



                                                                hyphfile=fullfile(toolboxdir('shared/rptgen'),'resources','hyph','default.xml');
                                                                xsltParameters=[xsltParameters,{'hyphenate',(exist(hyphfile,'file')==2)}];




