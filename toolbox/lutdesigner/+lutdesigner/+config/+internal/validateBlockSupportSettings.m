function validateBlockSupportSettings(bss)



    if isempty(bss)
        return;
    end
    validateattributes(bss,{'struct'},{});
    mustBeMember({'BlockType','MaskType','NumDims','Table','Axes'},fieldnames(bss));

    for i=1:numel(bss)
        validateattributes(bss(i).BlockType,{'char','string'},{'scalartext'});
        validateattributes(bss(i).MaskType,{'char','string'},{'scalartext'});
        mustBeVarName(bss(i).NumDims);
        mustBeVarName(bss(i).Table);
        validateattributes(bss(i).Axes,{'cell'},{});
        cellfun(@(axis)mustBeVarName(axis),bss(i).Axes);
    end
end

function mustBeVarName(val)
    validateattributes(val,{'char','string'},{'scalartext'});
    assert(strlength(val)==0||isvarname(val),...
    'lutdesigner:internal:invalidBlockSupportSetting',...
    'Value for NumDims, Table, or element of Axes, must be a valid variable name.');
end
