function val=getrtwoption(modelname,opt)
%GETRTWOPTION gets an RTWOption for a Simulink model
%   VALUE = GETRTWOPTION(MODELNAME, OPT) returns the VALUE of the RTWOption OPT
%   for Simulink model MODELNAME.

%   Copyright 2004-2010 The MathWorks, Inc.

  TargetCommon.ProductInfo.warning('common', 'ObsoleteFunction', mfilename);

  opts = get_param(modelname,'RTWOptions');
  
  if isempty(strfind(opts,['-a' opt '=']))
    val = '';
    return
  end
  
  [s,~,t] = regexp(opts, ['-a' opt '=\"([^"]*)\"']);
  
  isNumeric=0;
  if isempty(s)
    % Numeric values are not double quoted
    [~,~,t] = regexp(opts, ['-a' opt '=(\d*)']);
    isNumeric=1;
  end
  
  t1 = t{1};
  
  if isempty(t1)
    val = '';
  else
    if isNumeric==0
      val = opts(t1(1):t1(2));
    else
      eval(['val = ' opts(t1(1):t1(2)) ';']);
    end
  end 
