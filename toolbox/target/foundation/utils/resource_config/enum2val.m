function idx = enum2val(type,enum)
%ENUM2VAL  Converts an enumerated string to its numerical equivalent.
% 
% idx = enum2val(type, enum)
%
% -- Arguments ---
%
%   type    -   A string indicating the enumeration class to look up
%   enum    -   A string representing the enumeration value to lookup
%
% -- Returns   ---
%
%   An integer representing the numerical equivalent of the enumeration
%   string.
%
% -- Example ---
%
%   v = enum2val('color','red');
%
    
%   Copyright 2001-2011 The MathWorks, Inc.
    
    typeClass = findtype(type);
    if isempty(typeClass)
        TargetCommon.ProductInfo.error('resourceConfiguration', ...
                                       'InvalidUDDType', ...
                                       type);
    end

    idx = find(strcmp(enum, typeClass.Strings));

    if isempty(idx)
        TargetCommon.ProductInfo.error('resourceConfiguration', ...
                                       'InvalidEnumerationString',...
                                       enum, type);
    end
    
   idx = int32(typeClass.Values(idx)); 


