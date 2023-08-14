




function result=setGlobalExclusion(this,eventData)
    switch(eventData.GlobalExclusion)
    case 'ModelReference'
        this.GlobalExclusionsData.ExcludeModelReferences=eventData.IsChecked;
    case 'LibraryLinks'
        this.GlobalExclusionsData.ExcludeLibraryLinks=eventData.IsChecked;
    case 'InactiveRegions'
        this.GlobalExclusionsData.ExcludeInactiveRegions=eventData.IsChecked;
    end
    result=true;
end

