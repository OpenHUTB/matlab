function setrtwoption(modelname,opt,val,~)
%SETRTWOPTION sets an RTWOption for a Simulink model
%   OPT=SETRTWOPTION(MODELNAME, OPT, VALUE, CREATE) sets the RTWOption OPT to VALUE for 
%   Simulink model MODELNAME. If CREATE = 1 the option is created if necessary, otherwise
%   an error is thrown if the option does note exist.
%
%   This function is now obsolete. Use set_param instead.

%   Copyright 2002-2010 The MathWorks, Inc.

TargetCommon.ProductInfo.warning('common', 'ObsoleteFunction2', mfilename);
  set_param(modelname,opt,val);
