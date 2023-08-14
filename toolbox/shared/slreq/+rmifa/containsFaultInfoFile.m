function yesno=containsFaultInfoFile(obj)
    yesno=isa(obj,'char')&&contains(obj,[faultinfo.manager.faultInfoFileNameExtension(),'|']);
end