classdef Utils

    properties(Constant)
        TYPE_SPECIFIER=".type.";
        META_DATA_FILE_EXTENSION=".xml";
    end

    methods(Static)
        function bool=hasProjectMetaDataExtension(file)
            import matlab.internal.project.comparisons.Utils
            [~,~,ext]=fileparts(file);
            bool=strcmpi(ext,Utils.META_DATA_FILE_EXTENSION);
        end

        function bool=hasTypeStructure(file)
            import matlab.internal.project.comparisons.Utils
            bool=contains(file,Utils.TYPE_SPECIFIER);
        end

        function bool=hasType(file,expectedType)
            import matlab.internal.project.comparisons.Utils
            [~,name]=fileparts(file);
            type=extractAfter(name,Utils.TYPE_SPECIFIER);
            bool=startsWith(type,expectedType);
        end

        function bool=isUnderProjectMetadata(file)
            bool=false;
            [underRoot,root]=matlab.internal.project.util.isUnderProjectRoot(file);
            if~underRoot
                return
            end
            relativeMetaRoots=matlab.internal.project.metadata.getSupportedRoots();
            for relativeMetaRoot=relativeMetaRoots
                metaRoot=fullfile(root,relativeMetaRoot);
                if contains(file,metaRoot)
                    bool=true;
                    return
                end
            end
        end

        function bool=isUnderComparisonsTempDir(file)
            bool=false;
            try
                tmpRoot=com.mathworks.toolbox.shared.computils.file.ComparisonsTempDirManager.getRootDir();
                tempdirStr=string(tmpRoot.getCanonicalFile());
                bool=contains(file,tempdirStr);
            catch
            end
        end
    end

end
