function [w,y,u,Weight,Ts,Ny,Nu] = validateData(w,y,u,Weight,Ts)
%

%   Copyright 2015-2017 The MathWorks, Inc.
%% w validation

% Valid specifications:
% 1) w is a numeric column vector
% 2) w is a cell array, where all elements are numeric columns vectors
if isnumeric(w)
    w = {w};
end
validateattributes(w,{'cell'},{'nonempty'},'','w');
Nd = numel(w); % # of datasets
Nf = zeros(Nd,1);
for kkD=1:Nd
    % w must be a column vector with Nf elements
    validateattributes(w{kkD},{'numeric'},{'nonempty','column','finite'},'','w');
    if ~isa(w{kkD},'double')
        w{kkD} = double(w{kkD});
    end
    Nf(kkD) = numel(w{kkD});
end

%% y validation

% Valid specifications:
% 1) A numeric column vector, and Nd is 1
% 2) A cell array, where all elements are numeric column vectors. numel(y) 
% is Nd. Each elelement must have the same number of columns (system 
% outputs). The # of rows in k-th element must match with the k-th frequency 
% vector w{k}
if isnumeric(y)
    y = {y};
end
validateattributes(y,{'cell'},{'numel',Nd},'','y');
Ny = size(y{1},2); % # of outputs
for kkD=1:Nd
    % y{kkD} must be a [Nf(kkD) Ny] matrix
    validateattributes(y{kkD},{'numeric'},{'nonempty','finite','2d','size',[Nf(kkD) Ny]},'','y')
    if ~isa(y{kkD},'double')
        y{kkD} = double(y{kkD});
    end
end

%% u validation

% Valid specifications:
% 1) [], {}, {[]}, 1 (assume Nu=1 and u=1s)
% 2) A numeric column vector, and Nd is 1
% 3) A cell array, where all elements are numeric column vectors. numel(u)
% is Nd. Each element must have the same number of columns (system inputs).
% The # of rows in k-th element must match with the k-th frequency vector w{k}
emptyU = isempty(u) || ... % [] or {}
    (iscell(u) && all(cellfun('isempty',u))) || ... % {[],...,[]}
    (isnumeric(u) && isscalar(u) && u==1);
if emptyU
    % U is empty, fill it. No need for any validation
    Nu = 1;
    u = cell(Nd,1);
    for kkD=1:Nd
        u{kkD} = ones(Nf(kkD),1);
    end
else
    % User provided u, perform validations
    if isnumeric(u)
        u = {u};
    end
    validateattributes(u,{'cell'},{'numel',Nd},'','u');
    Nu = size(u{1},2); % # of outputs
    
    for kkD=1:Nd
        % u{kkD} must be a [Nf(kkD) Nu] matrix
        validateattributes(u{kkD},{'numeric'},{'nonempty','finite','2d','size',[Nf(kkD) Nu]},'','u');
        if ~isa(u{kkD},'double')
            u{kkD} = double(u{kkD});
        end
    end    
end

%% Weight validation

% Valid specifications:
% 1) [], {}, {[]}, any scalar (assume Weight=1s)
% 2) A numeric column vector, and Nd is 1
% 3) A cell array. numel(Weight) is Nd. Each element must be either a
% column vector with Nf(kkD) elements, of a [Nf(kkD) Ny] matrix.
emptyWeight = isempty(Weight)  || ... % {}, []
    (iscell(Weight) && all(cellfun('isempty',Weight))) || ... % {[],...,[]}
    (isnumeric(Weight) && isscalar(Weight));
if emptyWeight
    % Weight is empty, fill it. No need for any validation
    Weight = cell(Nd,1);
    for kkD=1:Nd
        Weight{kkD} = ones(Nf(kkD),Ny);
    end
else
    % User provided Weight, perform validations
    if isnumeric(Weight)
        Weight = {Weight};
    end
    validateattributes(Weight,{'cell'},{'numel',Nd},'','Weight');
    for kkD=1:Nd
        % Weight{kkD} must be either a Nd(kkD) column vector, or a [Nf(kkD)
        % Ny] matrix
        %
        % Expand Weight if specified as a vector. This is for specifying a
        % single frequency-based weight to be applied for all I/O channels
        if isnumeric(Weight{kkD}) && iscolumn(Weight{kkD}) && numel(Weight{kkD})==Nf(kkD)
            Weight{kkD} = repmat(Weight{kkD},1,Ny);
        end
        validateattributes(Weight{kkD},{'numeric'},{'nonempty','finite','2d','size',[Nf(kkD) Ny]},'','Weight');
        if ~isa(Weight{kkD},'double')
            Weight{kkD} = double(Weight{kkD});
        end
    end
end

%% Ts validation

% Treat Ts=-1 as Ts=1
if Ts==-1
    warning(message('Controllib:estimation:fitRationalUnspecifiedTs'));
    Ts = 1;
end
validateattributes(Ts,{'numeric'},{'real','finite','scalar','nonnegative'},'','Ts')
if ~isa(Ts,'double')
    Ts = double(Ts);
end

%% Data concatenation for multiple datasets
w = vertcat(w{:});
y = vertcat(y{:});
u = vertcat(u{:});
Weight = vertcat(Weight{:});

%% Select & eliminate unnecessary frequency points

% Appropriate frequency points: 
% * Finite, non-negative frequencies for continuous time
% * Under Nyquist frequency for discrete time
% * Non-zero weight across columns of Weight. This means for a given
% frequency point all I/O channels get multiplied by 0 and have no impact
% on the cost fcn
if Ts==0 % Assumption: w has the units rad/TimeUnit
    idxKeep = w>=0 & w<Inf;
else
    idxKeep = w>=0 & w<=pi/Ts; 
end
idxKeep = idxKeep & any(Weight~=0,2);
% Eliminate the unnecessary points
w = w(idxKeep);
y = y(idxKeep,:);
u = u(idxKeep,:);
Weight = Weight(idxKeep,:);
% Ensure there is data left
validateattributes(w,{'numeric'},{'nonempty'},'','w');
end