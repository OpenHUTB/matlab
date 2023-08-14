classdef FolderReference






    properties(GetAccess=public,SetAccess=private)

        File;

        StoredLocation;

        Type;
    end


    methods(Access=public,Hidden=true)
        function obj=FolderReference(folderReference)
            if nargin==0||numel(folderReference)==0
                return
            end

            privateConstructorInputValidate(...
            folderReference,...
'com.mathworks.toolbox.slproject.project.references.FolderReference[]'...
            );

            import matlab.internal.project.util.*;

            obj(numel(folderReference))=obj(1);

            for idx=1:numel(folderReference)
                obj(idx).File=string(folderReference(idx).getLocation().getCanonicalPath());
                obj(idx).StoredLocation=string(folderReference(idx).getStoredPath());
                obj(idx).Type=string(folderReference(idx).getType());
            end

        end

        function sortedArray=sort(objArray)

            if numel(objArray)<2
                sortedArray=objArray;
                return
            end
            [~,index]=sort([objArray.File]);
            sortedArray=objArray(index);
        end

    end
end
