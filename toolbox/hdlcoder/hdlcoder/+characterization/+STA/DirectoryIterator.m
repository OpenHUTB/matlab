classdef DirectoryIterator<ListIterator





    properties
m_rootDir
    end

    methods
        function self=DirectoryIterator(dirPath)
            self=self@ListIterator([]);
            self.m_rootDir=dirPath;
            list=self.populate();
            self.setList(list);

        end

        function list=populate(self)

            dirContent=dir(self.m_rootDir);
            dirVect=[dirContent(:).isdir];
            filteredDirs={dirContent(dirVect).name};
            filteredDirs(ismember(filteredDirs,{'.','..'}))=[];
            list=filteredDirs;

        end

    end

end

