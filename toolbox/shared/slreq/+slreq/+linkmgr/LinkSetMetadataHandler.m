classdef LinkSetMetadataHandler<handle





    methods(Static,Hidden)
        function fileList=convertJAVAFileListToFilePathList(javaFileList)
            fileList=cell(1,javaFileList.size());
            for i=0:(javaFileList.size()-1)
                fileList{i+1}=char(javaFileList.get(i).getAbsolutePath());
            end
        end

        function files=getAllProjectFiles()
            import com.mathworks.toolbox.shared.slreq.projectext.requirementsetup.LinkSetManagerExtension;
            import slreq.linkmgr.LinkSetMetadataHandler;

            try
                files=LinkSetMetadataHandler.convertJAVAFileListToFilePathList(LinkSetManagerExtension.getProjectSLMXFiles());
            catch ex %#ok<NASGU>

                files={};
            end
        end
    end
end
