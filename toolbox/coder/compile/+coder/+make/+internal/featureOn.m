function mode_out = featureOn(feature, mode_in)
%

% Copyright 2019-2022 The MathWorks, Inc.

mlock;
persistent features;

if isempty(features)
    features = struct(...
        'CacheVcVars', true, ...
        'SilPwsReusableLibs', false,...
        'CMakeWriterSupportsOpenMP', true,...
        'BuildInfoRootFolders', false,...
        'ExplicitLibClosing', true, ...
        'TargetFrameworkToolchain', true, ...
        'TargetFrameworkToolchainUpgrade', false, ...
        'UseAdapterForClassicToolchain', true, ...
        'ApplicationWithServices', false, ...
        'BuildCoderAssumptionsForSDP', false);
    % The following feature control is for internal testing purpose, we
    % allow the single model reference scenario for true Parallel Build
    % FBT. This is an alternative approach to registering a testing hook
    % via SLTH_RegisterTestingHook, that requires the registration to be 
    % done from C++ code owned by a upstream component. However, this type 
    % of C++ file is not available under current consideration. Therefore, 
    % this feature control mechanism is chosen so long as the its owning
    % component, i.e., coder/compile, is upstream of simulink_core that
    % owns the downstream clients 
    features.SingleMdlRefAllowedForTesting = false;
end

assert(isfield(features, feature),...
    'Feature ''%s'' is not available!', feature);

% Check for outputs
if nargout == 1
    mode_out = features.(feature);
end

% Check for inputs
if nargin >= 2
    
    % Verify type before continuing    
    % new value must be boolean
    assert(islogical(mode_in),...
        'Feature value for ''%s'' must be a logical!', feature)
    
    % Assign new value to struct field.
    features.(feature) = mode_in;
    
end
