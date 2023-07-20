function msiwrite(obj,freq,fname,varargin)
%MSIWRITE   Writes data in MSI Planet Antenna File Format. It
%           outputs a file with the .PLN file extension. 
%
% msiwrite(obj,freq,fname) writes calculated data from the antenna or array 
% object at the specified frequency in the MSI Planet Antenna file format in the
% location specified.
%
% msiwrite(__,Name,Value) writes calculated data from the antenna or array 
% object at the specified frequency in the MSI Planet Antenna file format in the
% location specified with  additional options specified by one or more
% Name, Value pairs.
%
% Input Arguments
%
% obj:  An antenna or array object 
%
% freq: Freqeuncy of operation of the antenna object
%
% fname:    File name specified as a string. File extension can be .msi or .pln
%         . By default, .pln is added to the fname.
%
% Below are the list of Name-Value pairs available in the pattern function
%
% Name: File name specified as a string.
%    
% Comment: Comments to the file specified as a string.
% Examples
%
% % Example1: Write the data generated using the default helix at 2GHz in
% % the MSI Planet file format.
%
% h = helix; 
% msiwrite(h, 2e9,'test_file','Name','Designed Helix Antenna in MATLAB','Comment','This antenna is for space simulations');
%
%
% See also <a href="matlab:help msiread">msiread</a>, <a href="matlab:help msiwrite">msiwrite</a>

%   Copyright 2015 The MathWorks, Inc.

% Check for the number of inputs
narginchk(3,7);

% Throwing error messages if number of inputs are not valid
if isequal(nargin,4)
    error(message('antenna:antennaerrors:UnspecifiedValue'));
end

if isequal(nargin,6)
    error(message('antenna:antennaerrors:UnspecifiedValue'));
end

% Parsing through the inputs
parseobj = inputParser;
parseobj.FunctionName = 'writemsi';
typeValidationFcnnum = @(x) validateattributes(x,{'numeric'},              ...
    {'scalar','nonempty', 'real','finite', 'nonnan', 'positive'},'writemsi');
addRequired(parseobj,'freq', typeValidationFcnnum);
typeValidationchar = @(x) validateattributes(x,{'char','string'},          ...
    {'nonempty', 'scalartext'}, 'writemsi');
addRequired(parseobj,'fname',typeValidationchar);
addParameter(parseobj,'Name','',typeValidationchar);
addParameter(parseobj,'Comment','',typeValidationchar);
parse(parseobj, freq, fname, varargin{:});

% Creating local structures for storage of data
DataStore = struct;
Horz = struct;
Vert = struct;

% Storing the optional arguments
if nargin > 3
    N1 = lower((varargin{1}));
    DataStore.(N1) = varargin{2};
elseif nargin > 5
    N2 = lower((varargin{3}));
    DataStore.(N2) = varargin{4};
end

DataStore.frequency = freq;

% Checking if the .msi extension was provided
if strfind(fname, '.msi')
elseif strfind(fname, '.pln')
else
    % Adding the .PLN file extension to the fname
    fname = strcat(fname,'.pln');
end

% Calculating the vertical and horizontal gain data
H = patternAzimuth(obj,freq);
V = patternElevation(obj,freq);

% Angle vectors
Horzang = (0:1:359)';
Vertang = (0:1:359)';

% Taking the first 360 points
Horzdata = H(1:360);
Vertdata = V(1:360);

%% Commenting out stuff because of findpeaks

% % Calculating the beamwidth and F/B ratios
% L = em.internal.measureLobes(Horzang, Horzdata);
% H_FB = L.FB;
% 
% M = em.internal.measureLobes(Vertang, Vertdata);
% V_FB = M.FB;
% 
% H_Width = L.HPBW;
% DataStore.h_width = H_Width;
% 
% V_Width = M.HPBW;
% DataStore.v_width = V_Width;
% 
% if H_FB > V_FB
%     value1 = H_FB;
%     DataStore.front_to_back = value1;
% else
%     value1 = V_FB;
%     DataStore.front_to_back = value1;
% end

%% This cell calculates the gain based on the two plane (H & V) data

% Calculating the gain from the pattern data
gain1 = max(Horzdata);
gain2 = max(Vertdata);

% Taking the bigger gain value to use as a reference data point
if gain1 >= gain2
    gain = gain1;
    DataStore.gain.value = gain;
    DataStore.gain.unit = 'dBi';
else
    gain = gain2;
    DataStore.gain.value = gain;
    DataStore.gain.unit = 'dBi';
end
%% Da Huang brought the point of the gain calculated not lying on the two 
% planes. This cell contains the code of calculating max gain out of the 3D
% pattern and writing it into the file.

% [D] = pattern(obj,freq);
% gain = max(max(D));
% DataStore.gain.value = gain;
% DataStore.gain.unit = 'dBi';

%%
% Making the gain points refer to the gain value
Horzdata = abs((Horzdata - gain));
Vertdata = abs((Vertdata - gain));

% Storing the data in the local structures
Horz.magnitude = Horzdata;
Horz.angle = Horzang;
Horz.size = size(Horzdata,1);
Horz.slice = 'horizontal';

Vert.magnitude = Vertdata;
Vert.angle = Vertang;
Vert.size = size(Vertdata,1);
Vert.slice = 'vertical';

% Calling the write function to write data in the file
em.internal.writer(fname,Horz,Vert,DataStore);
end