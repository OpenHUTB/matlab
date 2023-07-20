function addExtraRtlFileList=addTargetcodegenDependentFiles(this,codegendir,allSrcFileList)



    addExtraRtlFileList=[];


    hfpLib=this.getParameter('FloatingPointTargetConfiguration');
    synthTool=this.getParameter('SynthesisTool');



    if~isempty(hfpLib)&&strcmpi(synthTool,'Intel Quartus Pro')
        if strcmpi(hfpLib.Library,'ALTERAFPFUNCTIONS')
            dependentRtlFiles={};
            libraryFileList={};
            addLibDone=0;
            for k=1:numel(allSrcFileList)
                [Path1,Path2,~]=fileparts(allSrcFileList{k});
                if contains(Path2,'alterafpf_')
                    curPath=pwd;
                    d=dir(fullfile(codegendir,Path1,Path2));
                    dfolders=d([d(:).isdir]);
                    dfolders=dfolders(~ismember({dfolders(:).name},{'.','..'}));
                    relativePath=fullfile(Path1,Path2,dfolders.name);
                    cd(fullfile(codegendir,relativePath));
                    filesContents=dir(pwd);
                    fileNames={filesContents.name};

                    fileFlags=(~[filesContents.isdir]);

                    FileList=fileNames(fileFlags);

                    for index=1:length(FileList)
                        currentFile=fullfile(relativePath,char(FileList(index)));
                        [~,srcName,srcExt]=fileparts(currentFile);
                        if(strcmpi(srcExt,'.vhd')&&contains(srcName,'alterafpf_'))
                            dependentRtlFiles{end+1}=currentFile;
                        end

                        if contains(srcName,'dspba_')&&isempty(libraryFileList)
                            libraryFileList{end+1}=currentFile;
                        elseif contains(srcName,'dspba_')&&~addLibDone
                            libraryFileList{end+1}=currentFile;
                            addLibDone=1;
                        end

                        if strcmpi(srcExt,'.hex')
                            copyfile([srcName,srcExt],fullfile(curPath,'hdlsrc',this.ModelName));
                        end
                    end
                    cd(curPath);
                end
            end

            libraryFileList=flip(libraryFileList);

            addExtraRtlFileList=[libraryFileList,dependentRtlFiles];

        end
    end

end


