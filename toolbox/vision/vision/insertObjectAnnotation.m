function RGB = insertObjectAnnotation(I, shape, position, labelTemp, varargin)
%insertObjectAnnotation Insert annotation in image or video stream.
%  This function inserts labels and corresponding circles or rectangles
%  into an image or video. You can use it with either a grayscale or
%  truecolor image input.
%
%
% RGB = insertObjectAnnotation(I, shape, position, label) returns a
%    truecolor image annotated with shape and label. The input image, I, can
%    be either a truecolor or grayscale image. The supported values for shape
%    and position are described below. The input label can be an M-element
%    vector of numeric, string, or categorical labels, or an M-element cell
%    array of character vectors, where M is the number of shape positions.
%    Character, string, or categorical labels must encoded as ASCII characters.
%    A scalar label can also be specified for all shapes as a numeric scalar,
%    string, or categorical.
%   
%    ------------------------------------------------------------------------
%    SHAPE             | POSITION
%    ------------------|-----------------------------------------------------
%    'rectangle'       | An M-by-4 matrix where each row specifies an
%                      | axis-aligned rectangle as [x y width height] in
%                      | pixel coordinates, where [x y] defines the
%                      | upper-left corner of the rectangle.
%    ------------------|-----------------------------------------------------
%    'circle'          | M-by-3 matrix where each row specifies a circle as
%                      | [x y radius], where [x y] is the center of the
%                      | circle in spatial coordinates.         
%    ------------------|-----------------------------------------------------
%    'projected-cuboid'| For M projected cuboids, specify either an 8-by-2-by-M
%                      | array or an M-by-8 matrix.
%                      |
%                      | When specified as an 8-by-2-by-M array, each row must
%                      | contain the x and y location of a projected cuboid vertex.
%                      | The vertices are connected to form the 6 faces of the 
%                      | cuboid. See projected cuboid <a href="matlab:helpview(fullfile(docroot,'toolbox','vision','vision.map'),'insertObjectAnnotation')">vertex order</a> for more information.  
%                      |
%                      | When specified as an M-by-8 matrix, each row 
%                      | specifies the front and back face of a projected 
%                      | cuboid as a [x1 y1 w1 h1 x2 y2 w2 h2] vector, where 
%                      | [x1 y1] and [x2 y2] are the upper left coordinates of 
%                      | front and back face respectively and [w1 h1] and 
%                      | [w2 h2] are their respective widths and heights.
%  
%
%  RGB = insertObjectAnnotation(I, shape, position, label, Name, Value)
%  specifies additional name-value pair arguments described below:
%
%  'LineWidth'       Line width for the border of a shape, specified as a
%                    positive scalar integer, in pixels.
%
%                    Default: 1
%
%  'Color'           Color for the shape and label text box. You can
%                    specify a different color for each shape, or one color
%                    for all the shapes.
%                    - To specify a color for each shape, set 'Color' to a
%                      cell array of M strings or an M-by-3 matrix of RGB
%                      values.
%                    - To specify one color for all shapes, set 'Color' to
%                      either a string or an [R G B] vector.
%                    RGB values must be in the range of the image data
%                    type. Supported color strings are, 'blue', 'green',
%                    'red', 'cyan', 'magenta', 'yellow', 'black', 'white'
%
%                    Default: 'yellow'
%
%  'TextColor'       Color of text labels. Specify the color of text labels
%                    in the same way as the 'Color' input.
%
%                    Default: 'black'
%
%  'TextBoxOpacity'  A scalar defining the opacity of the background of the
%                    label text box. Specify this value in the range of 0
%                    to 1.
%
%                    Default: 0.6
%
%  'Font'            Font face of text. Specify the font of the text as one
%                    of the available truetype fonts installed on your
%                    system. To get a list of available fonts, type
%                    'listTrueTypeFonts' in the command prompt.
%
%                    Default: 'LucidaSansRegular'
%
%  'FontSize'        Font size, specified in points, as an integer in the
%                    range of 8 to 72.
%
%                    Default: 12
%
%  Class Support
%  -------------
%  The class of input I can be uint8, uint16, int16, double, single. Output
%  RGB matches the class of I.
%
%  Example 1: Object annotation with integer numbers
%  -------------------------------------------------
%  I = imread('coins.png');
%  position = [96 146 31;236 173 26];% center (x,y) and radius of the circle
%  label = [5 10]; % U.S. 5-cent and 10-cent coins
%
%  RGB = insertObjectAnnotation(I, 'circle', position, label, ...
%     'LineWidth', 3, 'Color', {'cyan', 'yellow'}, 'TextColor', 'black');
%  figure, imshow(RGB), title('Annotated coins');
%
%  Example 2: Object annotation with numbers and strings
%  -----------------------------------------------------
%  I = imread('board.tif');
%  % Create labels with floating point numbers
%  label_str = cell(3,1);
%  conf_val = [85.212 98.76 78.342];% Detection confidence
%  for ii=1:3
%     label_str{ii} = ['Confidence: ' num2str(conf_val(ii),'%0.2f') '%'];
%  end
%  position = [23 373 60 66;35 185 77 81;77 107 59 26];%[x y width height]
%
%  RGB = insertObjectAnnotation(I, 'rectangle', position, label_str, ...
%        'TextBoxOpacity', 0.9, 'FontSize', 18);
%  figure, imshow(RGB), title('Annotated chips');
%
%  See also insertText, insertShape, insertMarker, showShape.

