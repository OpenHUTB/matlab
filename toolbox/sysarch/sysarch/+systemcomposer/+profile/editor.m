function editor(varargin)


















    profileNameToSelect='';
    if nargin>0
        if isa(varargin{1},'systemcomposer.profile.Profile')
            profileNameToSelect=varargin{1}.Name;
        else
            profileNameToSelect=varargin{1};
        end
    end
    systemcomposer.internal.profile.Designer.launch(ProfileToSelect=profileNameToSelect);
