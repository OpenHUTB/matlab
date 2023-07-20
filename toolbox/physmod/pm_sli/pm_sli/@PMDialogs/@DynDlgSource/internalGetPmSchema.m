function pm_schema=internalGetPmSchema(~,~,~)






    pm_schema=[];
    error('PMDialogs:DynDlgSource:internalGetPmSchema',['This method must'...
    ,' not be called from the base class.  Only the subclass''s overriden'...
    ,' version can be invoked']);

end
