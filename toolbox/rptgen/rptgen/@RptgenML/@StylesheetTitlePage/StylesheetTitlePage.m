function this=StylesheetTitlePage(parentObj,varargin)






    this=feval(mfilename('class'));
    this.init(parentObj,varargin{:});

    jComment=this.JavaHandle.getFirstChild();
    while~isempty(jComment)&&~strcmp(jComment.getNodeName(),'#comment')
        jComment=jComment.getNextSibling;
    end


    if strcmp(jComment.getData(),'new template')
        this.Format=Rptgen.TitlePage.Format;
        this.Format.generateTemplateContent(this.JavaHandle);
    else
        this.Format=Rptgen.TitlePage.loadFormat(jComment.getData());
        e=RptgenML.enumTitlePageContents;
        this.IncludedElementIndices=[];
        this.IncludedElementNames={};
        this.IncludedElementDisplayNames={};
        this.ExcludedElementIndices=[];
        this.ExcludedElementNames={};
        this.ExcludedElementDisplayNames={};
        for i=1:length(e.strings)
            if isempty(this.Format.getContentElement(e.strings{i}))
                this.ExcludedElementIndices=[this.ExcludedElementIndices,i];
                this.ExcludedElementNames=[this.ExcludedElementNames;e.strings(i)];
                this.ExcludedElementDisplayNames=[this.ExcludedElementDisplayNames;e.DisplayNames(i)];
            else
                this.IncludedElementIndices=[this.IncludedElementIndices,i];
                this.IncludedElementNames=[this.IncludedElementNames;e.strings(i)];
                this.IncludedElementDisplayNames=[this.IncludedElementDisplayNames;e.DisplayNames(i)];

            end
        end
        ce=this.Format.getContentElement(this.IncludedElementNames{1});
        this.CurrElemRow=ce.RowNum-1;
        this.CurrElemRowSpan=ce.RowSpan;
        this.CurrElemCol=ce.ColNum-1;
        this.CurrElemColSpan=ce.RowSpan;
        this.CurrElemHAlign=ce.HAlign;
    end

end




