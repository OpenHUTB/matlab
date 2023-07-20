function[flag,blkname,paraname]=hasCallBackFcn(allFnames)
    flag=false;
    blkname='';
    paraname='';
    callbackfcnName={'ClipboardFcn';'CloseFcn';'ContinueFcn';'CopyFcn';...
    'DeleteFcn';'DestroyFcn';'InitFcn';'LoadFcn';'ModelCloseFcn';'MoveFcn';...
    'NameChangeFcn';'OpenFcn';'ParentCloseFcn';'PostSaveFcn';'PauseFcn';'PreCopyFcn';...
    'PreDeleteFcn';'PreSaveFcn';'StopFcn';'StartFcn';'UndoDeleteFcn'};
    extraSysCallbackfcnName='DeleteChildFcn';



    t=zeros(1,length(allFnames));
    for i=1:length(allFnames)
        if~strcmp(get_param(allFnames{i},'Type'),'block_diagram')&&(strcmp(get_param(allFnames{i},'LinkStatus'),'resolved')||strcmp(get_param(allFnames{i},'LinkStatus'),'implicit'))
            t(i)=1;
        end
    end
    allFnames(find(t,1))=[];

    for i=1:length(callbackfcnName)
        v=get_param(allFnames,callbackfcnName{i});
        indx=find(cellfun('isempty',v)==0,1);
        if~isempty(indx)
            blkname=allFnames{indx};
            paraname=callbackfcnName{i};
            flag=true;
            return;
        end

        for j=1:length(allFnames)
            if strcmp(get_param(allFnames{j},'BlockType'),'SubSystem')
                v=get_param(allFnames{j},extraSysCallbackfcnName);
                if~isempty(v)
                    blkname=allFnames{j};
                    paraname=extraSysCallbackfcnName;
                    flag=true;
                    return;
                end
            end
        end
    end


    for i=1:length(allFnames)
        if strcmp(get_param(allFnames{i},'BlockType'),'SubSystem')
            blkset=find_system(allFnames{i},'SearchDepth',1,...
            'MatchFilter',@Simulink.match.allVariants,'IncludeCommented','on',...
            'LookUnderMasks','all','FollowLinks','on');
            [flag,blkname,paraname]=slEnginePir.hasCallBackFcn(blkset(2:end));
            if flag
                return;
            end
        end
    end
end