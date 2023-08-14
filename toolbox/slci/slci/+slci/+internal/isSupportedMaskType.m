


function out=isSupportedMaskType(maskType)
    unsupportedMaskTypes={...
    'Environment Controller',...
    'LTI Block'};
    out=~any(strcmpi(maskType,unsupportedMaskTypes));
end