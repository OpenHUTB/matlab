function res=isSubsystemReadProtected(block)




    permissions=get_param(block.handle,'Permissions');
    res=strcmpi(permissions,'NoReadOrWrite');
end