% Copyright 2018-2022 The MathWorks, Inc.

%#codegen
%#ok<*EMCA>

coder.allowpcode('plain');
if isSimMode()
    label = labelTemp;
    if isstring(label) || iscategorical(label)
        label = manageMissingLabels(label);
        label = convertStringsToChars(string(label));
    end
else
    % Convert string and categorical types to cell array type
    % for code generation.
    if isstring(labelTemp) || iscategorical(labelTemp)
        label = cellstr(labelTemp);
    else
        label = labelTemp;
    end
end
%% == Parse inputs and validate ==
[RGB, shape, position, label, lineWidth, color, textColor, ...
    textBoxOpacity, fontSize, font, isEmpty] = ...
    validateAndParseInputs(I, shape, position, label, varargin{:});

% handle empty I or empty position
if isEmpty
    return;
end


if isSimMode()
    RGB = insertShape(RGB, shape, position, ...
        'LineWidth', lineWidth, ...
        'Color',     color);
else
    RGB(:) = insertShape(RGB, shape, position, ...
        'LineWidth', lineWidth, ...
        'Color',     color);
end


textLocAndWidth = getTextLocAndWidth(shape, position, lineWidth);
textPosition    = textLocAndWidth(:,1:2);
shapeWidth  = textLocAndWidth(:,3);
shapeHeight = textLocAndWidth(:,4);
RGB = insertText(RGB, textPosition, label, ...
    'FontSize',    fontSize, ...
    'Font',        font, ...
    'TextColor',   textColor, ...
    'BoxColor',    color, ...
    'BoxOpacity',  textBoxOpacity, ...
    'AnchorPoint', 'LeftBottom', ...
    'ShapeWidth',  shapeWidth, ...
    'ShapeHeight', shapeHeight);

%==========================================================================
% Parse inputs and validate
%==========================================================================
function [RGB, shape,position,outLabel,lineWidth, color,textColor,...
    textBoxOpacity,fontSize,font,isEmpty] = ...
    validateAndParseInputs(I, shape, position, label, varargin)

%--input image--
checkImage(I);
RGB = convert2RGB(I);
inpClass = class(I);

%--shape--
shape = validatestring(shape,{'rectangle','circle','projected-cuboid'}, mfilename,'SHAPE', 3);

%--position--
% position data type does not depend on input data type
vision.internal.inputValidation.validateNotObject(position, 'vision', 'position');
validateattributes(position, {'numeric'}, ...
    {'real','nonsparse',  'finite'}, mfilename,'POSITION', 3);
position = int32(position);

% Compute number of shapes.
numShapes = numberOfShapes(position);

%--isEmpty--
isEmpty = isempty(I) || isempty(position);

%--label--
checkLabel(label);

if ischar(label)
    numLabels = 1;
else
    numLabels = length(label);
end
outLabel  = label;

%--other optional parameters--
if isSimMode()
    [lineWidth, color, textColor, textBoxOpacity, fontSize, font] = ...
        validateAndParseOptInputs_sim(inpClass,varargin{:});
else
    [lineWidth, color, textColor, textBoxOpacity, fontSize, font] = ...
        validateAndParseOptInputs_cg(inpClass,varargin{:});
end
crossCheckInputs(shape, position, numLabels, color, textColor);
color = getColorMatrix(inpClass, numShapes, color);
textColor = getColorMatrix(inpClass, numShapes, textColor);

%==========================================================================
function flag = isSimMode()

flag = isempty(coder.target);

