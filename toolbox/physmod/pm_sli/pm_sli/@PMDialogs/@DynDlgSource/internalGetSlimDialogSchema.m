function schema=internalGetSlimDialogSchema(~,~)





    schema=[];
    error('PMDialogs:DynDlgSource:getSlimDialogSchema',['This method must'...
    ,' not be called from the base class.  Only the subclass''s overriden'...
    ,' version can be invoked']);

end
