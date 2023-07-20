classdef(Sealed)TempFolder<handle









    properties(Constant,Hidden)

        FolderList={
tempdir
prefdir
userpath
        }';

        Salt=char(matlab.internal.editor.RandGeneratorUtilities.RandomGenerator.randi([97,122],1,5));
    end

    properties(Hidden)
        CurrentFolder=[];
    end

    methods(Static)
        function obj=getInstance()
            import matlab.internal.editor.eval.TempFolder
            persistent instance
            mlock;
            if isempty(instance)
                instance=TempFolder();
            end
            obj=instance;
        end
    end

    methods
        function folder=get.CurrentFolder(obj)
            import matlab.internal.editor.eval.TempFolder
            if isempty(obj.CurrentFolder)
                folder=TempFolder.getFirstAvailableFolder();

                folder=builtin('_canonicalizepath',folder);
                obj.CurrentFolder=folder;
                path(TempFolder.createNewPath(folder));
                message.publish('/embeddedoutputs/editor/tempfolderreset',folder);
                matlab.internal.language.ExcludedPathStore.getInstance.setExcludedPathEntry(folder);
            end

            folder=obj.CurrentFolder;
        end

        function folder=getFolderOnPath(obj)
            folder=obj.CurrentFolder;
        end

        function reset(obj)
            obj.CurrentFolder=[];
        end
    end

    methods(Access=private)
        function obj=TempFolder()
        end
    end

    methods(Static,Hidden)
        function pathToUse=getFirstAvailableFolder()
            import matlab.internal.editor.eval.TempFolder

            for testDirectory=TempFolder.FolderList
                [isValidFolder,pathToUse]=TempFolder.validateFolder(testDirectory);
                if isValidFolder
                    return;
                end
            end

            pathToUse=[];
        end

        function[isValidFolder,folderToUse]=validateFolder(folder)

            import matlab.internal.editor.eval.TempFolder;
            folderToUse=[];
            isValidFolder=false;


            if contains(folder,';')
                return;
            end
            try
                [status,~,~]=mkdir(folder{1},['Editor_',TempFolder.Salt]);
                if status~=1
                    return
                end

                fullPath=fullfile(folder{1},['Editor_',TempFolder.Salt]);
                testFile=fullfile(fullPath,'testFile');
                fid=fopen(testFile,'w');
                fprintf(fid,'testValue');
                status=fclose(fid);
                if status~=0
                    return
                end

                if exist(testFile,'file')==2

                    builtin('delete',testFile);
                end

                isValidFolder=true;
                folderToUse=fullPath;


                if isunix
                    [~,~,~]=fileattrib(fullPath,'-w','o');
                end
            catch
                return;
            end
        end

        function[firstHalf,secondHalf]=getPathPieces(thePath)







            ps=pathsep;
            if thePath(end)~=ps
                thePath=[thePath,ps];
            end




            DelimitedByAndIncludingSep=['(.[^',ps,']*',ps,'?)'];
            all_path_lines=regexp(thePath,DelimitedByAndIncludingSep,'tokens');
            all_path_lines=[all_path_lines{:}]';

            for idx=1:numel(all_path_lines)
                if strfind(all_path_lines{idx},matlabroot)
                    break;
                end
            end

            firstHalf=[all_path_lines{1:idx-1}];
            secondHalf=[all_path_lines{idx:end}];
        end

        function newPath=createNewPath(folder)



            import matlab.internal.editor.eval.TempFolder
            folder=[folder,pathsep];
            [first,second]=TempFolder.getPathPieces(matlabpath);

            newPath=[first,folder,second];
        end
    end
end

