function out=wordApp(method,varargin)




    persistent hWord;
    mlock;


    if reqmgt('rmiFeature','UseDotNet')
        useDotNet=true;
    else
        useDotNet=false;
    end

    if nargin==0
        if isempty(hWord)||~isValid()
            hWord=get_app();
        end
        out=hWord;
        return;
    end

    switch method
    case 'kill'
        if isempty(hWord)||~isValid()
            hWord=get_running();
        end
        if~isempty(hWord)
            hWord.Quit(0);
            hWord=[];
        end
    case 'closedoc'
        if isempty(hWord)||~isValid()
            hWord=get_running();
        end

        if~isempty(hWord)
            closedoc(varargin{1});
        end
    case 'exists'
        if isempty(hWord)||~isValid()
            hWord=get_running();
        end
        out=~isempty(hWord);

    case 'finddoc'
        if isempty(hWord)||~isValid()
            hWord=get_running();
            if isempty(hWord)||~isValid()

                out=[];
                return;
            end
        end
        out=finddoc(varargin{1});

    case 'dispdoc'
        if isempty(hWord)||~isValid()
            hWord=get_app();
        end
        out=dispdoc(varargin{1});
    case 'saveasdoc'
        if isempty(hWord)||~isValid()
            hWord=get_app();
        end
        out=dispdoc(varargin{1});
        invoke(out,'saveas',varargin{2},11);
    case 'dispapp'
        if isempty(hWord)||~isValid()
            hWord=get_running();
        end
        hWord.Visible=varargin{1};
        out=hWord;

    case 'updatedoc'
        if isempty(hWord)||~isValid()
            hWord=get_app();
        end

        out=dispdoc(varargin{1});
        if~isempty(out)

            out.Fields.Update;

            tocNum=out.TablesOfContents.Count;
            for index=1:tocNum
                cTOC=out.TablesOfContents.Item(index);
                cTOC.Update;
            end

            tofNum=out.TablesOfFigures.Count;
            for index=1:tofNum
                cTOF=out.TablesOfFigures.Item(index);
                cTOF.Update;
            end

            out.Save;
        end

    case 'clearselection'
        if isempty(hWord)||~isValid()
            hWord=get_running();
        end
        clearSelection();
        out=hWord;

    otherwise
        error(message('Slvnv:reqmgt:com_word_app:UnknownMethod'));
    end



    function result=get_new()
        if useDotNet
            NET.addAssembly('microsoft.office.interop.word');
            result=Microsoft.Office.Interop.Word.ApplicationClass;
        else
            result=actxserver('word.application');
        end
    end

    function result=get_running()
        try
            if useDotNet
                NET.addAssembly('microsoft.office.interop.word');
                result=System.Runtime.InteropServices.Marshal.GetActiveObject('Word.Application');
            else
                result=actxGetRunningServer('word.application');
            end
        catch ex %#ok<NASGU>
            result=[];
        end
    end

    function result=get_app()
        result=get_running();
        if isempty(result)
            result=get_new();
        end
    end

    function clearSelection()

        if~isempty(hWord)&&~isempty(hWord.Selection)&&hWord.Selection.Start<hWord.Selection.End
            hWord.Selection.Collapse(0);
        end
    end

    function hDoc=finddoc(filename)
        hDoc=[];
        hDocs=hWord.Documents;
        openCount=hDocs.Count;
        match=[];
        for i=1:openCount
            thisDoc=hDocs.Item(i);
            if useDotNet
                docFullName=thisDoc.FullName.char;
                docName=thisDoc.Name.char;
            else
                docFullName=thisDoc.FullName;
                docName=thisDoc.Name;
            end
            if rmiut.cmp_paths(docFullName,filename)
                hDoc=thisDoc;
                return;
            elseif strcmp(docName,filename)
                match(end+1)=i;%#ok<AGROW>
            end
        end


        if length(match)==1
            hDoc=hWord.Documents.Item(match);
        end
    end

    function closedoc(filename)
        hWord.Visible=1;

        hDoc=finddoc(filename);
        if~isempty(hDoc)
            try
                invoke(hDoc,'Close',false);
            catch ME
                warning(message('SimulinkBlocks:docblock:CloseFile',ME.message));
            end
        end

        allDocs=hWord.documents;
        if(allDocs.count==0)


            while get(hWord,'BackgroundPrintingStatus')||...
                get(hWord,'BackgroundSavingStatus')
                pause(.25);
            end

            try
                invoke(hWord,'Quit',false);
                hWord.Quit(0);
            catch ME %#ok

            end
            delete(hWord);
            hWord=[];
        end


    end
    function hDoc=dispdoc(filename)


        if~hWord.Visible
            hWord.Visible=1;
        end

        if(strcmpi(hWord.WindowState,'wdWindowStateMinimize'))
            hWord.WindowState='wdWindowStateNormal';
        end


        hDoc=finddoc(filename);


        if isempty(hDoc)
            hDocs=hWord.Documents;
            try
                if useDotNet
                    hDocs.Open(filename,0,0);
                else
                    hDocs.Open(filename,[],0);
                end
                hDoc=hWord.ActiveDocument;


                hWord.Activate;

            catch Mex
                error(message('Slvnv:reqmgt:linktype_rmi_word:DocumentNotFound',filename,Mex.message));
            end
        else
            hDoc.Activate;

            if~hWord.Visible
                hWord.Visible=true;
            end
            hWord.Activate;








        end
    end

    function result=isValid()
        result=1;
        try
            hWord.Version;
        catch Mex2 %#ok<NASGU>
            result=0;
        end
    end

end
