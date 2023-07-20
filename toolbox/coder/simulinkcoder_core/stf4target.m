function stf4target(nameStr, hObj)
% STF4TARGET  converting rtwoptions in system target file to properties in 
%             an object; Note that this is called during object creation.
%             You should not set value to properties that have init access.
%             Things that are setup during this routine:
%             1) Instance specific property
%             2) Default value and the enable status of those properties
%             3) Register those properties in the prop list
%             4) Setup derivation structure
%             5) Setup UI items
%             6) Property preset listener
%             7) Tlc options and make options markup string

% Copyright 2002-2021 The MathWorks, Inc.
% 

  if ~isa(hObj, 'Simulink.STFCustomTargetCC')
      DAStudio.error('RTW:configSet:unsupportedClassType');
      % return;
  end

  if isempty(nameStr)
      DAStudio.error('RTW:utility:emptyValue','nameStr');
      % return;
  end
  
  % If rtw not installed or available
  if ~(exist('rtwprivate','file')==2 || exist('rtwprivate','file')==6)
      DAStudio.error('RTW:configSet:rtwComponentUnavailable');
      % return;
  end

      
  [rtwoptions, gensettings] = coder.internal.getSTFInfo([],...
                                         'SystemTargetFile',nameStr);
  
  % Create identifier based on TLC file name, to be included in data type
  % name for enum (popup) parameters.  
  % If the TLC file is under matlabroot, store path from matlabroot
  % otherwise, just store TLC file name to avoid storing customer-specific
  % info in the model
  if ~isempty(strfind(gensettings.SystemTargetFile, matlabroot))
      stfapp = strrep(gensettings.SystemTargetFile, matlabroot, '');
  else
      [path, ~, ~] = fileparts(gensettings.SystemTargetFile);
      stfapp = strrep(gensettings.SystemTargetFile, path, '');
  end
  stfapp = strrep(stfapp, '.tlc', '_');
  stfapp = strrep(stfapp, '/', '_');
  stfapp = strrep(stfapp, ':', '_');
  stfapp = strrep(stfapp, '\', '_');
  stfapp = strrep(stfapp, '.', '');
  
  props   = [];
  tag = 'Tag_ConfigSet_RTW_STFTarget_';
  
  % whether system target file is updated to support dynamic dialog call back
  version = '';
  if isfield(gensettings, 'Version') 
      if ischar(gensettings.Version) && str2double(gensettings.Version) >= 1
          supportCB = true;
          version = gensettings.Version;
      else
          supportCB = false;
          MSLDiagnostic('RTW:utility:incorrectSTFVersion',...
                           gensettings.SystemTargetFile).reportAsWarning;
      end
  else
      supportCB = false;
  end
  
  % initial setup for dynamic dialog
  if ~isempty(rtwoptions)
      index         = 0;
      categoryIndex = 0;
  end
  
  % If this target is derived from another target; we want to 
  % 1) Attach the parent target as a component of the current target;
  % 2) Transfer default values of the common target options from parent target
  %    to this target;
  if isfield(gensettings, 'DerivedFrom') && ~isempty(gensettings.DerivedFrom)
                    
      parentSTF = gensettings.DerivedFrom;     
      hParentSTF = [];
      try
          hParentSTF = stf2target(gensettings.DerivedFrom);
      catch exc %#ok<NASGU>
                % ignore the error
      end
      
      if isempty(hParentSTF)
          DAStudio.error('RTW:configSet:instantiateTargetFailure',...
                         parentSTF,gensettings.SystemTargetFile);
      end
      
      loc_AddParentTarget(hObj, hParentSTF);
  end
  
  % store activate callback in object
  if isfield(gensettings, 'ActivateCallback') && ~isempty(gensettings.ActivateCallback)
      hObj.ActivateCallback = gensettings.ActivateCallback;
  end

  % store deselect callback in object
  if isfield(gensettings, 'DeselectCallback') && ~isempty(gensettings.DeselectCallback)
      hObj.DeselectCallback = gensettings.DeselectCallback;
  end
  
  % store post apply callback in object
  if isfield(gensettings, 'PostApplyCallback') && ~isempty(gensettings.PostApplyCallback)
      hObj.PostApplyCallback = gensettings.PostApplyCallback;
  end
  
  % Add properties for each rtwoption and create make option string on the fly
  makeoption = '';
  tlcoption = '';
  enumReg = [];
  setFunctions = [];
  getFunctions = [];
  hasCallback = false;
  widgetID_index = 0;
  
  % First, go through all the options to see if we need to automatically
  % attach an ERT target
  uiOnly(1:length(rtwoptions)) = false;
  optionIgnored(1:length(rtwoptions)) = false;
  for i = 1:length(rtwoptions)
      thisOption        = rtwoptions(i);
      thisOptionName    = thisOption.tlcvariable;
      thisOptionMakeVar = thisOption.makevariable;
      if isempty(thisOptionName) && ~isempty(thisOptionMakeVar)
          thisOptionName = thisOptionMakeVar;
      end
      
      if ~isempty(thisOptionName)
          switch thisOptionName
            case {'RollThreshold',...
                  'InlineInvariantSignals',...
                  'BufferReuse',...
                  'EnforceIntegerDowncase',...
                  'FoldNonRolledExpr',...
                  'LocalBlockOutputs',...
                  'RTWExpressionDepthLimit',...
                  'MaxRTWIdLen',...
                  'IncHierarchyInIds',...
                  'GenerateComments',...
                  'ForceParamTrailComments',...
                  'ShowEliminatedStatement',...
                  'IgnoreCustomStorageClasses',...
                  'IncDataTypeInIds', ...
                  'PrefixModelToSubsysFcnNames',...
                  'InlinedPrmAccess',...
                  'GenerateReport',...
                  'RTWVerbose'}
              % Ignore options that we have moved to other components
              optionIgnored(i) = true;
              
            case {'LogVarNameModifier',...
                  'MatFileLogging',...
                  'TargetLangStandard',...
                  'GenFloatMathFcnCalls',...
                  'TargetFunctionLibrary',...
                  'CodeReplacementLibrary',...
                  'MultiInstanceERTCode',...
                  'CodeInterfacePackaging'}
              % those properties are promoted to base target, we only
              % present the ui not register property
              uiOnly(i) = true;
              
            case {'ZeroInternalMemoryAtStartup',...
                  'ZeroExternalMemoryAtStartup',...
                  'InsertBlockDesc',...
                  'InitFltsAndDblsToZero',...
                  'GenerateErtSFunction'}
              % Ignore ert options that we have moved to other components
              
              if strcmp(hObj.IsERTTarget, 'off')
                  hObj.IsERTTarget = 'on';
                  
                  if isempty(hObj.getComponent('Target'))
                      hParentTarget = Simulink.ERTTargetCC;
                      
                      loc_AddParentTarget(hObj, hParentTarget);
                      hObj.ForcedBaseTarget = 'on';
                  else
                      hParentTarget = hObj.getComponent('Target');
                      if strcmp(hParentTarget.IsERTTarget, 'off')
                          MSLDiagnostic('RTW:buildProcess:ERTOnlyOption',...
                                           thisOptionName).reportAsWarning;
                      end
                  end
              end
              optionIgnored(i) = true;
              
            case {'IncludeMdlTerminateFcn',...
                  'ERTCustomFileBanners',...
                  'CombineOutputUpdateFcns',...
                  'SuppressErrorStatus',...
                  'GenerateSampleERTMain',...
                  'PurelyIntegerCode'}
              % ERT options will be defined by the base target and thus are UI only.
              uiOnly(i) = true;
              if strcmp(hObj.IsERTTarget, 'off')
                  hObj.IsERTTarget = 'on';
                  
                  if isempty(hObj.getComponent('Target'))
                      hParentTarget = Simulink.ERTTargetCC;
                      
                      loc_AddParentTarget(hObj, hParentTarget);
                      hObj.ForcedBaseTarget = 'on';
                      
                  else
                      hParentTarget = hObj.getComponent('Target');
                      if strcmp(hParentTarget.IsERTTarget, 'off')
                          MSLDiagnostic('RTW:buildProcess:ERTOnlyOption',...
                                           thisOptionName).reportAsWarning;
                      end
                  end
              end
              
            otherwise
          end % switch thisOptionName
      end
  end
  
  isERTTarget = strcmp(hObj.IsERTTarget, 'on');
  hasForcedBase = strcmp(hObj.ForcedBaseTarget, 'on');
  modelReferenceParameterCheck = [];
  
  for i = 1:length(rtwoptions)
      thisOption        = rtwoptions(i);
      thisOptionName    = thisOption.tlcvariable;
      thisOptionType    = thisOption.type;
      thisOptionDefault = thisOption.default;
      thisOptionMakeVar = thisOption.makevariable;
      thisOptionPrompt  = thisOption.prompt;
      thisOptionEnable  = thisOption.enable;
      if(isfield(thisOption, 'modelReferenceParameterCheck'))
          thisOptionModelReferenceParameterCheck = thisOption.modelReferenceParameterCheck;
      else
          thisOptionModelReferenceParameterCheck = '';
      end

      
      if ischar(thisOption.tooltip)
          thisOptionTooltip = thisOption.tooltip;
      else
          thisOptionTooltip = '';
      end
      if (supportCB &&...
          isfield(thisOption, 'callback') &&...
          ~isempty(thisOption.callback))
          thisOptionCallback = thisOption.callback;
      else
          thisOptionCallback = '';
      end    
      if (isfield(thisOption, 'callback') && ~isempty(thisOption.callback)) || ...
              (isfield(thisOption, 'opencallback') && ~isempty(thisOption.opencallback)) || ...
              (isfield(thisOption, 'closecallback') && ~isempty(thisOption.closecallback))
          hasCallback = true;
      end
      
      if isempty(thisOptionName) 
          if ~isempty(thisOptionMakeVar)
              thisOptionName = thisOptionMakeVar;
          else
              thisOptionName = '';
          end
      end
      
      thisUIOnly = uiOnly(i);
      
      % skip this option if it is ignored (move to other component)
      if optionIgnored(i)
          continue;
      end
      
      % Now that we know if we have a forced base ERT target or not, we can remove
      % options that are already declared by the base target
      if ~isempty(thisOptionName) && isERTTarget && hasForcedBase
          switch thisOptionName
            case {'GenerateASAP2',...
                  'ExtMode',...
                  'ExtModeTesting',...
                  'InlinedParameterPlacement',...
                  'TargetOS',...
                  'MultiInstanceERTCode',...
                  'MultiInstanceErrorCode',...
                  'CodeInterfacePackaging',...
                  'TargetLangStandard',...
                  'GenFloatMathFcnCalls',...
                  'TargetFunctionLibrary',...
                  'CodeReplacementLibrary',...
                  'ERTSrcFileBannerTemplate',...
                  'ERTHdrFileBannerTemplate',...
                  'ERTCustomFileTemplate'}
              thisUIOnly = true;
          end      
      end
      
      % initialize value
      uiType           = '';
      uiName           = '';
      uiObjectProperty = '';
      uiEntries        = [];
      uiValues         = [];
      propType         = [];
      
      if ~isempty(thisOptionType)
          % Select property type based on thisOptionType
          switch thisOptionType
            case 'Checkbox'
              propType         = 'slbool';
              uiType           = 'checkbox';
              uiName           = thisOptionPrompt;
              uiObjectProperty = thisOptionName;
              
            case 'Popup'        
              if thisUIOnly && hasProp(hObj, thisOptionName)
                  % UIOnly ==> this option is defined in internally
                  % We need to get its internal definition 
                  hOwner = getPropOwner(hObj, thisOptionName);
                  hProp = findprop(hOwner, thisOptionName);
                  hType = findtype(hProp.DataType);
                  if isprop(hType, 'Strings')
                      enumStrings = hType.Strings;
                  else
                      enumStrings = thisOption.popupstrings;
                      enumStrings = eval(['{''', strrep(enumStrings, '|', '''; '''), '''}']);
                  end
                  if isprop(hType, 'Values')
                      enumValues = hType.Values;
                  else
                      enumValues = 0:length(enumStrings)-1;
                  end
              else
                  propType = ['RTWOptions_EnumType_', stfapp, loc_GetVersionID(version), thisOptionName];
                  if isempty(findtype(propType))
                      enumStrings = thisOption.popupstrings;
                      enumStrings = eval(['{''', strrep(enumStrings, '|', '''; '''), '''}']);
                      if isfield(thisOption, 'value') && ~isempty(thisOption.value)
                          startVal = thisOption.value;
                          endVal   = thisOption.value+length(enumStrings)-1;
                          enumValues = startVal(1) : endVal(1);
                      else
                          enumValues = 0:length(enumStrings)-1;
                      end
                      schema.EnumType(propType, enumStrings, enumValues);
                  else
                      type = findtype(propType);
                      enumStrings = type.Strings;
                      enumValues  = type.Values;
                      %      else
                      %        warning(sprintf('A type named ''%s'' already exists.', propType));
                  end
                  if isempty(enumReg)
                      enumReg.Name = propType;
                      enumReg.Strings = enumStrings;
                      enumReg.Values = enumValues;
                  else
                      enumReg(end+1).Name = propType; %#ok<AGROW>
                      enumReg(end).Strings = enumStrings;
                      enumReg(end).Values = enumValues;
                  end
              end
              uiType           = 'combobox';
              uiName           = thisOptionPrompt;
              uiObjectProperty = thisOptionName;
              uiEntries        = enumStrings';
              uiValues         = enumValues;
            case 'Edit'
              isInt = ~isempty(regexp(thisOptionDefault, '^[+-]?\d+$','once'));
              if isInt
                  propType = 'int32';
                  thisOptionDefault = str2double(thisOptionDefault);
              else
                  propType = 'string';
              end
              uiType = 'edit';
              uiName = thisOptionPrompt;
              uiObjectProperty = thisOptionName;
              
            case 'NonUI'
                % For backwards compatibility purposes, [0,1] must be bool
                % and [off/on] must be interpreted as strings
              if strcmp(thisOptionDefault, '0') || strcmp(thisOptionDefault, '1') 
                  propType = 'slbool';
                  thisOptionDefault = str2double(thisOptionDefault);
              elseif strcmpi(thisOptionDefault, 'false') || strcmpi(thisOptionDefault, 'true')
                  propType = 'slbool';
                  thisOptionDefault = strcmpi(thisOptionDefault, 'true');
              elseif ~isempty(sscanf(thisOptionDefault, 'int32(%d)'))
                  propType = 'int32';
                  thisOptionDefault = sscanf(thisOptionDefault, 'int32(%d)');
              elseif isempty(thisOptionDefault)
                  propType = 'string';
                  thisOptionDefault = '';
              else
                  isInt = ~isempty(regexp(thisOptionDefault, '^[+-]?\d+$','once'));
                  if isInt
                      propType = 'int32';
                      thisOptionDefault = str2double(thisOptionDefault);
                  else
                      propType = 'string';
                      % thisOptionDefault remains unchanged
                  end
              end
              
            case 'Category'
              categoryIndex = categoryIndex + 1;
              index = 0;
              continue;
              
            case 'Pushbutton'
              if supportCB
                  uiType = 'pushbutton';
                  uiName = thisOptionPrompt;
              else
                  continue;
              end
            otherwise
              MSLDiagnostic('RTW:utility:UnsupportedRTWOptionType', thisOptionType).reportAsWarning;
              continue;
          end
          
          % make sure that what we declare UI only has been registered/used by
          % base target
          if ~isempty(propType) && thisUIOnly && ~isempty(thisOptionName) && ...
                  ~hObj.hasProp(thisOptionName)
              assertMsg = ['Internal error: ',thisOptionName,' has been removed from ', ...
                           ' base target definition.'];
              assert(false,assertMsg);
          end
          
          % Create property      
          if ~isempty(propType) && ~thisUIOnly && ~isempty(thisOptionName)
              if hObj.hasProp(thisOptionName)
                  if hObj.getPropOwner(thisOptionName) == hObj
                      MSLDiagnostic('RTW:buildProcess:duplicateOption',...
                                       thisOptionName, gensettings.SystemTargetFile).reportAsWarning;
                      continue;
                  else
                      if supportCB
                          MSLDiagnostic('RTW:buildProcess:baseOptionConflict',...
                                           thisOptionName, ...
                                           gensettings.SystemTargetFile).reportAsWarning;
                      else
                          MSLDiagnostic('RTW:buildProcess:reservedNameOptionConflict',...
                                           thisOptionName, ...
                                           gensettings.SystemTargetFile).reportAsWarning;
                      end
                      continue;
                  end
              end
              hThisProp = schema.prop(hObj, thisOptionName, propType);
              hObj.registerPropList('UseParent', 'Only', thisOptionName);
              % cache property handles in a props handle vector
              if isempty(props)
                  props = hThisProp;
              else
                  props = [props hThisProp]; %#ok<AGROW>
              end
              
              % setup tlc option string
              if ~isempty(thisOptionName)
                  if ~isempty(tlcoption)
                      tlcoption = [tlcoption ' ']; %#ok<AGROW>
                  end
                  tlcoption = [tlcoption '-a' thisOptionName '=']; %#ok<AGROW>
                  switch propType
                    case {'slbool', 'int32'}
                      valrep = ['/' thisOptionName '/'];
                    case 'string'
                      valrep = ['"/' thisOptionName '/"'];
                    otherwise
                      % enum type
                      if (isfield(thisOption, 'value') && ~isempty(thisOption.value))
                          valrep = ['/' thisOptionName '/'];
                      else
                          valrep = ['"/' thisOptionName '/"'];
                      end
                  end
                  tlcoption = [tlcoption valrep]; %#ok<AGROW>
              end
              
              % setup the make option string
              if ~isempty(thisOptionMakeVar)
                  if ~isempty(makeoption)
                      makeoption = [makeoption ' ']; %#ok<AGROW>
                  end
                  makeoption = [makeoption thisOptionMakeVar '=']; %#ok<AGROW>
                  switch propType
                    case {'slbool', 'int32'}
                      valrep = ['/' thisOptionName '/'];
                    case 'string'
                      valrep = ['"/' thisOptionName '/"'];
                    otherwise
                      % this is enum type
                      if (isfield(thisOption, 'value') && ~isempty(thisOption.value))
                          valrep = ['/' thisOptionName '/'];
                      else
                          valrep = ['"/' thisOptionName '/"'];
                      end
                  end
                  makeoption = [makeoption valrep]; %#ok<AGROW>
              end
              
              % setup get and set function if any
              if (isfield(thisOption, 'setfunction') && ~isempty(thisOption.setfunction))
                  if isempty(setFunctions)
                      setFunctions.prop = thisOptionName;
                      setFunctions.fcn  = thisOption.setfunction;
                  else
                      setFunctions(end+1).prop = thisOptionName; %#ok<AGROW>
                      setFunctions(end).fcn    = thisOption.setfunction;
                  end
              end
              if (isfield(thisOption, 'getfunction') && ~isempty(thisOption.getfunction))
                  if isempty(getFunctions)
                      getFunctions.prop = thisOptionName;
                      getFunctions.fcn  = thisOption.getfunction;
                  else
                      getFunctions(end+1).prop = thisOptionName; %#ok<AGROW>
                      getFunctions(end).fcn    = thisOption.getfunction;
                  end
              end
          end
          
          % Set up ui item
          if ~isempty(uiType)
              widget = [];
              widget.Name = uiName;
              widget.Type = uiType;
              if ~isempty(uiObjectProperty)
                  widget.ObjectProperty = uiObjectProperty;
                  widgetID = widget.ObjectProperty;
              else
                  widgetID_index = widgetID_index + 1;
                  widgetID = sprintf('%s%d', uiType, widgetID_index);
              end
              if thisUIOnly && ~isempty(hObj.Components)
                  % redirect the source of this ui to its parent since there will be
                  % where get_param and set_param get value from
                  propOwner = hObj.Components(1).getPropOwner(uiObjectProperty);
                  if ~isempty(propOwner)
                      widget.Source = propOwner;
                  else
                      widget.Source = hObj.Components(1);
                  end
              end
              if ~isempty(uiEntries)
                  widget.Entries        = uiEntries;
                  widget.UserData.RealEntries = uiEntries;
              end
              if ~isempty(uiValues)
                  widget.Values         = uiValues;
              end
              widget.ToolTip        = thisOptionTooltip;
              widget.Mode = 1;
              if ~isempty(thisOptionCallback)
                  widget.MatlabMethod = 'slprivate';
                  widget.DialogRefresh = 1;
                  if strcmp(uiType, 'pushbutton')
                      widget.MatlabArgs = {'stfTargetDlgCallback', '%source', ...
                                          '%dialog', '', '', thisOptionCallback, uiName, uiType};
                  else
                      widget.MatlabArgs   = {'stfTargetDlgCallback', '%source', ...
                                          '%dialog', widgetID, ...
                                          '%value', thisOptionCallback, uiName, uiType};
                  end
              end
              index = index + 1;
              widget.RowSpan = [index index];        
              widget.Tag = [tag widgetID];
          end
          
          % set up default value
          if isempty(thisOptionDefault)
              % No default specified
          elseif hObj.hasProp(thisOptionName)
              currentVal = get_param(hObj, thisOptionName);
              if (isnumeric(currentVal) && ischar(thisOptionDefault))
                  set_param(hObj, thisOptionName, str2num(thisOptionDefault)); %#ok<ST2NM>
              else
                  set_param(hObj, thisOptionName, thisOptionDefault);
              end
          end

          % set up enable status
          if (~isempty(thisOptionEnable) &&...
              strcmp(thisOptionEnable, 'off') && ...
              hObj.hasProp(thisOptionName))
              setPropEnabled(hObj, thisOptionName, 0);
          end

          % set up model reference parameter check
          if ~isempty(thisOptionModelReferenceParameterCheck)
              modelReferenceParameterCheck(end + 1).parameter = thisOptionName; %#ok<AGROW>
              modelReferenceParameterCheck(end).check = thisOptionModelReferenceParameterCheck;
          end 
      end % if ~isempty(thisOptionType)
  end % for i = 1:length(rtwoptions)
  
  if hasCallback && ~supportCB
      MSLDiagnostic('RTW:utility:obsoleteSTFCallback',...
                       gensettings.SystemTargetFile).reportAsWarning;
  end

  hObj.EnumDefinition = enumReg;
  hObj.MakeOptionString = makeoption;
  hObj.TLCOptionString = tlcoption;
  hObj.SetFunction = setFunctions;
  hObj.GetFunction = getFunctions;
  hObj.ModelReferenceParameterCheck = modelReferenceParameterCheck;
  
  % setup preset listener
  coder.internal.stfTargetSetListener(hObj, props);
  
function loc_AddParentTarget(hTarget, hParentTarget)
  
  % Keep the old values for the following options:
  % SystemTargetFile
  oldSTFName = hTarget.SystemTargetFile;
  hTarget.assignFrom(hParentTarget, true);
  hTarget.SystemTargetFile = oldSTFName;
  attachComponent(hTarget, hParentTarget);
    
  % Set the target to be ERT derived if parent target is
  if isequal(get_param(hParentTarget, 'IsERTTarget'), 'on')
    hTarget.IsERTTarget = 'on';
  end
    
  % ModelReferenceCompliant is off by default
  set_param(hTarget, 'ModelReferenceCompliant', 'off');
  set_param(hTarget, 'CompOptLevelCompliant', 'off');
  set_param(hTarget, 'ParMdlRefBuildCompliant', 'off');
  set_param(hTarget, 'ERTFirstTimeCompliant', 'off');
  set_param(hTarget, 'ModelStepFunctionPrototypeControlCompliant', 'off');
  set_param(hTarget, 'CPPClassGenCompliant', 'off');
  set_param(hTarget, 'AutosarCompliant', 'off');
  set_param(hTarget, 'ConcurrentExecutionCompliant', 'off');

function version = loc_GetVersionID(version)
    version = strrep(version, '.', '_');
% EOF

% LocalWords:  rtwoptions rtwoption Downcase Flts Dbls opencallback
% LocalWords:  closecallback Hdr slbool setfunction getfunction
