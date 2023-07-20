function dtaItems=getConceptualDatatype(h)%#ok








    persistent builtins;
    if isempty(builtins)
        builtins={
'double'
'single'
'int8'
'uint8'
'int16'
'uint16'
'int32'
'uint32'
'int64'
'uint64'
'boolean'
'void'
        };
    end
    dtaItems.inheritRules={};
    dtaItems.builtinTypes={};
    dtaItems.scalingModes={};
    dtaItems.signModes={};
    dtaItems.extras=[];
    dtaItems.validValues={};

    dtaItems.builtinTypes=builtins;

    dtaItems.validValues=[dtaItems.builtinTypes{:},...
    'Unspecified',...
    'fixdt(1,16,0)',...
    'fixdt(1,16,2^0,0)'];

    dtaItems.scalingModes={'UDTBinaryPointMode','UDTSlopeBiasMode','UDTBestPrecisionMode'};
    dtaItems.signModes={'UDTSignedSign','UDTUnsignedSign'};


    dtaItems.allowsExpression=true;

