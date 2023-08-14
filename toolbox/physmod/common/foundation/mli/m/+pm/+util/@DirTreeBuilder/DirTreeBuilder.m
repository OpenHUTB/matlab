classdef DirTreeBuilder<handle







    properties(SetAccess=private)
CompoundBuilder
SimpleBuilder
    end

    methods
        function treeBldr=DirTreeBuilder(compBuilder,simpleBuilder)
            treeBldr.CompoundBuilder=compBuilder;
            treeBldr.SimpleBuilder=simpleBuilder;
        end

        function set.CompoundBuilder(thisBldr,compBuilder)



            if isa(compBuilder,'pm.util.CompoundNodeBuilder')
                thisBldr.CompoundBuilder=compBuilder;
            else
                pm_error('physmod:common:foundation:mli:util:dirtreebuilder:InvalidCompoundBuilder');
            end
        end

        function set.SimpleBuilder(thisBldr,simpleBuilder)



            if isa(simpleBuilder,'pm.util.SimpleNodeBuilder')
                thisBldr.SimpleBuilder=simpleBuilder;
            else
                pm_error('physmod:common:foundation:mli:util:dirtreebuilder:InvalidSimpleBuilder');
            end
        end

        function rootNode=buildTree(thisBldr,rootDir)






            if ischar(rootDir)&&exist(rootDir,'dir')
                dirContents=dir(rootDir);
                cIdx=strcmp({dirContents.name},'.');
                dirContents(cIdx)=[];
            else
                pm_error('physmod:common:foundation:mli:util:dirtreebuilder:InvalidDirInfo');
            end
            dirContents(strcmp({dirContents.name},'..'))=[];





            rootNode=thisBldr.CompoundBuilder.getObject(rootDir);

            if isempty(rootNode)



                return;
            end



            dirIdx=[dirContents.isdir];
            dirs=dirContents(dirIdx);
            files=dirContents(~dirIdx);

            for idx=1:length(dirs)



                dirInfo=dirs(idx);
                compoundChild=thisBldr.buildTree(fullfile(rootDir,dirInfo.name));
                if~isempty(compoundChild)
                    rootNode.addChild(compoundChild);
                end
            end

            for idx=1:length(files)



                fileInfo=files(idx);
                simpleChild=thisBldr.SimpleBuilder.getObject(fullfile(rootDir,fileInfo.name));
                if~isempty(simpleChild)
                    rootNode.addChild(simpleChild);
                end
            end
        end
    end
end
