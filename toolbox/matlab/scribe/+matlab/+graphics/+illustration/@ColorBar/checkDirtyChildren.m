function r=checkDirtyChildren(obj,child)









    if~isempty(obj.Parent)...
        &&isa(obj.Parent,'matlab.graphics.layout.Layout')...
        &&~isempty(obj.Ruler)...
        &&~isempty(obj.Ruler.Label_I)...
        &&isequal(child.Parent,obj.Ruler.Label_I)
        r=true;
    else
        r=false;
    end

end