%==========================================================================
function [lineWidth, color, textColor, textBoxOpacity, fontSize, font] = ...
    validateAndParseOptInputs_sim(inpClass,varargin)
% Validate and parse optional inputs

defaults = getDefaultParameters(inpClass);
% Setup parser
parser = inputParser;
parser.CaseSensitive = false;
parser.FunctionName  = mfilename;

parser.addParameter('LineWidth', defaults.LineWidth);
parser.addParameter('Color', defaults.Color);
parser.addParameter('TextColor', defaults.TextColor);
parser.addParameter('TextBoxOpacity', defaults.TextBoxOpacity, ...
    @checkTextBoxOpacity);
parser.addParameter('FontSize', defaults.FontSize, @checkFontSize);
parser.addParameter('Font', defaults.Font);

%Parse input
parser.parse(varargin{:});

lineWidth      = checkLineWidth(parser.Results.LineWidth);
color          = checkColor(parser.Results.Color, 'Color');
textColor      = checkColor(parser.Results.TextColor, 'TextColor');
textBoxOpacity = double(parser.Results.TextBoxOpacity);
fontSize       = double(parser.Results.FontSize);
font           = vision.internal.checkFont(parser.Results.Font, mfilename);
%==========================================================================
function [lineWidth, color, textColor, textBoxOpacity, fontSize, font] = ...
    validateAndParseOptInputs_cg(inpClass,varargin)
% Validate and parse optional inputs

defaultsNoVal = getDefaultParametersNoVal();
defaults      = getDefaultParameters(inpClass);
properties    = getEmlParserProperties();

optarg = eml_parse_parameter_inputs(defaultsNoVal,properties,varargin{:});

lineWidth1 = (eml_get_parameter_value(optarg.LineWidth, ...
    defaults.LineWidth, varargin{:}));
color = (eml_get_parameter_value(optarg.Color, ...
    defaults.Color, varargin{:}));
textColor = (eml_get_parameter_value(optarg.TextColor, ...
    defaults.TextColor, varargin{:}));
textBoxOpacity = (eml_get_parameter_value(optarg.TextBoxOpacity, ...
    defaults.TextBoxOpacity, varargin{:}));
fontSize = (eml_get_parameter_value(optarg.FontSize, ...
    defaults.FontSize, varargin{:}));
font = (eml_get_parameter_value(optarg.Font, ...
    defaults.Font, varargin{:}));

lineWidth1     = checkLineWidth(lineWidth1);
lineWidth      = double(lineWidth1);

color          = checkColor(color, 'Color');
textColor      = checkColor(textColor, 'TextColor');

checkTextBoxOpacity(textBoxOpacity);
textBoxOpacity = double(textBoxOpacity);

checkFontSize(fontSize);
fontSize    = int32(fontSize);% const cast is done in insertText

coder.extrinsic('vision.internal.checkFont');
font        = coder.const(vision.internal.checkFont(font, mfilename)); % readjusted case

%==========================================================================
function checkImage(I)
% Validate input image

% No objects allowed.
vision.internal.inputValidation.validateNotObject(I, 'vision', 'I');

validateattributes(I,{'uint8', 'uint16', 'int16', 'double', 'single'}, ...
    {'real','nonsparse'}, mfilename, 'I', 1)
% input image must be 2d or 3d (with 3 planes)
errIf0((ndims(I) > 3) || ((size(I,3) ~= 1) && (size(I,3) ~= 3)), ...
    'vision:dims:imageNot2DorRGB');

coder.internal.assert(coder.internal.isConst(size(I,3)), ...
    'vision:insertObjectAnnotation:image3rdDimFixed');
%==========================================================================
function checkLabel(label)
% Validate label

if isnumeric(label)
    vision.internal.inputValidation.validateNotObject(label, 'vision', 'label');
    validateattributes(label, {'numeric'}, ...
        {'real', 'nonsparse', 'nonnan', 'finite', 'nonempty', 'vector'}, ...
        mfilename, 'LABEL');
