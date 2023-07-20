function libData=getLibInfo(cellBlocks)






    linkStatus=get_param(cellBlocks,'StaticLinkStatus');
    idx1=strcmp(linkStatus,'none');
    cellBlocks(idx1)=[];

    if isempty(cellBlocks)
        libData=struct('Block',{},...
        'Library',{},...
        'ReferenceBlock',{},...
        'LinkStatus',{},...
        'FromLibrary',{});
        return;
    end


    linkStatus(idx1)=[];
    if~iscell(linkStatus)
        linkStatus={linkStatus};
    end

    if isnumeric(cellBlocks)
        cellBlocks=num2cell(cellBlocks);

    elseif~iscell(cellBlocks)
        cellBlocks=cellstr(cellBlocks);
    end


    cellBlocks=cellBlocks(:);
    referenceBlocks=cell(size(cellBlocks));
    fromLibrary=num2cell(false(size(cellBlocks)));
    newCellBlock2LinkStatusMap=containers.Map('KeyType','char','ValueType','any');

    for iter=1:numel(cellBlocks)
        blk=cellBlocks{iter};

        [refBlk,refLinkStatus]=i_getReferenceBlockAndItsStatus(blk);
        switch refLinkStatus
        case 'none'


            referenceBlocks{iter}=refBlk;
        case 'inactive'









            referenceBlocks{iter}=refBlk;
            linkStatus{iter}='inactive';
        case 'implicit'






            while(~strcmp(refLinkStatus,'none'))
                [refBlk,refLinkStatus]=i_getReferenceBlockAndItsStatus(refBlk);
            end
            referenceBlocks{iter}=refBlk;
        case 'resolved'
            referenceBlocks{iter}=refBlk;


            while~newCellBlock2LinkStatusMap.isKey(refBlk)&&~strcmp(refLinkStatus,'none')
                newCellBlock=refBlk;
                newCellLinkStatus=refLinkStatus;
                if~strcmp(refLinkStatus,'inactive')







                    [refBlk,refLinkStatus]=i_getReferenceBlockAndItsStatus(refBlk);
                else




                    [refBlk,~]=i_getReferenceBlockAndItsStatus(refBlk);
                    refLinkStatus='none';
                end
                newCellBlock2LinkStatusMap(newCellBlock)={refBlk,newCellLinkStatus};
            end
        end
    end

    [newRefBlocks,newCellsLinkStatus]=cellfun(@(x)x{:},newCellBlock2LinkStatusMap.values,'UniformOutput',false);
    cellBlocks=[cellBlocks;newCellBlock2LinkStatusMap.keys'];
    referenceBlocks=[referenceBlocks;newRefBlocks(:)];
    linkStatus=[linkStatus;newCellsLinkStatus(:)];
    fromLibrary=[fromLibrary;num2cell(true(size(newRefBlocks(:))))];


    library=strtok(referenceBlocks,'/');

    libData=struct('Block',cellBlocks,...
    'Library',library,...
    'ReferenceBlock',referenceBlocks,...
    'LinkStatus',linkStatus,...
    'FromLibrary',fromLibrary);
end


function[refBlk,refLinkStatus]=i_getReferenceBlockAndItsStatus(blk)
    refLinkStatus='none';


    refBlk=replaceCarriageReturnWithSpace(get_param(blk,'ReferenceBlock'));
    ancestorBlock=replaceCarriageReturnWithSpace(get_param(blk,'AncestorBlock'));

    if~isempty(refBlk)
        origLibName=getRootBDNameFromPath(refBlk);
        [origLibFile,isLibUnderMROOT]=Simulink.variant.utils.resolveBDFile(origLibName);
        if~isLibUnderMROOT
            if~bdIsLoaded(origLibName)






                withCallbacks=true;
                Simulink.variant.reducer.utils.loadSystem(origLibFile,withCallbacks);
            end
            refLinkStatus=get_param(refBlk,'StaticLinkStatus');
        end
    end

    if~isempty(ancestorBlock)




        refBlk=ancestorBlock;
        refLinkStatus='inactive';
    end
end


function blkPath=replaceCarriageReturnWithSpace(blkPath)
    blkPath=strrep(blkPath,newline,' ');
end


function modelName=getRootBDNameFromPath(path)
    [modelName,~]=strtok(path,'/');
end


