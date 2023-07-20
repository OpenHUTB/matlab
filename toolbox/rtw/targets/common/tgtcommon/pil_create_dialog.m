function obj = pil_create_dialog(h,className)
% PIL_CREATE_DIALOG Instantiates a dynamic dialog object.
%
%    OBJ = PIL_CREATE_DIALOG returns OBJ, a dynamic 
%    dialog object.

%    Copyright 2005-2021 The MathWorks, Inc.

% h is either the library block, an instance of the library block or a
% subsystem containing the library block
if strcmp(get_param(h, 'ReferenceBlock'), 'pil_lib/PIL Block') || ...
        strcmp(get_param(h, 'Parent'), 'pil_lib')
    xilBlock = h;
else
    assert(strcmp(get_param(h, 'BlockType'), 'SubSystem'), ...
        'h must be a SubSystem');
    % look under SubSystem
    % @todo update the usage of edit-time filter filterOutInactiveVariantSubsystemChoices()
    % instead use the post-compile filter activeVariants() - g2597518
    xilBlock = find_system(h,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'LookUnderMasks', 'on', 'ReferenceBlock', 'pil_lib/PIL Block' ); % look only inside active choice of VSS
    assert(~isempty(xilBlock), 'XIL library block not found.');
end
obj = pilverification.(className{1})(h, xilBlock);
