function stfInitTarget(~, h)
% STFINITTARGET converting common options in system target file to the right place in 
% configuration set object

% Copyright 2002-2021 The MathWorks, Inc.
  
  if ~isa(h, 'Simulink.STFCustomTargetCC')
      DAStudio.error('RTW:configSet:unsupportedObjectType',h);
      % return;
  end
  
  showStackInfo = rtwprivate('checkForRTWTesting');
  hConfigSet = getConfigSet(h);
  
  if isempty(hConfigSet)
      MSLDiagnostic('RTW:configSet:skipTargetInit').reportAsWarning;
      return;
  end
  
  % If rtw not installed or available
  if ~(exist('rtwprivate', 'file')==2 || exist('rtwprivate', 'file')==6)
      DAStudio.error('RTW:configSet:rtwComponentUnavailable');
      % return;
  end
  
  fileName = h.SystemTargetFile;
  [rtwoptions, gensettings] = coder.internal.getSTFInfo([],...
                                         'SystemTargetFile', fileName);
 
  if isfield(gensettings, 'Version') && ischar(gensettings.Version) && ...
        str2double(gensettings.Version) >= 1
    supportCB = true;
  else
    supportCB = false;
  end

  % Update corresponding field in configuration set
  for i = 1:length(rtwoptions)
    thisOption        = rtwoptions(i);
    thisOptionName    = thisOption.tlcvariable;
    thisOptionDefault = thisOption.default;
    thisOptionEnable  = thisOption.enable;

    if ~isempty(thisOptionName) && (~isempty(thisOptionDefault) || ...
                                   ~isempty(thisOptionEnable))

      name = '';
      switch thisOptionName
       case 'RTWExpressionDepthLimit'
        name = 'ExpressionFolding';
       case 'MaxRTWIdLen'
        name = 'MaxIdLength';
       case {'RollThreshold', ...
             'InlineInvariantSignals', ...
             'BufferReuse', ...
             'EnforceIntegerDowncase', ...
             'FoldNonRolledExpr', ...
             'LocalBlockOutputs', ...
             'IncHierarchyInIds', ...
             'GenerateComments', ...
             'ForceParamTrailComments', ...
             'ShowEliminatedStatement', ...
             'IgnoreCustomStorageClasses', ...
             'IncDataTypeInIds', ...
             'PrefixModelToSubsysFcnNames', ...
             'InlinedPrmAccess', ...
             'GenerateReport', ...
             'RTWVerbose', ...
             'CombineOutputUpdateFcns', ...
             'ERTCustomFileBanners', ...
             'SuppressErrorStatus', ...
             'InsertBlockDesc', ...
             'LogVarNameModifier', ...
             'ZeroInternalMemoryAtStartup', ...
             'ZeroExternalMemoryAtStartup', ...
             'InitFltsAndDblsToZero', ...
             'GenerateSampleERTMain', ...
             'MatFileLogging', ...
             'CodeInterfacePackaging', ...
             'MultiInstanceERTCode', ...
             'PurelyIntegerCode', ...
             'GenFloatMathFcnCalls', ...
             'TargetFunctionLibrary', ...
             'CodeReplacementLibrary'}
        name = thisOptionName;
        
      end

      if hConfigSet.hasProp(name) && ~h.hasProp(name)
        if ~isempty(thisOptionDefault)          
            try
                set_param(hConfigSet, name, thisOptionDefault);
            catch exc %#ok<NASGU>
                MSLDiagnostic('RTW:configSet:invalidDefaultValForParam', name, loc_get_type_vals(hConfigSet, name),...
		'COMPONENT', 'RTW', 'CATEGORY', 'RTW:configSet:invalidDefaultValForParam').reportAsWarning;
            end
        end
        if ~isempty(thisOptionEnable) && strcmp(thisOptionEnable, 'off')
          setPropEnabled(hConfigSet, name, 0);
        end
      end
    end
  end % for i = 1:length(rtwoptions)
  
  if isfield(gensettings, 'SelectCallback') && ~isempty(gensettings.SelectCallback) && ...
        supportCB
    try
      loc_eval(h, [], gensettings.SelectCallback);
    catch recordedErr
          MSLDiagnostic('RTW:configSet:errorInSelectCallback', fileName, recordedErr.message, ...
                         stack_info_to_str(recordedErr.stack, showStackInfo), 'COMPONENT', 'RTW', 'CATEGORY', recordedErr.identifier).reportAsWarning
    end
  end
  
 
  
function loc_eval(hSrc, hDlg, evalStr) %#ok Do not remove hDlg
  model = hSrc.getModel; %#ok  Do not remove
  hConfigSet = hSrc.getConfigSet; %#ok Do not remove
  % hSrc, hDlg, model, hConfigSet are all passed into the evaluation
  eval(evalStr);

% We need to report stack info for user scripts in all cases.  However, only in debug
% mode, i.e. RTWTesting = 1, we want to show stack info into our own code
function stackInfoStr=stack_info_to_str(stackinfo, showStackInfo)  
    stackInfoStr = '';
    for i = 1:length(stackinfo)
        if ~showStackInfo && ...
                contains(stackinfo(i).file, fullfile('toolbox','rtw','rtw','stfInitTarget'))
            break;
        end
        stackInfoStr = sprintf('%s %s:%s:%d \n',stackInfoStr,stackinfo(i).file,...
                            stackinfo(i).name, stackinfo(i).line);  
    end 
%end of function   

function values = loc_get_type_vals(hCS, name)
    hOwner = hCS.getPropOwner(name);
    prop = hOwner.findprop(name);
    type = findtype(prop.DataType);
    
    if isprop(type, 'Strings') && ~isempty(t.Strings)
        values = '{';
        for i = 1:length(t.Strings)
            values = sprintf('%s"%s"',values, t.Strings{i});
            if i < length(t.Strings)
                values = [values ',']; %#ok<AGROW>
            else
                values = [values '}']; %#ok<AGROW>
            end
        end
        return;
    end
    
    switch type.Name
      case 'slbool'
        values = '{"on", "off"}';
      case 'int32'
        values = 'integer numbers';
      otherwise
        values = ['data of type "', type.Name, '"'];
    end
    
