classdef(Sealed)Icon









    properties(Hidden,SetAccess=private)


        ImageFile;
    end

    methods
        function obj=set.ImageFile(obj,v)
            validateattributes(v,{'char','string'},{'scalartext','nonempty'},'','ImageFile');
            if isstring(v)
                v=char(v);
            end
            obj.ImageFile=v;
        end


        function obj=Icon(imageFile)
            obj.ImageFile=imageFile;
        end
    end
end
