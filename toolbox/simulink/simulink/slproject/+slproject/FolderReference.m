classdef FolderReference





    properties(Dependent,GetAccess=public,SetAccess=private)

        File;

        StoredLocation;

        Type;
    end

    properties(GetAccess=protected,SetAccess=immutable)
        Delegate;
    end

    methods(Access=public,Hidden=true)
        function obj=FolderReference(delegate)
            obj.Delegate=delegate;
        end
    end

    methods
        function file=get.File(obj)
            file=char(obj.Delegate.File);
        end

        function location=get.StoredLocation(obj)
            location=char(obj.Delegate.StoredLocation);
        end

        function type=get.Type(obj)
            type=char(obj.Delegate.Type);
        end

        function sortedArray=sort(objArray)

            if numel(objArray)<2
                sortedArray=objArray;
                return
            end
            [~,index]=sort({objArray.File});
            sortedArray=objArray(index);
        end
    end

end