else
    if ischar(label)
        % allow empty string ('')
        validateattributes(label,{'char'}, {}, ...
            mfilename, 'LABEL');
        labelCell = {label};
    else
        % allow empty cell {} or 0x1 cell to enable workflows where
        % position is empty. The crossCheckInputs function validates
        % whether the number of labels matches the number of
        % positions/objects.
        if isempty(label)
            validateattributes(label,{'cell'}, {},...
                mfilename, 'LABEL');
        else
            validateattributes(label,{'cell'}, {'vector'}, ...
                mfilename, 'LABEL');
        end
        allLabelCellsChar = true;
        for i=1:length(label)
            vision.internal.inputValidation.validateNotObject(label{i}, 'vision', 'label');
            allLabelCellsChar = allLabelCellsChar && ischar(label{i});
        end
        errIf0(~allLabelCellsChar, ...
            'vision:insertObjectAnnotation:labelCellNonChar');
        labelCell = label;
    end
    
    % manually generate hasNewLine and hasCarriageReturn.
    % sprintf('\n')==10; sprintf('\r')==13
    % 'my\nname' is fine; sprintf('my\nname') is not accepted
    hasNewLine     = false;
    hasCarriageRet = false;
    for i = 1:length(labelCell)
        for j = 1:length(labelCell{i})
            hasNewLine     = hasNewLine || labelCell{i}(j)==10;
            hasCarriageRet = hasCarriageRet || labelCell{i}(j)==13;
        end
    end
    
    errIf0(hasNewLine || hasCarriageRet, ...
        'vision:insertObjectAnnotation:labelNewLineCR');
end

%==========================================================================
function crossCheckInputs(shape, position, numLabels, color, textColor)
% Cross validate inputs
if ndims(position)==3
    [~, numColsPositions,numRowsPositions] = size(position);
else
    [numRowsPositions, numColsPositions] = size(position);
end
numPtsForShape = getNumPointsForShape(shape,position);
numShapeColors = getNumColors(color);
numTextColors  = getNumColors(textColor);

% cross check shape and position (cols)
% size of position: for rectangle Mx4, for circle Mx3
errIf0(numPtsForShape ~= numColsPositions, ...
    'vision:insertObjectAnnotation:invalidNumColPos');

% cross check label and position (rows)
errIf0((numLabels ~=1) && (numLabels ~= numRowsPositions), ...
    'vision:insertObjectAnnotation:invalidNumLabels');

% cross check color and position (rows). Empty color is caught here
errIf0((numShapeColors ~= 1) && (numRowsPositions ~= numShapeColors), ...
    'vision:insertObjectAnnotation:invalidNumPosNumColor');

% cross check text color and position (rows). Empty color is caught here
errIf0((numTextColors ~= 1) && (numRowsPositions ~= numTextColors), ...
    'vision:insertObjectAnnotation:invalidNumPosNumColor');

%==========================================================================
function colorOut = getColorMatrix(inpClass, numShapes, color)

color = colorRGBValue(color, inpClass);
if (size(color, 1)==1)
    colorOut = repmat(color, [numShapes 1]);
else
    colorOut = color;
end

%==========================================================================
function numPts = getNumPointsForShape(shape, position)

switch shape
    case 'rectangle'
        numPts = 4;% rectangle: [x y width height]
    case 'circle'
        numPts = 3;% circle: [x y radius]
    case 'projected-cuboid' % shape is projected cuboid  
        if ndims(position)==3 % vertices representation
            numPts = 2;
        elseif ndims(position)==2 && all(size(position,[1,2])==[8 2])
            numPts = 2;
        else % rectangle representation
            numPts = 8;
        end
    otherwise
        % code flow should not reach here.
        assert(false,'Incorrect shape.')
end

%==========================================================================
function numColors = getNumColors(color)

% Get number of colors
numColors = 1;
if isnumeric(color)
    numColors = size(color,1);
elseif iscell(color) % if color='red', it is converted to cell earlier
    numColors = length(color);
end

%==========================================================================
function defaultFont = getDefaultFont_sim()

persistent origDefFont

if isempty(origDefFont)
    origDefFont = vision.internal.getDefaultFont();
end
defaultFont = origDefFont;

%==========================================================================
function defaultFont = getDefaultFont_cg()

coder.extrinsic('vision.internal.getDefaultFont');
defaultFont = coder.internal.const(vision.internal.getDefaultFont());


%==========================================================================
function defaults = getDefaultParameters(inpClass)

% Get default values for optional parameters
% default color 'black', default text color 'yellow'
black = [0 0 0];
switch inpClass
    case {'double', 'single'}
        yellow = [1 1 0];
    case 'uint8'
        yellow = [255 255 0];
    case 'uint16'
        yellow = [65535  65535  0];
    case 'int16'
        yellow = [32767  32767 -32768];
        black = [-32768  -32768  -32768];
end

if isSimMode()
    origDefFont = getDefaultFont_sim();
else
    origDefFont = getDefaultFont_cg();
end

