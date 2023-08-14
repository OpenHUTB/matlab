function excludeElement(this,exElement)






    e=RptgenML.enumTitlePageContents;



    excludedNames=[this.ExcludedElementNames',{exElement}]';
    selector=ismember(e.Strings,excludedNames);
    this.ExcludedElementDisplayNames=e.DisplayNames(selector);
    this.ExcludedElementNames=e.Strings(selector);
    this.ExcludedElementIndices=0:length(this.ExcludedElementNames)-1;



    includedNames=...
    this.IncludedElementNames(not(cellfun(@(a)strcmp(a,exElement),...
    this.IncludedElementNames)));

    if this.CurrIncludeElementIdx>=(length(this.IncludedElementNames)-1)
        this.CurrIncludeElementIdx=0;
    end

    if~isempty(includedNames)
        selector=ismember(e.Strings,includedNames);
        this.IncludedElementDisplayNames=e.DisplayNames(selector);
        this.IncludedElementNames=e.Strings(selector);
        this.IncludedElementIndices=0:length(this.IncludedElementNames)-1;
    else
        this.IncludedElementDisplayNames={};
        this.IncludedElementNames={};
        this.IncludedElementIndices=0;
        dlg.setEnabled('TitlePageRecto_FormatGroup',false);
    end

    this.Format.excludeElement(exElement);








