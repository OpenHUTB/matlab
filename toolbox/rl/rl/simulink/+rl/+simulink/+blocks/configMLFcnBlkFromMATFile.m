function [policyData,modelData] = configMLFcnBlkFromMATFile(matfilename,blk,namedargs)
% CONFIGMLFCNBLKFORPOLICY

% Revised: 1-6-2022
% Copyright 2022 The MathWorks, Inc.

% This function should be p-coded due to internal APIs for modifying MATLAB
% Function blocks.

arguments
    matfilename (1,1) string
    blk         (1,1) string
    namedargs.FcnName     (1,1) string = "policy_fcn";
end

fname = namedargs.FcnName;
mname = matfilename;

% update the MATLAB Function block code (don't update the code in a
% library)
if strcmp(get_param(bdroot(blk),"LibraryType"),"BlockLibrary")
    policyData = [];
    modelData = [];
else
    [policyData,modelData] = localUpdataMLFcnCode(blk,fname,mname);
end

function [policyData,modelData] = localUpdataMLFcnCode(blk,fname,mname)

% load the policyData from the matfile
try
    vars = who("-file",mname);
catch ex
    error(message("rl:block:PolicyUnableToLoadPolicyData",mname));
end
hasRequiredVars = all(ismember({'model','modelData','policyData','metaData'},vars));
if ~hasRequiredVars
    error(message("rl:block:PolicyInvalidPolicyData",blk));
end
try
    load(mname,"modelData","policyData","metaData");
catch ex
    error(message("rl:block:PolicyUnableToLoadPolicyData",mname));
end

try
    % assert policyData.Verion >= 2
    assert(policyData.Version >= 2);
    
    % get the observation meta data
    if ~isempty(policyData.ObsBusType)
        
        % check if the bus has been auto generated
        if isfield(metaData,"ObsGeneratedBus") && ~isempty(metaData.ObsGeneratedBus)
            % make sure the bus is installed in the model global ws
            Simulink.data.assigninGlobal(bdroot(blk),policyData.ObsBusType,metaData.ObsGeneratedBus);
        end

        buselnames = string(policyData.ObsBusElementNames);
        N = numel(buselnames);
        obsArgs = "observation." + buselnames(1);
        for i = 2:N
            obsArgs = obsArgs + ",observation." + buselnames(i);
        end
        obsdt   = "Bus: " + policyData.ObsBusType;
        obsdim  = [1 1];
    else
        obsArgs = "observation";
        obsdt   = string(policyData.ObsDataTypes);
        obsdim  = policyData.ObsDimensions{1};
    end
    
    % get the action meta data
    if ~isempty(policyData.ActBusType)

        % check if the bus has been auto generated
        if isfield(metaData,"ActGeneratedBus") && ~isempty(metaData.ActGeneratedBus)
            % make sure the bus is installed in the model global ws
            Simulink.data.assigninGlobal(bdroot(blk),policyData.ActBusType,metaData.ActGeneratedBus);
        end

        buselnames = string(policyData.ActBusElementNames);
        N = numel(buselnames);
        varname = "action." + buselnames(1);
        actArgs = varname;
        actInitStr = localInitVariable(...
            varname,policyData.ActDimensions{1},policyData.ActDataTypes{1});
        for i = 2:N
            varname = "action." + buselnames(i);
            actArgs = actArgs + "," + varname;
            actInitStr = actInitStr + localInitVariable(...
                varname,policyData.ActDimensions{i},policyData.ActDataTypes{i});
        end
        if N > 1
            actArgs = sprintf("[%s]",actArgs);
        end
        actdt   = "Bus: " + policyData.ActBusType;
        actdim  = [1 1];
    else
        actArgs = "action";
        actdt   = string(policyData.ActDataTypes);
        actdim  = policyData.ActDimensions{1};

        actInitStr = localInitVariable(actArgs,actdim,actdt);
    end
catch ex
    error(message("rl:block:PolicyInvalidPolicyData",blk));
end

% create the function string
policyType = policyData.PolicyType;
modelType = modelData.ModelType;
str = sprintf(...
    "function action = %s(observation,useSimTarget)"                            + newline + ...
    "%%#codegen"                                                                + newline + ...
    "rl.codegen.model.ModelType.%s;"                                            + newline + ... % dummy use of enumeration needed for codegen g2675487
    "rl.codegen.policy.PolicyType.%s;"                                          + newline + ... % dummy use of enumeration needed for codegen g2675487
    "useExtrinsic = coder.const(coder.target(""sfun"") && ~useSimTarget);"      + newline + ...
    "persistent policy;"                                                        + newline + ...
    "if isempty(policy)"                                                        + newline + ...
    "\tif useExtrinsic"                                                         + newline + ...
    "\t\tpolicy = feval(""coder.loadRLPolicy"",""%s"");"                        + newline + ...
    "\telse"                                                                    + newline + ...
    "\t\tpolicy = coder.loadRLPolicy(""%s"");"                                  + newline + ...
    "\tend"                                                                     + newline + ...
    "end"                                                                       + newline + ...
    "if useExtrinsic"                                                           + newline + ...
    "%s"                                                                                  + ...
    "\t%s = feval(""getAction"",policy,%s);"                                    + newline + ...
    "else"                                                                      + newline + ...
    "\t%s = getAction(policy,%s);"                                              + newline + ...
    "end"                                                                                 , ...
    fname               ,...
    string(modelType)   ,...
    string(policyType)  ,...
    mname               ,...
    mname               ,...
    actInitStr          ,...
    actArgs             ,...
    obsArgs             ,...
    actArgs             ,...
    obsArgs            );

% update the MATLAB function block
chartID = sfprivate('block2chart',get_param(blk,"handle"));
sfh = idToHandle(sfroot,chartID);
if ~strcmp(sfh.Script,str)
    sfh.Script = str;

    sfh.Inputs (1).DataType = obsdt;
    sfh.Outputs(1).DataType = actdt;

    sfh.Inputs (1).Props.Array.Size = mat2str(obsdim);
    sfh.Outputs(1).Props.Array.Size = mat2str(actdim);

    sfh.Inputs(2).DataType = "boolean";
    sfh.Inputs(2).Tunable = false;
    sfh.Inputs(2).Props.Array.Size = "[1 1]";
    sfh.Inputs(2).Scope = "Parameter";
end

function str = localInitVariable(name,dim,dt)
str = sprintf("\t%s = zeros(%s,""%s"");\n",name,mat2str(dim),dt);