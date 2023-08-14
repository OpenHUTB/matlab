function fetchDataFromBackend(this)





    this.isSaveToSlx=isempty(this.getExternalFilePath());

    exclusionsObj=CloneDetector.Exclusions(this.model,this.getExternalFilePath());
    this.TableData=exclusionsObj.getExclusionsTableData();
    this.GlobalExclusionsData.ExcludeModelReferences=exclusionsObj.getExcludeModelReferences();
    this.GlobalExclusionsData.ExcludeLibraryLinks=exclusionsObj.getExcludeLibraryLinks();
    this.GlobalExclusionsData.ExcludeInactiveRegions=exclusionsObj.getExcludeInactiveRegions();

    this.isTableDataValid=true;
end


