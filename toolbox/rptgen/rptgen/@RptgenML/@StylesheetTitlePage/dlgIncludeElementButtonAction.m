function dlgIncludeElementButtonAction(this)






    e=RptgenML.enumTitlePageContents;

    inElement=this.ExcludedElementNames{this.CurrExcludeElementIdx+1};

    this.Format.includeElement(inElement);



    includedNames=[this.IncludedElementNames',{inElement}]';
    selector=ismember(e.Strings,includedNames);
    this.IncludedElementNames=e.Strings(selector);
    this.IncludedElementDisplayNames=e.DisplayNames(selector);
    this.IncludedElementIndices=0:length(this.IncludedElementNames)-1;



    excludedNames=...
    this.ExcludedElementNames(not(cellfun(@(a)strcmp(a,inElement),...
    this.ExcludedElementNames)));
    selector=ismember(e.Strings,excludedNames);
    this.ExcludedElementNames=e.Strings(selector);
    this.ExcludedElementDisplayNames=e.DisplayNames(selector);
    this.ExcludedElementIndices=0:length(this.ExcludedElementNames)-1;

    selector=ismember(this.IncludedElementNames,inElement);
    this.CurrIncludeElementIdx=this.IncludedElementIndices(selector);





