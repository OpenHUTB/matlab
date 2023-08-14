function replaceWithLibraryLink(obj,blk,src,prms)










    if isempty(blk)
        return;
    elseif iscell(blk)
        tempblock=i_create_block(obj,blk{1},src,prms);
        for i=1:numel(blk)
            i_replace_block(obj,blk{i},tempblock,prms);
        end
    else
        tempblock=i_create_block(obj,blk,src,prms);
        i_replace_block(obj,blk,tempblock,prms);
    end
    obj.appendRule(slexportprevious.rulefactory.replaceInSourceBlock('SourceBlock',tempblock,src));

end

function tempblock=i_create_block(obj,blk,srcblk,prms)


    templib=getTempLib(obj);
    tempblock=obj.createEmptySubsystem(templib,'',get_param(blk,'Ports'));




    numparams=size(prms,1);
    x=1:numparams;
    y=[prms(:,1),num2cell(x(:))]';
    maskvars=sprintf('%s=@%d;',y{:});
    maskenables=repmat('off,',1,numparams);
    maskenables(end)=[];
    set_param(tempblock,'Mask','on','MaskVariables',maskvars,'MaskEnableString',maskenables);


    sep=find(srcblk=='/');
    sep=sep(end);
    masktype=strrep(srcblk(sep+1:end),newline,' ');
    set_param(tempblock,'MaskType',masktype);

    save_system(templib);

end

function i_replace_block(obj,blk,tempblock,prms)


    numparams=size(prms,1);
    pv=cell(numparams,1);
    for i=1:numparams
        pv{i}=get_param(blk,prms{i,2});
    end

    obj.replaceBlock(blk,tempblock);


    for i=1:size(prms,1)
        set_param(blk,prms{i,1},pv{i});
    end
end