defaults = struct(...
    'LineWidth', 1, ...
    'Color', yellow, ...
    'TextColor',  black, ...
    'TextBoxOpacity', 0.6,...
    'FontSize', 12,...
    'Font', origDefFont);

%==========================================================================
function defaults = getDefaultParametersNoVal()

defaults = struct(...
    'LineWidth', uint32(0), ...
    'Color',  uint32(0), ...
    'TextColor', uint32(0), ...
    'TextBoxOpacity', uint32(0),...
    'FontSize', uint32(0),...
    'Font', uint32(0));

%==========================================================================
function properties = getEmlParserProperties()

properties = struct( ...
    'CaseSensitivity', false, ...
    'StructExpand',    true, ...
    'PartialMatching', false);

%==========================================================================
function errIf0(condition, msgID)

coder.internal.errorIf(condition, msgID);

%==========================================================================
function lineWidthOut = checkLineWidth(lineWidth)
% Validate 'LineWidth'

validateattributes(lineWidth, {'numeric'}, ...
    {'nonsparse', 'integer', 'scalar', 'real', 'positive'}, ...
    'insertObjectAnnotation', 'LineWidth');

lineWidthOut = lineWidth;

%==========================================================================
function colorOut = checkColor(color, paramName)
% Validate 'Color' or 'TextColor'

% Validate color
if isnumeric(color)
    vision.internal.inputValidation.validateNotObject(color,'vision','color');
    % must have 6 columns
    validateattributes(color, ...
        {'uint8','uint16','int16','double','single'},...
        {'real','nonsparse','nonnan', 'finite', '2d', 'size', [NaN 3]}, ...
        mfilename, paramName);
    colorOut = color;
else
    if ~isSimMode()
        % codegen does not support cell array
        errIf0(~isnumeric(color), 'vision:insertShape:colorNotNumeric');
        colorOut = color;
    else
        if ischar(color) || isstring(color)
            colorCell = cellstr(color);
        else
            validateattributes(color, {'cell'}, {}, mfilename, 'BoxColor');
            colorCell = color;
        end
        supportedColorStr = {'blue','green','red','cyan','magenta', ...
            'yellow','black','white'};
        numCells = length(colorCell);
        colorOut = cell(1, numCells);
        for ii=1:numCells
            colorOut{ii} =  validatestring(colorCell{ii}, ...
                supportedColorStr, mfilename, paramName);
        end
    end
end

%==========================================================================
function tf = checkTextBoxOpacity(opacity)
% Validate 'TextBoxOpacity'
vision.internal.inputValidation.validateNotObject(opacity,'vision','opacity');
validateattributes(opacity, {'numeric'}, {'nonempty', 'nonnan', ...
    'finite', 'nonsparse', 'real', 'scalar', '>=', 0, '<=', 1}, ...
    mfilename, 'TextBoxOpacity');
tf = true;

%==========================================================================
function tf = checkFontSize(FontSize)
% Validate 'FontSize'
vision.internal.inputValidation.validateNotObject(FontSize,'vision','FontSize');
validateattributes(FontSize, {'numeric'}, ...
    {'nonempty', 'integer', 'nonsparse', 'scalar', '>=', 8, '<=', 72}, ...
    mfilename, 'FontSize');
tf = true;

%==========================================================================
function textLocAndWidth = getTextLocAndWidth(shape, position, lineWidth)
% This function computes the text location and the width of the shape
% Text location:
%   * It is the bottom-left corner (x,y) of the label text box
%   * Label text box is left aligned with shape
%   * Since label text box is placed above the shape (i.e., bottom border
%     of the label text box touches the top-most point of the shape),
%     (x, y) is computed as follows:
%     For 'rectangle' shape, (x, y) is the top-left corner of the shape
%     For 'circle' shape, (x, y) is the top-left corner of the rectangle
%     that encloses the shape (circle)
%     For 'projected-cuboid' shape, (x,y) is the top left vertex of the
%     front face in rectangles representation and (x,y) is the left most
%     vertex in the vertices representation.
% Width of label text box:
%   * For 'rectangle' shape, Width of label text box = width of rectangle
%   * For 'circle' shape, Width of label text box = diameter of circle


halfLineWidth = floor(lineWidth/2);
lineWidthAdj = 2*halfLineWidth; % adjusted line width

