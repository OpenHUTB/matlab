function disp(this)


    blocks=getTags(this);
    numBlocks=length(blocks);
    if numBlocks<3
        disp('EMPTY');
    else
        for ii=3:numBlocks
            curBlock=this.getImplInfoForBlockLibPath(blocks{ii});
            if~isempty(curBlock.Block)
                fprintf('         Block: %s',...
                regexprep(curBlock.Block,newline,' '));
            else
                fprintf('         Block: []');
            end
            if~isempty(curBlock.ArchitectureName)
                fprintf('     ArchitectureName: %s',...
                regexprep(curBlock.ArchitectureName,newline,' '));
            else
                fprintf('     ArchitectureName: []');
            end
            if length(curBlock.Parameters)>1
                fprintf('    Parameters: {');
                for jj=1:length(curBlock.Parameters)
                    fprintf('                 %s',...
                    regexprep(curBlock.Parameters{jj},newline,' '));
                end
                fprintf('                }');
            elseif~isempty(curBlock.Parameters)
                fprintf('    Parameters: %s',...
                regexprep(curBlock.Parameters{1},newline,' '));
            else
                fprintf('    Parameters: []');
            end
            if~isempty(curBlock.Instance)
                fprintf('      Instance: %s',class(curBlock.Instance));
            end
            disp(' ')
        end
    end
    disp(' ');
end
