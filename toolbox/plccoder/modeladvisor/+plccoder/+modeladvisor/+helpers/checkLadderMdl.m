function ret = checkLadderMdl(modelH)
%

% This function was previously named as check_ladder_mdl and was part
% of private/plc_mdl_check_initial_property.m
ret = false;
if ~isempty(plc_find_system(modelH, 'PLCBlockType', 'AOIRunner')) || ~isempty(plc_find_system(modelH, 'PLCBlockType', 'Controller'))
    ret = true;
end
end