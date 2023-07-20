function objGetDropdown(obj,varargin)


    in=varargin{1};


    OldDropdownNames=fieldnames(obj.OldDropdown);
    nOldDropdown=numel(OldDropdownNames);
    for dropdownIdx=1:nOldDropdown
        thisDropdownName=OldDropdownNames{dropdownIdx};
        obj.OldDropdown.(thisDropdownName)=getValue(in,thisDropdownName);
    end
end
