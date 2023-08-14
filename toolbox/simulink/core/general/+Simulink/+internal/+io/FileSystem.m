classdef(Hidden)FileSystem<handle







    methods(Static,Access=public)



        function d=dirContents(src)
            d=Simulink.internal.io.FileSystem.dirNoDots(src);
            d={d.name};
        end




        function d=dirFilenames(src)
            d=Simulink.internal.io.FileSystem.dirNoDots(src);
            d=d(~[d.isdir]);
            d={d.name};
        end




        function robustMkdir(name)
            cmd=@(d)mkdir(d);
            coder.make.internal.robustOperation(cmd,name);
        end




        function robustMove(src,dst)

            function[success,msg,msgID]=moveCmd(src,dst)
                [success,msg,msgID]=builtin('movefile',src,dst,'f');
                srcEx=exist(src,'file');
                dstEx=exist(dst,'file');
                success=success&&((srcEx~=2)&&(srcEx~=7))&&((dstEx==2)||(dstEx==7));
            end

            coder.make.internal.robustOperation(@moveCmd,src,dst);
        end




        function robustCopy(src,dst)
            cmd=@(s,d)copyfile(s,d,'f');
            coder.make.internal.robustOperation(cmd,src,dst);
        end




        function robustCopyFiles(src,dst,filenames)

            if~isempty(filenames)&&~isfolder(dst)
                Simulink.internal.io.FileSystem.robustMkdir(dst);
            end

            for i=1:length(filenames)
                srcFile=fullfile(src,filenames{i});
                dstFile=fullfile(dst,filenames{i});
                Simulink.internal.io.FileSystem.robustCopy(srcFile,dstFile);
            end
        end






        function robustCopyExcluding(src,dst,skipItems)
            import Simulink.internal.io.FileSystem;


            if~isfolder(dst)
                FileSystem.robustMkdir(dst);
            end


            if isempty(skipItems)
                copyfile(src,dst);
                return;
            end




            skipItemsUnderSrcIdx=contains(skipItems,filesep);
            skipUnderSrc=skipItems(skipItemsUnderSrcIdx);

            skipInSrc=skipItems(~skipItemsUnderSrcIdx);



            skipItemsUnderSrcRoots=extractBefore(skipUnderSrc,filesep);



            keepIdx=~ismember(skipItemsUnderSrcRoots,skipInSrc);
            skipItemsUnderSrcRoots=skipItemsUnderSrcRoots(keepIdx);
            skipUnderSrc=skipUnderSrc(keepIdx);
            skipUnderSrcRootUnique=unique(skipItemsUnderSrcRoots);



            skipInSrc=[skipInSrc,skipUnderSrcRootUnique];


            itemsToCopy=setdiff(FileSystem.dirContents(src),skipInSrc);
            for i=1:length(itemsToCopy)
                FileSystem.robustCopy(...
                fullfile(src,itemsToCopy{i}),...
                fullfile(dst,itemsToCopy{i}));
            end



            for i=1:length(skipUnderSrcRootUnique)

                rootSkipItemsIdx=startsWith(skipUnderSrc,skipUnderSrcRootUnique{i});
                rootSkipItems=skipUnderSrc(rootSkipItemsIdx);

                rootSkipItems=extractAfter(rootSkipItems,filesep);

                rootSrc=fullfile(src,skipUnderSrcRootUnique{i});
                rootDst=fullfile(dst,skipUnderSrcRootUnique{i});


                FileSystem.robustCopyExcluding(rootSrc,rootDst,rootSkipItems);
            end
        end
    end

    methods(Static,Access=private)



        function d=dirNoDots(src)
            d=dir(src);
            dot=strcmp({d.name},'.');
            doubledot=strcmp({d.name},'..');
            d=d(~dot&~doubledot);

        end
    end
end


