function s=getUniqueID(obj)
    obj.TableID=obj.TableID+1;
    s=num2str(obj.TableID);
end
