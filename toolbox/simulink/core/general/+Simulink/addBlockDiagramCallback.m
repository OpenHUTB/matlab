function addBlockDiagramCallback(bd,type,id,fcn,replace)























    obj=get_param(bd,'Object');
    if nargin>4&&replace
        if obj.hasCallback(type,id)
            obj.removeCallback(type,id);
        end
    end
    obj.addCallback(type,id,fcn);

end
