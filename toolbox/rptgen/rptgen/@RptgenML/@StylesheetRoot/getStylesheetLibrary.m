function varargout=getStylesheetLibrary(this,libAction)









    root=RptgenML.Root;

    ssLib=this.StylesheetLibrary;
    if isempty(ssLib)
        if nargin>1&&strcmpi(libAction,'-asynchronous')&&~isempty(root.Editor)

            ssLib=RptgenML.Message(getString(message('rptgen:RptgenML_StylesheetRoot:searchingLabel')),...
            getString(message('rptgen:RptgenML_StylesheetRoot:buildingStylesheetLibraryLabel')));

            mlreportgen.utils.internal.defer(@()this.getStylesheetLibrary('-deferred'));

            if nargout>0
                varargout={ssLib};
            end
            return;
        end




        ssLib=RptgenML.Library;
        this.StylesheetLibrary=ssLib;

        typeCat=this.CategoryNew;

        ss=RptgenML.StylesheetEditor.createLibrary('-NEW_HTML');connect(ss,typeCat,'up');
        ss=RptgenML.StylesheetEditor.createLibrary('-NEW_HTML_CHUNKED');connect(ss,typeCat,'up');
        ss=RptgenML.StylesheetEditor.createLibrary('-NEW_FO');connect(ss,typeCat,'up');
        ss=RptgenML.StylesheetEditor.createLibrary('-NEW_DSSSL');connect(ss,typeCat,'up');




        ssFiles=which('rptstylesheets.xml','-all');
        ssFileCount=length(ssFiles);
        for i=1:ssFileCount


            nl=com.mathworks.toolbox.rptgencore.tools.StylesheetMaker.findStylesheetRegistryElements(ssFiles{i});
            nlCount=nl.getLength;
            for j=1:nlCount
                try

                    ss=com.mathworks.toolbox.rptgencore.tools.StylesheetMaker(nl.item(j-1));
                    ss.setRegistry(ssFiles{i});
                    ss=RptgenML.StylesheetEditor.createLibrary(ss);
                    this.addStylesheetToLibrary(ss);
                catch ME
                    warning(ME.message);
                end
            end
        end




        pSep=pathsep;
        if isempty(findstr(lower(pwd),lower(path)))
            pathString=[pSep,pwd,pSep,path,pSep];
        else
            pathString=[pSep,path,pSep];
        end

        breakIndex=findstr(pathString,pSep);

        lastIndex=length(breakIndex)-1;
        dirIdx=1;

        CONTINUE_SEARCH=true;

        searchTermRGS=[filesep,'*',char(com.mathworks.toolbox.rptgencore.tools.StylesheetMaker.FILE_EXT_SS)];
        while dirIdx<=lastIndex&&CONTINUE_SEARCH
            myDir=pathString(breakIndex(dirIdx)+1:breakIndex(dirIdx+1)-1);
            fileList=dir([myDir,searchTermRGS]);
            if~isempty(fileList)
                for fileIdx=1:length(fileList)
                    fileName=fileList(fileIdx).name;
                    if strcmp(fileName(1:2),'~$')
                        continue;
                    end
                    try
                        ss=com.mathworks.toolbox.rptgencore.tools.StylesheetMaker([],fullfile(myDir,fileName));
                        ss=RptgenML.StylesheetEditor.createLibrary(ss);
                        this.addStylesheetToLibrary(ss);
                    catch ME
                        warning(ME.message);
                    end
                end
            end
            dirIdx=dirIdx+1;
        end


        if nargin>1&&strcmpi(libAction,'-deferred')&&~isempty(root.Editor)


            refreshWhenReady(root);
        end
    elseif nargin>1&&strcmpi(libAction,'-clear')
        ssLib=[];
        this.StylesheetLibrary=ssLib;
        this.CategoryNEW=[];
        this.CategoryHTML=[];
        this.CategoryFO=[];
        this.CategoryDSSSL=[];
        this.CategoryDSSSLHTML=[];
        this.CategoryLATEX=[];
        this.CategoryEmpty=[];
    end

    if nargout>0
        varargout={ssLib};
    end





