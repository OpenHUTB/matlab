function setCursorOptions(varargin)


























    try
        inputResults=locParseInput(varargin{:});
    catch ex
        throwAsCaller(MException(ex.identifier,ex.message));
    end









    appType='sdi';
    if strcmpi(inputResults.type,'compare')
        appType='SDIComparison';
    end

    Simulink.sdi.setCursorPreferences(...
    appType,...
    inputResults.emphasize,...
    lower(inputResults.shadearea),...
    locrgb2hex(inputResults.shadecolor),...
    inputResults.shadeopacity);
end


function inputResults=locParseInput(varargin)
    cursorOptionsInput=inputParser;
    currViewPrefs=Simulink.sdi.getViewPreferences;
    cursorOptions=currViewPrefs.cursorOptionsPref;
    cursorOptionsInspect=cursorOptions.cursorOptionsInspectView;
    cursorOptionsComparison=cursorOptions.cursorOptionsComparisonView;
    defaultType='inspect';

    defaultEmphasize=strcmpi(cursorOptionsInspect.shadeType,'emphasize');
    defaultShadeArea=cursorOptionsInspect.shadeArea;
    defaultShadeColorRGB=lochex2rgb(cursorOptionsInspect.shadeColor);
    defaultShadeOpacity=cursorOptionsInspect.shadeOpacity;

    if~isempty(find(cellfun(@(x)strcmpi(x,'compare'),varargin)==1))%#ok
        defaultEmphasize=cursorOptionsComparison.shadeType;
        defaultShadeArea=cursorOptionsComparison.shadeArea;
        defaultShadeColorRGB=lochex2rgb(cursorOptionsComparison.shadeColor);
        defaultShadeOpacity=cursorOptionsComparison.shadeOpacity;
    end

    addParameter(cursorOptionsInput,'type',defaultType,@typeValidationFcn);
    addParameter(cursorOptionsInput,'emphasize',defaultEmphasize,...
    @emphasizeValidationFcn);
    addParameter(cursorOptionsInput,'shadearea',defaultShadeArea,...
    @shadeAreaValidationFcn);
    addParameter(cursorOptionsInput,'shadecolor',defaultShadeColorRGB,...
    @shadeColorValidationFcn);
    addParameter(cursorOptionsInput,'shadeopacity',defaultShadeOpacity,...
    @shadeOpacityValidationFcn);
    parse(cursorOptionsInput,varargin{:});
    inputResults=cursorOptionsInput.Results;
end


function typeValidationFcn(typeVal)
    expectedTypeVals={'inspect','compare'};
    validatestring(typeVal,expectedTypeVals);
end


function emphasizeValidationFcn(emphasizeVal)
    validateattributes(emphasizeVal,{'logical','numeric'},{'nonempty'});
end


function shadeAreaValidationFcn(shadeAreaVal)
    expectedShadeAreaVals={'lead','lag','leadandlag','inbetween',...
    'none'};
    validatestring(shadeAreaVal,expectedShadeAreaVals);
end


function shadeColorValidationFcn(shadeColorVal)
    validateattributes(shadeColorVal,{'numeric'},{'size',[1,3]});
end


function shadeOpacityValidationFcn(shadeOpacityVal)
    validateattributes(shadeOpacityVal,{'numeric'},{'>=',0,'<=',1});
end


function hexStr=locrgb2hex(rgb)
    rgb=round(rgb*255);
    hexStr(:,2:7)=reshape(sprintf('%02X',rgb.'),6,[]).';
    hexStr(:,1)='#';
    hexStr=lower(hexStr);
end


function rgbVec=lochex2rgb(hexStr)

    hexStr(:,1)=[];
    rgbVec=reshape(sscanf(hexStr.','%2x'),3,[]).'/255;
end