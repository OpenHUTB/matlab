function propgrp = getPropertyGroups(this)
% GETPROPERTYLISTTODISP creates the property list for
% Simulink.data.dictionary.Entry. It is used by matlab.mixin.CustomDisplay method
% getPropertyGroups to generate property group. The purpose of
% using custom display here is to disp the Value that an entry holds

%   Copyright 2015 The MathWorks, Inc.

% First, get the set of all properties defined for the object
propgrp = getPropertyGroups@matlab.mixin.CustomDisplay(this);

% ONLY scalar and non-deleted case should get here.
% Default disp will be invoked (through default getPropertyGroups
% implementation of matlab.mixin.CustomDisplay) for other cases.
if isscalar(this) && ~strcmp(this.Status, 'Deleted')
    propList = propgrp.PropertyList;
    propNames = fieldnames(propList);
    assert(~isempty(this));
    propList.Value = this.getValue;
    perm = {propNames{1}, 'Value', propNames{2:end}};
    propgrp.PropertyList = orderfields(propList, perm);
end

end

% EOF
