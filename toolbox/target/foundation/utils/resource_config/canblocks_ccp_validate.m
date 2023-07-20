function argout = canblocks_ccp_validate(block, target, instance_str)
% Resource allocation function 

%   Copyright 2002 The MathWorks, Inc.

% find a resource object
resource_obj = target.findResourceForClass('TargetsCommonConfig.CCP');
if isempty(resource_obj)
  TargetCommon.ProductInfo.error('resourceConfiguration', 'ResourceConfigurationMissingConfiguration', 'TargetsCommonConfig.CCP');
end;

% get the instance resource from the resource object
resource = resource_obj.CCP_INSTANCE;

% Manual Allocation of the instance %
instance_str_alloc = resource.manual_allocate(block, instance_str);

if isempty(instance_str_alloc)
   host = resource.get_host(instance_str);
   if ischar(host)
      hilite_system(host, 'error');
      TargetCommon.ProductInfo.error('can', 'TooManyCCPBlocks');
   else 
      % should never get here...
   end;
   open_system(block);
else
   % successful allocation
end;
      
argout = {instance_str};
