




function mlPaths=getSearchPath()


    persistent pSep pSplitExpr pMatlabRoot pLctSlDemo pLctSlCoderDemo pFoldersToKeep
    if isempty(pSep)

        pSep=pathsep;


        pSplitExpr=['.[^',pSep,']*',pSep];


        pMatlabRoot=[matlabroot,filesep];


        pFoldersToKeep={...
        [fullfile(matlabroot,'test','polyspace','toolbox'),filesep];...
        [fullfile(matlabroot,'test','toolbox','rtw'),filesep];...
        [fullfile(matlabroot,'test','toolbox','simulink','lct'),filesep];...
        [fullfile(matlabroot,'test','toolbox','shared','codeinstrum'),filesep];...
        [fullfile(matlabroot,'test','toolbox','shared','sldv_cc'),filesep];...
        [fullfile(matlabroot,'test','toolbox','simulink'),filesep];...
        [fullfile(matlabroot,'test','toolbox','slci'),filesep];...
        [fullfile(matlabroot,'test','toolbox','slvnv'),filesep];...
        [fullfile(matlabroot,'test','toolbox','stm'),filesep];...
        [fullfile(matlabroot,'test','tools','shared','sldv_cc'),pSep];...
        [fullfile(matlabroot,'test','tools','slvnv'),pSep];...
        };


        pLctSlDemo=fileparts(which('sldemo_lct_builddemos'));
        if~isempty(pLctSlDemo)
            pLctSlDemo=[pLctSlDemo,pSep];
        end


        pLctSlCoderDemo=fileparts(which('rtwdemo_lct_builddemos'));
        if~isempty(pLctSlCoderDemo)
            pLctSlCoderDemo=[pLctSlCoderDemo,pSep];
        end
    end




    mlPaths=regexp([matlabpath,pSep],pSplitExpr,'match')';
    if~isempty(mlPaths)
        filteredPathIdx=strncmp(pMatlabRoot,mlPaths,numel(pMatlabRoot));
        if~isempty(pLctSlDemo)

            filteredPathIdx(strncmp(pLctSlDemo,mlPaths,numel(pLctSlDemo)))=0;
        end
        if~isempty(pLctSlCoderDemo)

            filteredPathIdx(strncmp(pLctSlCoderDemo,mlPaths,numel(pLctSlCoderDemo)))=0;
        end
        for ii=1:numel(pFoldersToKeep)
            filteredPathIdx(strncmp(pFoldersToKeep{ii},mlPaths,numel(pFoldersToKeep{ii})))=0;
        end
        mlPaths(filteredPathIdx)=[];
        mlPaths=strrep(mlPaths,pSep,'');
    end


