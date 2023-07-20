function init(this, cli)
%

%   Copyright 2005-2013 The MathWorks, Inc.

tools = {'vivado', 'ise', 'libero', 'precision', 'quartus', 'synplify','custom'};

for i=1:length(tools)
    edascript = hdlgetedascript(tools{i});
    % hdlgetedascript returns field with the following script parts:
    % SynScriptPostFix, SynScriptInit, SynScriptCmd, SynScriptTerm,
    % SynLibCmd, SynLibSpec.  Only SynScript* fields appear in the GUI.
    scriptParts = fieldnames(edascript);
    scriptParts = scriptParts(strncmp(scriptParts, 'SynScript', 9));
    
    % get the first letter of the tool name in order to concatenate it with
    % script part names for accessing class property
    toolInit = upper(tools{i}(1));
    for j=1:length(scriptParts)
        this.([scriptParts{j} '_' toolInit]) = edascript.(scriptParts{j});
    end
end

% update UI property from CLI if a tool has been selected
toolChoice = cli.HDLSynthTool;
if strcmpi(toolChoice, 'Synplify')
    this.SynScriptPostFix_S  = cli.HDLSynthFilePostfix;
    this.SynScriptInit_S = cli.HDLSynthInit;
    this.SynScriptCmd_S = cli.HDLSynthCmd;
    this.SynScriptTerm_S = cli.HDLSynthTerm;
elseif strcmpi(toolChoice, 'Precision')
    this.SynScriptPostFix_P  = cli.HDLSynthFilePostfix;
    this.SynScriptInit_P = cli.HDLSynthInit;
    this.SynScriptCmd_P = cli.HDLSynthCmd;
    this.SynScriptTerm_P = cli.HDLSynthTerm;
elseif strcmpi(toolChoice, 'ISE')
    this.SynScriptPostFix_I  = cli.HDLSynthFilePostfix;
    this.SynScriptInit_I = cli.HDLSynthInit;
    this.SynScriptCmd_I = cli.HDLSynthCmd;
    this.SynScriptTerm_I = cli.HDLSynthTerm;
elseif strcmpi(toolChoice, 'Vivado')
    this.SynScriptPostFix_V  = cli.HDLSynthFilePostfix;
    this.SynScriptInit_V = cli.HDLSynthInit;
    this.SynScriptCmd_V = cli.HDLSynthCmd;
    this.SynScriptTerm_V = cli.HDLSynthTerm;
elseif strcmpi(toolChoice, 'Libero')
    this.SynScriptPostFix_L  = cli.HDLSynthFilePostfix;
    this.SynScriptInit_L = cli.HDLSynthInit;
    this.SynScriptCmd_L = cli.HDLSynthCmd;
    this.SynScriptTerm_L = cli.HDLSynthTerm;
elseif strcmpi(toolChoice, 'Quartus')
    this.SynScriptPostFix_Q  = cli.HDLSynthFilePostfix;
    this.SynScriptInit_Q = cli.HDLSynthInit;
    this.SynScriptCmd_Q = cli.HDLSynthCmd;
    this.SynScriptTerm_Q = cli.HDLSynthTerm;
elseif strcmpi(toolChoice, 'Custom')
    this.SynScriptPostFix_C  = cli.HDLSynthFilePostfix;
    this.SynScriptInit_C = cli.HDLSynthInit;
    this.SynScriptCmd_C = cli.HDLSynthCmd;
    this.SynScriptTerm_C = cli.HDLSynthTerm;
end

% HDLLintTool specific stuff - load the known defaults
% and create dynamic fields with the alternatives for Lint Tool

% first load all defaults into the tool specific options
defaults = hdlgetlintscript('None');

this.HDLLintCmd_N = defaults{2}; % HDLLintCmd
this.HDLLintInit_N = defaults{4}; % HDLLintInit
this.HDLLintTerm_N = defaults{6}; % HDLLintTerm

defaults = hdlgetlintscript('Leda');

this.HDLLintCmd_L = defaults{2}; % HDLLintCmd
this.HDLLintInit_L = defaults{4}; % HDLLintInit
this.HDLLintTerm_L = defaults{6}; % HDLLintTerm


defaults = hdlgetlintscript('SpyGlass');

this.HDLLintCmd_S = defaults{2}; % HDLLintCmd
this.HDLLintInit_S = defaults{4}; % HDLLintInit
this.HDLLintTerm_S = defaults{6}; % HDLLintTerm

defaults = hdlgetlintscript('AscentLint');

this.HDLLintCmd_A = defaults{2}; % HDLLintCmd
this.HDLLintInit_A = defaults{4}; % HDLLintInit
this.HDLLintTerm_A = defaults{6}; % HDLLintTerm


defaults = hdlgetlintscript('HDLDesigner');

this.HDLLintCmd_H = defaults{2}; % HDLLintCmd
this.HDLLintInit_H = defaults{4}; % HDLLintInit
this.HDLLintTerm_H = defaults{6}; % HDLLintTerm

defaults = hdlgetlintscript('Custom');

this.HDLLintCmd_C = defaults{2}; % HDLLintCmd
this.HDLLintInit_C = defaults{4}; % HDLLintInit
this.HDLLintTerm_C = defaults{6}; % HDLLintTerm


% Update with CLI anything more specific
Z = upper(cli.HDLLintTool(1));
    
this.(['HDLLintCmd_',Z]) = cli.HDLLintCmd;
this.(['HDLLintInit_',Z]) = cli.HDLLintInit;
this.(['HDLLintTerm_',Z]) = cli.HDLLintTerm;

end
