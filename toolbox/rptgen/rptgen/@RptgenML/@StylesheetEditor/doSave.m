function fileName=doSave(this,isSaveAs)




    if nargin<2
        isSaveAs=false;
    end

    fileName=this.Registry;

    if rptgen.use_java
        ext=char(com.mathworks.toolbox.rptgencore.tools.StylesheetMaker.FILE_EXT_SS);
    else
        ext=mlreportgen.re.internal.db.StylesheetMaker.FILE_EXT_SS;
    end

    if isempty(fileName)||this.isBuiltin
        isSaveAs=true;

        startDir=fullfile(fileparts(fileName),['*',ext]);






    elseif isSaveAs
        startDir=fullfile(fileparts(fileName),['*',ext]);
        fileName='';
    end


    if isSaveAs

        [newFile,newPath]=uiputfile({
        ['*',ext],getString(message('rptgen:RptgenML_StylesheetEditor:ReportGeneratorStylesheetsLabel',ext))
        '*.*',getString(message('rptgen:RptgenML_StylesheetEditor:allFilesLabel'))
        },getString(message('rptgen:RptgenML_StylesheetEditor:saveAsLabel')),startDir);

        if isequal(newFile,0)

            fileName='';
            return;
        end

        if~isOnMatlabPath(newPath)
            optSave=getString(message('rptgen:RptgenML_StylesheetEditor:saveAnywayLabel'));
            optSaveAdd=getString(message('rptgen:RptgenML_StylesheetEditor:saveAndAddPathLabel'));
            optCancel=getString(message('rptgen:RptgenML_StylesheetEditor:cancelLabel'));
            resultStr=questdlg(...
            getString(message('rptgen:RptgenML_StylesheetEditor:fileNotOnPathMsg',newPath)),...
            getString(message('rptgen:RptgenML_StylesheetEditor:hiddenStylesheetLabel')),...
            optSave,optCancel,optCancel);
            switch resultStr
            case optCancel
                fileName='';
                return;
            case optSaveAdd
                addpath(newPath);
            case optSave

            otherwise
                error(message('rptgen:RptgenML_StylesheetEditor:unrecognizedOption'));
            end
        end

        fileName=fullfile(newPath,newFile);
        this.Registry=fileName;

    end

    [~,newID]=fileparts(fileName);


    ssRoot=RptgenML.StylesheetRoot;
    ssLib=ssRoot.getStylesheetLibrary;
    ssExist=find(ssLib,'ID',newID);

    thisLibSheet=[];
    if~isempty(ssExist)
        existFileNames='';
        for i=1:length(ssExist)
            if strcmpi(ssExist(i).Registry,fileName)
                thisLibSheet=ssExist(i);
                ssExist(i)=[];
            else
                existFileNames=sprintf('%s\n"%s"',existFileNames,ssExist(i).Registry);
            end
        end

        if~isempty(existFileNames)


            optSave=getString(message('rptgen:RptgenML_StylesheetEditor:saveAnywayLabel'));
            optSaveRemove=getString(message('rptgen:RptgenML_StylesheetEditor:saveAndMakeUniqueLabel'));
            optCancel=getString(message('rptgen:RptgenML_StylesheetEditor:cancelLabel'));
            resultStr=questdlg(...
            getString(message('rptgen:RptgenML_StylesheetEditor:duplicateIDMsg',newID,existFileNames)),...
            getString(message('rptgen:RptgenML_StylesheetEditor:duplicateIDLabel')),...
            optSaveRemove,optCancel,optCancel);
            switch resultStr
            case optCancel
                fileName='';
                return;
            case optSave

            case optSaveRemove

                for i=1:length(ssExist)
                    if isa(ssExist,'RptgenML.StylesheetEditor')
                        try
                            registryRemove(ssExist(i));
                        catch ME
                            warning(ME.message);
                        end
                    end
                end


            otherwise
                error(message('rptgen:RptgenML_StylesheetEditor:unrecognizedOption'));
            end
        end
    end




    try
        registrySave(this);
    catch ME %#ok


        warndlg(getString(message('rptgen:RptgenML_StylesheetEditor:couldNotWriteFileMsg',fileName)),...
        getString(message('rptgen:RptgenML_StylesheetEditor:saveErrorLabel')),getString(message('rptgen:RptgenML_StylesheetEditor:replaceLabel')));
        fileName='';
    end





    if~isempty(fileName)

        setDirty(this,false);


        try
            if rptgen.use_java
                com.mathworks.toolbox.rptgencore.output.StylesheetCache.clearCachedStylesheet();
            else
                rptgen.internal.output.StylesheetCache.clearCachedStylesheet();
            end
        catch ME
            warning(message('rptgen:RptgenML_StylesheetEditor:unableToRemoveStyleSheetCache',...
            ME.message));
        end


        if~isempty(thisLibSheet)



            set(thisLibSheet,...
            'DisplayName',this.DisplayName,...
            'Filename',this.Filename,...
            'Description',this.Description);
        elseif~isempty(ssLib)

            thisLibSheet=RptgenML.StylesheetEditor.createLibrary(this);
            ssRoot.addStylesheetToLibrary(thisLibSheet);
        end

        enableActions(RptgenML.Root);


        ed=DAStudio.EventDispatcher;ed.broadcastEvent('HierarchyChangedEvent',this);
    end



    function tf=isOnMatlabPath(dirName)



        mlPath=path;
        if ispc

            mlPath=lower(mlPath);
            dirName=lower(dirName);
        end

        if dirName(end)==filesep||dirName(end)=='/'

            dirName=dirName(1:end-1);
        end

        dirNameLength=length(dirName);
        tf=strcmp(mlPath(1:dirNameLength+1),[dirName,pathsep])||...
        strcmp(mlPath(end-dirNameLength:end),[pathsep,dirName])||...
        ~isempty(findstr(mlPath,[pathsep,dirName,pathsep]));

