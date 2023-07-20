function initFormat(this,side)






    jComment=this.JavaHandle.getFirstChild();
    while~isempty(jComment)&&~strcmp(jComment.getNodeName(),'#comment')
        jComment=jComment.getNextSibling;
    end


    if strcmp(jComment.getData(),'new PDF template')
        if strcmp(side,'recto')
            this.Format=Rptgen.TitlePage.PDF.Recto.Format;
        else
            this.Format=Rptgen.TitlePage.PDF.Verso.Format;
        end
        this.Format.generateTemplateContent(this.JavaHandle);
    else
        if strcmp(jComment.getData(),'new HTML template')
            if strcmp(side,'recto')
                this.Format=Rptgen.TitlePage.HTML.Recto.Format();
            else
                this.Format=Rptgen.TitlePage.HTML.Verso.Format();
            end
            this.Format.generateTemplateContent(this.JavaHandle);
        else
            this.Format=Rptgen.TitlePage.loadFormat(jComment.getData());
        end
    end

    this.LOGridCols=this.Format.LayoutGrid.NumberOfColumns;
    this.LOGridRows=this.Format.LayoutGrid.NumberOfRows;
    this.LOGridWidth=this.Format.LayoutGrid.Width;
    this.LOGridHeight=this.Format.LayoutGrid.Height;
    this.ShowGrid=this.Format.LayoutGrid.Show;

    e=RptgenML.enumTitlePageContents;
    this.IncludedElementIndices=[];
    this.IncludedElementNames={};
    this.IncludedElementDisplayNames={};
    this.ExcludedElementIndices=[];
    this.ExcludedElementNames={};
    this.ExcludedElementDisplayNames={};

    for i=1:length(this.Format.IncludeElements)
        name=this.Format.IncludeElements{i}.Name;
        this.IncludedElementIndices=[this.IncludedElementIndices,i];
        this.IncludedElementNames=[this.IncludedElementNames;name];
        this.IncludedElementDisplayNames=[this.IncludedElementDisplayNames;e.findDisplayName(name)];
    end

    for i=1:length(this.Format.ExcludeElements)
        name=this.Format.ExcludeElements{i}.Name;
        this.ExcludedElementIndices=[this.ExcludedElementIndices,i];
        this.ExcludedElementNames=[this.ExcludedElementNames;name];
        this.ExcludedElementDisplayNames=[this.ExcludedElementDisplayNames;e.findDisplayName(name)];
    end

    ce=this.Format.getIncludeElement(this.IncludedElementNames{1});
    this.CurrElemRow=ce.RowNum-1;
    this.CurrElemRowSpan=ce.RowSpan;
    this.CurrElemCol=ce.ColNum-1;
    this.CurrElemColSpan=ce.RowSpan;
    this.CurrElemXForm=ce.XForm;

    if isa(ce,'Rptgen.TitlePage.TextElement')
        this.CurrElemFontSize=ce.FontSize;
        this.CurrElemIsBold=ce.IsBold;
        this.CurrElemIsItalic=ce.IsItalic;
        this.CurrElemColor=ce.Color;
        this.CurrElemHAlign=ce.HAlign;
    end

end




