function ssEdit=addStylesheetEditor(this,id,varargin)











    ssEdit=[];
    if nargin<2
        id='';
    elseif isa(id,'rptgen.coutline')
        id=id.Stylesheet;
    elseif isa(id,'rpt_xml.db_output')
        id=id.getStylesheetID;
    elseif ischar(id)&&strcmpi(id,'-BROWSE')
        ssLib=RptgenML.libdlg(this.getStylesheetLibrary);
        if isempty(ssLib)||isempty(ssLib.ID)
            return;
        else
            id=ssLib.ID;


        end
    elseif isa(id,'RptgenML.StylesheetEditor')
        if isempty(id.JavaHandle)

            regFile=id.Registry;
            if isempty(regFile)

                id=id.ID;
            elseif((length(regFile)>18&&strcmpi(regFile(end-17:end),'rptstylesheets.xml'))||strcmp(regFile(end-4:end),'.dotx'))

                id=id.ID;
                varargin{1}=regFile;
            else


                id=regFile;
            end
        else

            ssEdit=id;
        end
    end

    if~isempty(ssEdit)
        addStylesheet(this,ssEdit,true);
    elseif~isempty(id)
        if exist(id,'file')
            id=rptgen.findFile(id);

            addToLibrary=true;
            if ispc

                isFileMatch=@(regFile)(strcmpi(regFile,id));
                ssEdit=find(this,...
                '-depth',1,'-isa','RptgenML.StylesheetEditor',...
                '-function','Registry',isFileMatch);
            else
                ssEdit=find(this,...
                '-depth',1,'-isa','RptgenML.StylesheetEditor',...
                'Registry',id);
            end
        else
            addToLibrary=false;
            ssEdit=find(this,...
            '-depth',1,'-isa','RptgenML.StylesheetEditor',...
            'ID',id);
        end


        if isempty(ssEdit)
            ssEdit=RptgenML.StylesheetEditor(id,varargin{:});
            addStylesheet(this,ssEdit,addToLibrary);
        end
    else
        ssEdit=this;
    end

    r=RptgenML.Root;
    refreshAction=r.refreshReportList('-deferred');
    connect(this,r,'up');
    e=r.getEditor;




    ime=DAStudio.imExplorer(e);
    ime.expandTreeNode(ssEdit);

    r.viewChild(ssEdit);
    r.refreshReportList(refreshAction);

    if(ssEdit==this)

        ssEdit=[];
    end


    function addStylesheet(this,ssEdit,addToLibrary)

        if isempty(down(this))
            connect(ssEdit,this,'up');
        else
            connect(ssEdit,down(this),'right');
        end

        if addToLibrary&&~isempty(this.StylesheetLibrary)

            libSheet=find(this.StylesheetLibrary,'ID',ssEdit.ID);
            if isempty(libSheet)
                libSheet=RptgenML.StylesheetEditor.createLibrary(ssEdit);
                this.addStylesheetToLibrary(libSheet);
            end
        end

