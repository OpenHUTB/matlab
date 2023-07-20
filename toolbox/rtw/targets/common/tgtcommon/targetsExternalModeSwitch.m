%TARGETSEXTERNALMODESWITCH This function enables switching between build and external mode configurations
%   TARGETSEXTERNALMODESWITCH This function enables switching between build and 
%   external mode configurations

%   Copyright 1990-2007 The MathWorks, Inc.

function targetsExternalModeSwitch(varargin)

% Define parameters
sigs{1} = {'modelName'};
sigs{2} = {'modelName' 'action'};

% Parse arguments
args = targets_parse_argument_pairs(sigs{end}, varargin);

n = targets_find_signature(sigs, args);

switch n
  
  case 1
    modelName = args.modelName;

    % Put up the dialog
    selections = {'Building an executable' 'External mode'};
    promptString = {'This block allows you to configure your model', ... 
      'for building an executable or using external mode.', ...
      'Please select a configuration:'};
    [selection, ok] = listdlg('Name', 'External mode configuration', ...
      'PromptString', promptString, 'SelectionMode', 'single', 'ListString', ...
      selections, 'ListSize', [250, 100]);
    
    if ok
      i_setupModel(modelName, selections{selection});
    else
      return;
    end
    
  case 2
    modelName = args.modelName;
    action = args.action;
    i_setupModel(modelName, action);

        
  otherwise
    TargetCommon.ProductInfo.error('common', 'UnknownFunctionSignature');
    
end % switch

% end targetsExternalModeSwitch

function i_setupModel(modelName, action)
  action = lower(action);
  
  switch action
    case 'building an executable'
      disp(' ')
      disp('1- Setting up the model to build an executable.');
      set_param(modelName, 'ExtMode', 'off');
      disp('2- Turning on optimization inline parameters required for ASAP2 generation.');
      set_param(modelName, 'InlineParams', 'on');
      disp('3- Selecting "normal" simulation mode.')
      set_param(modelName, 'SimulationMode', 'normal');
      disp('4- Selecting ASAP2 as the data exchange interface.');
      set_param(modelName, 'GenerateASAP2', 'on');
      
    case 'external mode'
      disp(' ')
      disp('1- Setting up the model for External Mode.');
      % Set model parameters for external mode
      disp('2- Turning on optimization inline parameters required for External mode.');      
      set_param(modelName, 'InlineParams', 'on');
      disp('3- Selecting "external" simulation mode.');
      set_param(modelName, 'SimulationMode', 'external');
      disp('4- Selecting External mode as the data exchange interface.')
      set_param(modelName, 'ExtMode', 'on');
      
    otherwise
      TargetCommon.ProductInfo.error('common', 'UnsupportedAction', 'unable to setup the model');
      
  end % switch
  
% end i_setupModel
