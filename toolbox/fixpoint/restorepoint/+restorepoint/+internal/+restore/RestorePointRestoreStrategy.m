classdef RestorePointRestoreStrategy<restorepoint.internal.restore.RestoreStrategy




    methods(Access=protected)
        function restoreFiles(~,filesToRestore,restoreData)
            for restoreIdx=1:numel(filesToRestore)
                curRestoreInfo=filesToRestore{restoreIdx};
                currentFullFile=curRestoreInfo{1};
                reason=curRestoreInfo{2};
                if strcmpi(reason,'FileChanged')
                    rd=restoreData.getDataForFile(currentFullFile);
                    copyfile(rd.newFile,currentFullFile);
                end
            end
        end
    end
end
