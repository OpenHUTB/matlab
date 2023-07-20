function inputResults=parseExportOptions(varargin)
    exportOptionsInput=inputParser;
    defaultExportTo='variable';
    defaultFileName='New_Export';
    defaultMetaData="";
    defaultShareTimeCol='on';
    defaultOverwrite='file';

    addParameter(exportOptionsInput,'to',defaultExportTo,...
    @exportToValidationFcn);
    addParameter(exportOptionsInput,'filename',defaultFileName,@filenameValidatationFcn);
    addParameter(exportOptionsInput,'metadata',defaultMetaData,...
    @metadataValidationFcn);
    addParameter(exportOptionsInput,'sharetimecolumn',...
    defaultShareTimeCol,@shareTimeColValidationFcn);
    addParameter(exportOptionsInput,'overwrite',defaultOverwrite,...
    @overwriteValidationFcn);
    parse(exportOptionsInput,varargin{:});
    inputResults=exportOptionsInput.Results;


    inputResults.filename=char(inputResults.filename);
end


function ret=filenameValidatationFcn(x)
    ret=ischar(x)||(isscalar(x)&&isstring(x));
end


function exportToValidationFcn(x)
    expectedExportTo={'variable','file'};
    validatestring(x,expectedExportTo);
end


function metadataValidationFcn(x)
    expectedMetadata=["datatype","units","blockpath","interp",...
    "portindex"];
    if isstring(x)
        for idx=1:length(x)
            validatestring(x(idx),expectedMetadata);
        end
    else
        validatestring(x,expectedMetadata);
    end
end


function shareTimeColValidationFcn(x)
    expectedShareTimeColumn={'on','off'};
    validatestring(x,expectedShareTimeColumn);
end


function overwriteValidationFcn(x)
    expectedOverwrite={'file','sheetsonly'};
    validatestring(x,expectedOverwrite);
end