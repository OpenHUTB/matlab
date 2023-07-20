
function destBlks=getDestsForEvent(sfBlock,ast,destBlks)



    if isa(ast,'slci.ast.SFAstExplicitEvent')
        portNum=ast.getPortNum();

        if portNum>=0
            dest=slci.internal.getActualDst(get_param(sfBlock,'Handle'),...
            portNum);
            for k=1:size(dest,1)
                destBlk=dest(k,1);
                destBlks{end+1}=slci.results.getKeyFromBlockHandle(destBlk);%#ok
            end
        end
    else
        ch=ast.getChildren();
        for k=1:numel(ch)
            destBlks=slci.results.getDestsForEvent(sfBlock,ch{k},destBlks);
        end
    end
end