switch shape
    case 'rectangle'
        % position must not be a column vector
        % [x y width]
        textLocAndWidth = position(:,1:4);
        textLocAndWidth(:,2) = textLocAndWidth(:,2) - int32(1) - int32(halfLineWidth);
        textLocAndWidth(:,1) = textLocAndWidth(:,1) - int32(halfLineWidth);
        textLocAndWidth(:,3) = textLocAndWidth(:,3) + int32(lineWidthAdj);
    case 'circle'
        % [x y width] = [center_x-radius center_y-radius-1 2*radius+1]
        textLocAndWidth = [position(:,1)-position(:,3) - int32(halfLineWidth)...
            position(:,2)-position(:,3) - int32(1) - int32(halfLineWidth) ...
            2*position(:,3) + int32(lineWidthAdj+1), ...
            2*position(:,3) + int32(lineWidthAdj+1)];
    case 'projected-cuboid' 
        % projected cuboids can be [8,2,M] or [M,8] depending on vertices
        % or rectangles representation.
        if ndims(position)==3
            % For vertices representation place the text at the left most
            % vertex.
            textLocAndWidth = zeros(size(position,3),4);         
            [textLocAndWidth(:,1),loc] = (min(position(1:8,1,:)));
            loc = squeeze(loc);
            for i=1:size(position,3)
                textLocAndWidth(i,2) = squeeze(position(loc(i),2,i));
            end
            textLocAndWidth(:,4) = 0;
            textLocAndWidth(:,3) = 0;
        elseif all(size(position)==[8 2])
            % This block handles the case when single cuboid vertices are
            % provided. MATLAB squeezes last singleton: [8,2,1] to [8,2].
            textLocAndWidth = zeros(1,4);
            [textLocAndWidth(:,1),loc] = (min(position(1:8,1,:)));
            loc = squeeze(loc);
            for i=1:size(position,3)
                textLocAndWidth(i,2) = squeeze(position(loc(i),2,i));
            end
            textLocAndWidth(:,4) = 0;
            textLocAndWidth(:,3) = 0;
        else
            % For rectangle representation place the text at the top left
            % of front face.
            textLocAndWidth = zeros(size(position,1),4);
            textLocAndWidth = position(:,1:4);
            textLocAndWidth(:,4) = 0;
            textLocAndWidth(:,3) = 0;
        end
    otherwise
        % Code flow should not reach here.
        assert(false,"Invalid shape choice.")
end

%==========================================================================
function inRGB = convert2RGB(I)

if ismatrix(I)
    inRGB = repmat(I,[1 1 3]);
else
    inRGB = I;
end

%==========================================================================
function outColor = colorRGBValue(inColor, inpClass)

if isnumeric(inColor)
    outColor = cast(inColor, inpClass);
else
    if iscell(inColor)
        textColorCell = inColor;
    else
        textColorCell = {inColor};
    end
    
    numColors = length(textColorCell);
    outColor = zeros(numColors, 3, inpClass);
    
    for ii=1:numColors
        supportedColorStr = {'blue','green','red','cyan','magenta','yellow',...
            'black','white'};
        % https://www.mathworks.com/help/techdoc/ref/colorspec.html
        colorValuesFloat = [0 0 1;0 1 0;1 0 0;0 1 1;1 0 1;1 1 0;0 0 0;1 1 1];
        idx = strcmp(textColorCell{ii}, supportedColorStr);
        switch inpClass
            case {'double', 'single'}
                outColor(ii, :) = colorValuesFloat(idx, :);
            case {'uint8', 'uint16'}
                colorValuesUint = colorValuesFloat*double(intmax(inpClass));
                outColor(ii, :) = colorValuesUint(idx, :);
            case 'int16'
                colorValuesInt16 = im2int16(colorValuesFloat);
                outColor(ii, :) = colorValuesInt16(idx, :);
        end
    end
end
%==========================================================================
function label = manageMissingLabels(label)
% Manage what to insert for missing strings or categorical labels. Follow
% the behavior of disp and display "<missing>" for strings and
% <"undefined"> for categoricals.
if ~isempty(label)
    if isstring(label)
        missingString = "<missing>";
    else
        missingString = "<undefined>";
    end
    label = fillmissing(string(label),'constant',missingString);
end
%==========================================================================
function numShapes = numberOfShapes(position)

if ndims(position) == 3
    % Compute the number of cuboids.
    % Vertices representation : 8-by-2-M.
    numShapes = size(position,3);
elseif all(size(position, [1,2]) == [8 2])
    % Compute the number of cuboids.
    % Vertices representation : 8-by-2-by-1
    numShapes  = 1; 
else
    % Compute the number of circles, rectangles and projected cuboids.
    % rectangles representation : M-by-8
    numShapes = size(position, 1);
end 
