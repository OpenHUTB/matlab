function populateDropdown(dlgSrc)
    [~,dlgSrc.instanceModelName,ext]=fileparts(dlgSrc.instanceFileName);
    dlgSrc.cutMap=containers.Map;
    if exist(dlgSrc.instanceFileName,'file')&&...
        (strcmp(ext,'.slx')||strcmp(ext,'.mdl'))
        try
            bd=find_system('type','block_diagram','Name',dlgSrc.instanceModelName);
            if isempty(bd)
                load_system(dlgSrc.instanceFileName);
            end
            blockList=getBlockList(dlgSrc);
            blkNames=cell(length(blockList),1);
            for i=1:length(blockList)
                blkNames{i}=strrep(blockList{i},[dlgSrc.instanceModelName,'/'],'');
            end
            blkNamesNoNL=strrep(blkNames,sprintf('\n'),' ');%#ok
            dlgSrc.cutCandidates=blkNamesNoNL;
            for i=1:length(blkNames)
                dlgSrc.cutMap(dlgSrc.cutCandidates{i})=blockList{i};
            end
            if numel(blkNames)>0
                dlgSrc.cutName=dlgSrc.cutCandidates{1};
            end
        catch

        end
    else
        dlgSrc.cutMap=containers.Map;
        dlgSrc.cutCandidates={};
        dlgSrc.cutName='';
    end

end

function blkNames=getBlockList(dlgSrc)
    [~,modelName,~]=fileparts(dlgSrc.instanceFileName);


    blkNames=find_system(modelName,...
    'BlockType','SubSystem','LinkStatus','resolved',...
    'TreatAsAtomicUnit','on',...
    'RTWSystemCode','Reusable function',...
    'ReferenceBlock',getfullname(dlgSrc.ownerH));

end
