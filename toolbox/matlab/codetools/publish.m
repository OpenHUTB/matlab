function outputAbsoluteFilename=publish(file,options,varargin)

    if nargin>0
        file=convertContainedStringsToChars(file);
    end

    if nargin>1
        options=convertContainedStringsToChars(options);
    end

    if nargin>2
        [varargin{:}]=convertContainedStringsToChars(varargin{:});
    end

    if~usejava('jvm')
        error(pm('NoJvm'));
    end


    if(nargin>2)
        pv=[{options},varargin];
        options=cell2struct(pv(2:2:end),pv(1:2:end),2);
    end


    if(nargin<2)
        options='html';
    end


    if ischar(options)
        t=options;
        options=struct;
        options.format=t;
    end


    checkOptionFields(options);
    options=supplyDefaultOptions(options);
    validateOptions(options)
    format=options.format;


    [filePath,~,fileExt]=fileparts(file);
    switch fileExt


    case{'mdl','slx'}
        error(pm('OnlyCode'));
    end




    if contains(filePath,'+')
        error(pm('PackageInInputFilePath'));
    end


    fullPathToScript=locateFile(file);
    if isempty(fullPathToScript)
        error(pm('SourceNotFound',file));
    end


    isCodeExtension=@(x)(strcmp(x,'.m')||strcmp(x,'.mlx'));
    [scriptDir,prefix,ext]=fileparts(fullPathToScript);
    if~isCodeExtension(ext)

        getExtension=@(x)returnNthOfM(@fileparts,3,3,x);
        hasCodeExtension=@(x)isCodeExtension(getExtension(x));
        if any(cellfun(hasCodeExtension,which('-all',prefix)))
            error(pm('Shadowed',fullPathToScript));
        else
            error(pm('OnlyCode'));
        end
    end

    if strcmpi(ext,'.mlx')
        warning(pm('MLXExportHint'));
    end



    options=setCodeToEvaluateIfEmpty(file,options,fullPathToScript);


    if isfield(options,'outputDir')&&~isempty(options.outputDir)
        outputDir=options.outputDir;


        if(matlab.io.internal.common.isAbsolutePath(outputDir))
            outputDir=fullfile(outputDir,filesep);
        else
            outputDir=fullfile(pwd,outputDir,filesep);
        end

        outputDir=regexprep(outputDir,'[/\\]$','');
    else
        outputDir=fullfile(scriptDir,'html');
    end
    switch format
    case 'latex'
        ext='tex';
    otherwise
        ext=format;
    end
    outputAbsoluteFilename=fullfile(outputDir,[prefix,'.',ext]);


    error(prepareOutputLocation(outputAbsoluteFilename));


    switch format
    case{'doc','ppt','pdf'}
        imageDir=tempdir;

        imageDir(end)=[];
        needToCleanTempdir=true;
    otherwise
        imageDir=outputDir;
        needToCleanTempdir=false;
    end




    deleteExistingImages(imageDir,prefix,false)


    [dom,cellBoundaries]=m2mxdom(file2char(fullPathToScript));


    newNode=dom.createElement('m-file');
    newTextNode=dom.createTextNode(prefix);
    newNode.appendChild(newTextNode);
    dom.getFirstChild.appendChild(newNode);
    newNode=dom.createElement('filename');
    newTextNode=dom.createTextNode(fullPathToScript);
    newNode.appendChild(newTextNode);
    dom.getFirstChild.appendChild(newNode);
    newNode=dom.createElement('outputdir');
    newTextNode=dom.createTextNode(outputDir);
    newNode.appendChild(newTextNode);
    dom.getFirstChild.appendChild(newNode);
    if isfield(options,'callback')
        newNode=dom.createElement('callback');
        newTextNode=dom.createTextNode(options.callback);
        newNode.appendChild(newTextNode);
        dom.getFirstChild.appendChild(newNode);
    end


    dom=createEquationImages(dom,imageDir,prefix,format,outputDir);


    if options.evalCode
        dom=evalmxdom(file,dom,cellBoundaries,prefix,imageDir,outputDir,options);
    end


    dom=removeDisplayCode(dom,options.showCode);
    dom=truncateOutput(dom,options.maxOutputLines);
    dom=postEval(dom);


    try
        switch format
        case 'xml'
            if isempty(options.stylesheet)
                xmlwrite(outputAbsoluteFilename,dom)
            else
                xslt(dom,options.stylesheet,outputAbsoluteFilename);
            end

        case 'html'
            xslt(dom,options.stylesheet,outputAbsoluteFilename);

        case 'latex'
            xslt(dom,options.stylesheet,outputAbsoluteFilename);
            resaveWithNativeEncoding(outputAbsoluteFilename)

        case 'doc'
            mxdom2word(dom,outputAbsoluteFilename);

        case 'ppt'
            mxdom2ppt(dom,outputAbsoluteFilename);

        case 'docbook'
            xslt(dom,options.stylesheet,outputAbsoluteFilename);
            resaveWithNativeEncoding(outputAbsoluteFilename)

        case 'pdf'
            publishToPdf(dom,options,outputAbsoluteFilename)
        end
    catch ex
        if isprop(ex,'ExceptionObject')&&isa(ex.ExceptionObject,'javax.xml.transform.TransformerException')
            error(pm('invalidXmlChar'))
        else
            rethrow(ex)
        end
    end



    if needToCleanTempdir
        try
            deleteExistingImages(imageDir,prefix,true)
        catch %#ok<CTCH>

        end
    end
    if strcmp(format,'doc')&&(numel(dir(fullfile(tempdir,'VBE')))==2)

        try
            rmdir(fullfile(tempdir,'VBE'))
        catch %#ok<CTCH>

        end
    end


    function nthOutput=returnNthOfM(f,n,m,varargin)
        outputs=cell(1,m);
        [outputs{:}]=f(varargin{:});
        nthOutput=outputs{n};


        function checkOptionFields(options)
            validOptions={'format','stylesheet','outputDir','imageFormat',...
            'figureSnapMethod','dockedFigureSnapMethod','useNewFigure','maxHeight','maxWidth','showCode',...
            'evalCode','stopOnError','catchError','displayError','createThumbnail','maxOutputLines',...
            'codeToEvaluate','font','titleFont','bodyFont','monospaceFont',...
            'maxThumbnailHeight','maxThumbnailWidth','callback'};
            bogusFields=setdiff(fieldnames(options),validOptions);
            if~isempty(bogusFields)
                error(pm('InvalidOption',bogusFields{1}));
            end


            function options=supplyDefaultOptions(options)

                if~isfield(options,'format')
                    options.format='html';
                end
                format=options.format;
                privateDir=fullfile(fileparts(mfilename('fullpath')),'private');

                if~isfield(options,'stylesheet')||isempty(options.stylesheet)
                    switch format
                    case 'html'
                        styleSheet=fullfile(privateDir,'mxdom2simplehtml.xsl');
                        options.stylesheet=styleSheet;
                    case 'latex'
                        styleSheet=fullfile(privateDir,'mxdom2latex.xsl');
                        options.stylesheet=styleSheet;
                    case{'docbook','pdf'}
                        styleSheet=fullfile(privateDir,'mxdom2docbook.xsl');
                        options.stylesheet=styleSheet;
                    otherwise
                        options.stylesheet='';
                    end
                end
                if~isfield(options,'figureSnapMethod')
                    options.figureSnapMethod='entireGUIWindow';
                end
                if isUseEntireFigureWindowForDockedFigures(options)
                    options.dockedFigureSnapMethod='entireFigureWindow';
                end
                if~isfield(options,'imageFormat')||isempty(options.imageFormat)
                    options.imageFormat='';
                elseif strcmp(options.imageFormat,'jpg')
                    options.imageFormat='jpeg';
                elseif strcmp(options.imageFormat,'tif')
                    options.imageFormat='tiff';
                elseif strcmp(options.imageFormat,'gif')
                    error(pm('NoGIFs'));
                end
                if~isfield(options,'useNewFigure')
                    options.useNewFigure=true;
                end
                if~isfield(options,'maxHeight')
                    options.maxHeight=[];
                end
                if~isfield(options,'maxWidth')
                    options.maxWidth=[];
                end
                if~isfield(options,'maxThumbnailHeight')
                    options.maxThumbnailHeight=64;
                end
                if~isfield(options,'maxThumbnailWidth')
                    options.maxThumbnailWidth=85;
                end
                if~isfield(options,'showCode')
                    options.showCode=true;
                end
                if~isfield(options,'evalCode')
                    options.evalCode=true;
                end
                if~isfield(options,'stopOnError')
                    options.stopOnError=true;
                end
                if~isfield(options,'catchError')
                    options.catchError=true;
                end
                if~isfield(options,'displayError')
                    options.displayError=true;
                end
                if~isfield(options,'createThumbnail')
                    options.createThumbnail=true;
                end
                if~isfield(options,'maxOutputLines')
                    options.maxOutputLines=Inf;
                end
                if~isfield(options,'codeToEvaluate')
                    options.codeToEvaluate='';
                end
                if~isfield(options,'font')
                    options.font='';
                end
                if~isfield(options,'titleFont')
                    options.titleFont=options.font;
                end
                if~isfield(options,'bodyFont')
                    options.bodyFont=options.font;
                end
                if~isfield(options,'monospaceFont')
                    options.monospaceFont=options.font;
                end


                function validateOptions(options)


                    supportedFormats={'html','doc','ppt','xml','rpt','latex','pdf','docbook'};
                    if~any(strcmp(options.format,supportedFormats))
                        error(pm('UnknownFormat',options.format));
                    end


                    if~isempty(options.stylesheet)&&~exist(options.stylesheet,'file')
                        error(pm('StylesheetNotFound',options.stylesheet))
                    end


                    logicalScalarOptions={'useNewFigure','showCode','evalCode','catchError','displayError','createThumbnail'};
                    isLogicalScalarOrEmpty=@(x)...
                    isempty(options.(x))||...
                    (islogical(options.(x))&&(numel(options.(x))==1));
                    badOptions=logicalScalarOptions(~cellfun(isLogicalScalarOrEmpty,logicalScalarOptions));
                    if~isempty(badOptions)
                        error(pm('InvalidBoolean',badOptions{1}))
                    end


                    if~isnumeric(options.maxOutputLines)||...
                        (numel(options.maxOutputLines)~=1)||...
                        (options.maxOutputLines<0)||...
                        isnan(options.maxOutputLines)||...
                        (round(options.maxOutputLines)~=options.maxOutputLines)
                        error(pm('InvalidMaxOutputLines'));
                    end


                    isEmptyOrPositiveInteger=@(x)isempty(x)||...
                    (isnumeric(x)&&numel(x)==1&&x>0&&round(x)==x);
                    for field={'maxWidth','maxHeight','maxThumbnailHeight','maxThumbnailWidth'}
                        f=field{1};
                        if~isEmptyOrPositiveInteger(options.(f))
                            error(pm('MustBeEmptyOrPositiveInteger',f))
                        end
                    end


                    vectorFormats=internal.matlab.publish.getVectorFormats();
                    if any(strcmp(options.imageFormat,vectorFormats))
                        if strcmp(options.figureSnapMethod,'getframe')
                            error(pm('VectorAndGetframe',options.imageFormat))
                        end
                        if~isempty(options.maxHeight)||~isempty(options.maxWidth)
                            warning(pm('VectorSize',upper(options.imageFormat)))
                        end
                    end


                    if strcmp(options.format,'pdf')&&...
                        ~isempty(options.imageFormat)&&...
                        ~(strcmp(options.imageFormat,'bmp')||strcmp(options.imageFormat,'jpeg'))
                        error(pm('InvalidPDFImageFormat'));
                    end


                    if~isempty(options.stopOnError)&&(options.stopOnError==false)
                        warning(pm('StopOnErrorDeprecated'))
                    end


                    function options=setCodeToEvaluateIfEmpty(file,options,fullPathToScript)
                        if isempty(options.codeToEvaluate)

                            cmd=regexprep(file,'.*[\\/]','');
                            cmd=regexprep(cmd,'\.(?:m|mlx)$','');
                            foundAt=safeWhich(cmd);

                            if~strcmpi(strrep(fullPathToScript,'/',filesep),foundAt)&&...
                                (options.evalCode==true)
                                if isempty(foundAt)
                                    error(pm('OffPath'))
                                else
                                    error(pm('Shadowed',foundAt))
                                end
                            end
                            options.codeToEvaluate=cmd;
                        end


                        function deleteExistingImages(imageDir,prefix,equations)


                            d=dir(fullfile(imageDir,[prefix,'_*.*']));


                            nonEquationImagePattern=['^',prefix,'_(\d{2,}\.[A-Za-z]+)$'];
                            equationImagePattern=['^',prefix,'_(eq\d+\.(?:png))$'];



                            [lastmsg,lastid]=lastwarn('');
                            warningMessage='';

                            for i=1:length(d)
                                toDelete=fullfile(imageDir,d(i).name);
                                if~isempty(regexp(d(i).name,nonEquationImagePattern,'once'))
                                    delete(toDelete);
                                elseif~isempty(regexp(d(i).name,equationImagePattern,'once'))

                                    fileContent=dir(toDelete);
                                    if(equations||fileContent.bytes==0)
                                        delete(toDelete);
                                    end
                                end
                                if~isempty(lastwarn)
                                    if isempty(warningMessage)
                                        warningMessage=lastwarn;
                                    else
                                        warningMessage=[warningMessage,newline,lastwarn];
                                    end
                                end
                            end

                            if~isempty(warningMessage)
                                error(pm('CannotDelete',warningMessage));
                            end


                            thumbnail=fullfile(imageDir,[prefix,'.png']);
                            if~isempty(dir(thumbnail))
                                delete(thumbnail)
                                if~isempty(lastwarn)
                                    error(pm('CannotDelete',thumbnail))
                                end
                            end


                            lastwarn(lastmsg,lastid);


                            function dom=removeDisplayCode(dom,showCode)
                                if~showCode
                                    while true
                                        codeNodeList=dom.getElementsByTagName('mcode');
                                        if(codeNodeList.getLength==0)
                                            break;
                                        end
                                        codeNode=codeNodeList.item(0);
                                        codeNode.getParentNode.removeChild(codeNode);
                                    end

                                    codeNodeList=dom.getElementsByTagName('mcode-xmlized');
                                    for i=codeNodeList.getLength:-1:1
                                        codeNode=codeNodeList.item(i-1);
                                        if(~strcmp(codeNode.getParentNode.getNodeName,'text'))
                                            codeNode.getParentNode.removeChild(codeNode);
                                        end
                                    end

                                end


                                function dom=truncateOutput(dom,maxOutputLines)
                                    if~isinf(maxOutputLines)
                                        outputNodeList=dom.getElementsByTagName('mcodeoutput');

                                        for iOutputNodeList=outputNodeList.getLength:-1:1
                                            outputNode=outputNodeList.item(iOutputNodeList-1);
                                            if(maxOutputLines==0)
                                                outputNode.getParentNode.removeChild(outputNode);
                                            else
                                                text=char(outputNode.getFirstChild.getData);
                                                newlines=regexp(text,'\n');
                                                if maxOutputLines<=length(newlines)
                                                    chopped=text(newlines(maxOutputLines):end);
                                                    text=text(1:newlines(maxOutputLines));
                                                    if~isempty(regexp(chopped,'\S','once'))
                                                        text=[text,'...'];%#ok<AGROW>
                                                    end
                                                end
                                                outputNode.getFirstChild.setData(text);
                                            end
                                        end
                                    end



                                    function dom=postEval(dom)
                                        postEvalNodeList=dom.getElementsByTagName('mcode-xmlized-post');

                                        for iPostEvalNodeList=postEvalNodeList.getLength:-1:1
                                            inputNode=postEvalNodeList.item(iPostEvalNodeList-1);
                                            code=inputNode.getTextContent;
                                            filename=strtrim(char(code));
                                            [codeoutput,includeWarning]=includeCode(filename);
                                            if isempty(includeWarning)
                                                [~,~,ext]=fileparts(filename);
                                                if isempty(ext)||strcmp(ext,'.m')
                                                    codeNode=dom.createElement('mcode-xmlized');
                                                    node=com.mathworks.widgets.CodeAsXML.xmlize(dom,codeoutput);
                                                else
                                                    codeNode=dom.createElement('pre');
                                                    node=dom.createTextNode(codeoutput);
                                                end
                                                codeNode.appendChild(node);
                                                inputNode.getParentNode.replaceChild(codeNode,inputNode);
                                            else
                                                node=dom.createElement('pre');
                                                node.setAttribute('class','error')
                                                node.appendChild(dom.createTextNode(includeWarning));
                                                inputNode.getParentNode.replaceChild(node,inputNode);
                                            end
                                        end



                                        function resaveWithNativeEncoding(outputAbsoluteFilename)

                                            f=fopen(outputAbsoluteFilename,'r','n','UTF-8');
                                            c=fread(f,'char=>char')';
                                            fclose(f);


                                            f=fopen(outputAbsoluteFilename,'w');
                                            fwrite(f,c,'char');
                                            fclose(f);


                                            function publishToPdf(dom,options,outputAbsoluteFilename)


                                                if~ispc
                                                    imgNodeList=dom.getElementsByTagName('img');
                                                    for i=1:imgNodeList.getLength()
                                                        node=imgNodeList.item(i-1);
                                                        src=char(node.getAttribute('src'));
                                                        if strcmp('/',src)
                                                            node.setAttribute('src',file2urn(src));
                                                        end
                                                    end
                                                end


                                                docbook=xslt(dom,options.stylesheet,'-tostring');


                                                [fopDriver,fopOutputStream]=fopInitialize(options,outputAbsoluteFilename);


                                                saxParserFactory=javax.xml.parsers.SAXParserFactory.newInstance;
                                                saxParserFactory.setValidating(false);
                                                saxParserFactory.setNamespaceAware(true);
                                                xmlReader=saxParserFactory.newSAXParser.getXMLReader();
                                                uriResolver=com.mathworks.toolbox.rptgencore.tools.UriResolverRG();
                                                xmlReader.setEntityResolver(uriResolver);
                                                saxInputSource=org.xml.sax.InputSource(java.io.StringReader(docbook));
                                                saxSource=javax.xml.transform.sax.SAXSource(xmlReader,saxInputSource);

                                                xsltDestination=javax.xml.transform.sax.SAXResult(...
                                                fopDriver.getDefaultHandler());


                                                noToc=dom.getElementsByTagName('steptitle').getLength<3;
                                                xslt(saxSource,getPdfStylesheet(options,noToc),xsltDestination);


                                                fopOutputStream.close;



                                                function[fop,fopOutputStream]=fopInitialize(options,outputAbsoluteFilename)


                                                    logger=com.mathworks.hg.print.MWFopLogger();
                                                    logger.setLevel(logger.LogLevelError);



                                                    fopFactory=com.mathworks.hg.print.MWFopFactory(...
                                                    com.mathworks.toolbox.rptgencore.tools.ResourceResolverRG());


                                                    fopFactory.setBasePath(fileparts(outputAbsoluteFilename));


                                                    fopFactory.setStrictValidation(false);


                                                    fopFactory.setSourceResolution(get(0,'ScreenPixelsPerInch'));
                                                    fopFactory.setTargetResolution(72);


                                                    fopFactory.setAutoDetectFonts(...
                                                    ~all(cellfun(@isempty,{options.titleFont,options.bodyFont,options.monospaceFont})));


                                                    fopFactory.setHyphenationBasePath(fullfile(matlabroot,'sys/namespace/hyph/'));

                                                    fopFactory.setDefaultHyphenationFile(...
                                                    fullfile(matlabroot,'toolbox/shared/rptgen/resources/hyph/en.xml'));

                                                    fopOutputStream=java.io.BufferedOutputStream(java.io.FileOutputStream(outputAbsoluteFilename));
                                                    fop=fopFactory.newFop(fopOutputStream);


                                                    function styleDom=getPdfStylesheet(options,noToc)

                                                        styleDom=com.mathworks.xml.XMLUtils.createDocument('xsl:stylesheet');
                                                        de=styleDom.getDocumentElement();
                                                        de.setAttribute('xmlns:xsl','http://www.w3.org/1999/XSL/Transform');
                                                        de.setAttribute('xmlns','http://www.w3.org/TR/xhtml1/transitional');
                                                        de.setAttribute('version','1.0');
                                                        importNode=styleDom.createElement('xsl:import');
                                                        xslUrl=file2urn(fullfile(matlabroot,...
                                                        '/sys/namespace/docbook/v4/xsl/fo/docbook_rptgen.xsl'));
                                                        importNode.setAttribute('href',xslUrl);
                                                        de.appendChild(importNode);
                                                        addVariable(styleDom,de,'show.comments','0')
                                                        addVariable(styleDom,de,'fop.extensions','0')
                                                        addVariable(styleDom,de,'fop1.extensions','1')
                                                        addVariable(styleDom,de,'body.start.indent','0')
                                                        if noToc
                                                            addVariable(styleDom,de,'generate.toc','0')
                                                        end
                                                        addVariable(styleDom,de,'draft.mode','no')


                                                        addVariable(styleDom,de,'ulink.show','0')
                                                        attributeSet=styleDom.createElement('xsl:attribute-set');
                                                        attributeSet.setAttribute('name','xref.properties');
                                                        de.appendChild(attributeSet);
                                                        addAttribute(styleDom,attributeSet,'text-decoration','underline')
                                                        addAttribute(styleDom,attributeSet,'color','blue')


                                                        sections={'title','body','monospace'};
                                                        for i=1:numel(sections)
                                                            section=sections{i};
                                                            val=options.([section,'Font']);
                                                            if~isempty(val)
                                                                addVariable(styleDom,de,[section,'.font.family'],['''',val,''''])
                                                            end
                                                        end


                                                        function addVariable(dom,node,name,value)
                                                            var=dom.createElement('xsl:variable');
                                                            var.setAttribute('name',name);
                                                            var.setAttribute('select',value);
                                                            node.appendChild(var);


                                                            function addAttribute(dom,attributeSet,name,value)
                                                                attribute=dom.createElement('xsl:attribute');
                                                                attribute.setAttribute('name',name);
                                                                attribute.appendChild(dom.createTextNode(value));
                                                                attributeSet.appendChild(attribute);


                                                                function urnFile=file2urn(fileName)



                                                                    if strncmp(fileName,'file:///',8)

                                                                        urnFile=fileName;

                                                                    else



                                                                        fileName=strrep(fileName,'%','%25');
                                                                        fileName=strrep(fileName,'?','%3F');
                                                                        fileName=strrep(fileName,'#','%23');
                                                                        fileName=strrep(fileName,' ','%20');

                                                                        if strncmp(fileName,'/',1)



                                                                            fileName=strrep(fileName,'\','/');
                                                                            urnFile=['file://',fileName];
                                                                        else


                                                                            fileName=strrep(fileName,'\','/');
                                                                            urnFile=['file:///',fileName];
                                                                        end
                                                                    end




                                                                    function dom=createEquationImages(dom,imageDir,prefix,format,outputDir)


                                                                        switch format
                                                                        case 'latex'
                                                                            return
                                                                        case{'docbook','pdf'}
                                                                            ext='.bmp';
                                                                        otherwise
                                                                            ext='.png';
                                                                        end


                                                                        baseImageName=fullfile(imageDir,prefix);
                                                                        [tempfigure,temptext]=getRenderingFigure;


                                                                        equationList=dom.getElementsByTagName('equation');
                                                                        for i=1:getLength(equationList)
                                                                            equationNode=equationList.item(i-1);
                                                                            equationText=char(equationNode.getTextContent);
                                                                            fullFilename=[baseImageName,'_',hashEquation(equationText),ext];

                                                                            if~isempty(dir(fullFilename))

                                                                                [height,width,~]=size(imread(fullFilename));
                                                                                swapTexForImg(dom,equationNode,outputDir,fullFilename,equationText,width,height)
                                                                            else

                                                                                [x,texWarning]=renderTex(equationText,tempfigure,temptext);
                                                                                if isempty(texWarning)

                                                                                    newSize=ceil(size(x)/2);
                                                                                    frame.cdata=internal.matlab.publish.make_thumbnail(x,newSize(1:2));
                                                                                    frame.colormap=[];

                                                                                    internal.matlab.publish.writeImage(fullFilename,ext(2:end),frame,[],[])

                                                                                    swapTexForImg(dom,equationNode,outputDir,fullFilename,equationText,newSize(2),newSize(1))
                                                                                else

beep
                                                                                    errorNode=dom.createElement('pre');
                                                                                    errorNode.setAttribute('class','error')
                                                                                    errorNode.appendChild(dom.createTextNode(texWarning));


                                                                                    pNode=equationNode.getParentNode;
                                                                                    if isempty(pNode.getNextSibling)
                                                                                        pNode.getParentNode.appendChild(errorNode);
                                                                                    else
                                                                                        pNode.getParentNode.insertBefore(errorNode,pNode.getNextSibling);
                                                                                    end
                                                                                end
                                                                            end
                                                                        end


                                                                        close(tempfigure)


                                                                        function swapTexForImg(dom,equationNode,outputDir,fullFilename,equationText,width,height)

                                                                            equationNode.removeChild(equationNode.getFirstChild);
                                                                            imgNode=dom.createElement('img');
                                                                            imgNode.setAttribute('alt',equationText);
                                                                            imgNode.setAttribute('src',strrep(fullFilename,[outputDir,filesep],''));
                                                                            imgNode.setAttribute('class','equation');
                                                                            scale=internal.matlab.publish.getImageScale();
                                                                            if scale~=1
                                                                                imgNode.setAttribute('scale',num2str(scale));
                                                                                width=round(width/scale);
                                                                                height=round(height/scale);
                                                                            end
                                                                            imgNode.setAttribute('width',sprintf('%ipx',width));
                                                                            imgNode.setAttribute('height',sprintf('%ipx',height));
                                                                            equationNode.appendChild(imgNode);



                                                                            function[tempfigure,temptext]=getRenderingFigure


                                                                                tag=['helper figure for ',mfilename];
                                                                                tempfigure=findall(0,'type','figure','tag',tag);
                                                                                if isempty(tempfigure)
                                                                                    figurePos=get(0,'ScreenSize');
                                                                                    if ispc


                                                                                        figurePos(1:2)=figurePos(3:4)+100;
                                                                                    end

                                                                                    tempfigure=figure(...
                                                                                    'HandleVisibility','off',...
                                                                                    'IntegerHandle','off',...
                                                                                    'Visible','off',...
                                                                                    'PaperPositionMode','auto',...
                                                                                    'PaperOrientation','portrait',...
                                                                                    'Color','w',...
                                                                                    'Position',figurePos,...
                                                                                    'Tag',tag);
                                                                                    tempaxes=axes('position',[0,0,1,1],...
                                                                                    'Parent',tempfigure,...
                                                                                    'XTick',[],'ytick',[],...
                                                                                    'XLim',[0,1],'ylim',[0,1],...
                                                                                    'Visible','off');
                                                                                    temptext=text('Parent',tempaxes,'Position',[.5,.5],...
                                                                                    'HorizontalAlignment','center','FontSize',22,...
                                                                                    'Interpreter','latex');
                                                                                else

                                                                                    tempaxes=findobj(tempfigure,'type','axes');
                                                                                    temptext=findobj(tempaxes,'type','text');
                                                                                end


                                                                                function[x,texWarning]=renderTex(equationText,tempfigure,temptext)


                                                                                    set(temptext,'string','');
                                                                                    drawnow;
                                                                                    [lastMsg,lastId]=lastwarn('');


                                                                                    set(temptext,'string',strrep(equationText,char(10),' '));

                                                                                    currentFontSize=temptext.FontSize;
                                                                                    drawnow;

                                                                                    if(temptext.Extent(1)<=0)||(temptext.Extent(3)>=1)
                                                                                        temptext.FontSize=temptext.FontSize/(temptext.Extent(3)+.05);
                                                                                    end


                                                                                    finishup=onCleanup(@()set(temptext,'FontSize',currentFontSize));


                                                                                    texWarning=lastwarn;
                                                                                    lastwarn(lastMsg,lastId)

                                                                                    if isempty(texWarning)

                                                                                        x=print(tempfigure,'-RGBImage','-r0');


                                                                                        x(1,:,:)=[];
                                                                                        x(:,1,:)=[];

                                                                                        [i,j]=find(sum(double(x),3)~=765);
                                                                                        x=x(min(i):max(i),min(j):max(j),:);
                                                                                        if isempty(x)

                                                                                            x=255*ones(1,3,'uint8');
                                                                                        end
                                                                                    else
                                                                                        x=[];
                                                                                    end






                                                                                    function[codeoutput,includeWarning]=includeCode(filename)
                                                                                        codeoutput='';
                                                                                        includeWarning='';
                                                                                        try
                                                                                            if isempty(filename)
                                                                                                error(pm('NoFileSpecified'));
                                                                                            end
                                                                                            codeToEval=['type ',filename];
                                                                                            codeoutput=evalc(codeToEval);
                                                                                        catch ME
                                                                                            includeWarning=ME.message;
                                                                                        end


                                                                                        function m=pm(id,varargin)
                                                                                            m=message(['MATLAB:publish:',id],varargin{:});


                                                                                            function isSupported=isDebuggingSupported()
                                                                                                import matlab.internal.lang.capability.Capability;
                                                                                                isSupported=Capability.isSupported(Capability.Debugging);


                                                                                                function useEntireFigureWindow=isUseEntireFigureWindowForDockedFigures(options)




                                                                                                    useEntireFigureWindow=~isfield(options,'dockedFigureSnapMethod')||(isfield(options,'dockedFigureSnapMethod')&&strcmp(options.dockedFigureSnapMethod,'entireGroupWindow'));
