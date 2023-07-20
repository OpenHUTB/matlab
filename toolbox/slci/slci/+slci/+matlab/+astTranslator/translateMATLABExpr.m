




function SFAst=translateMATLABExpr(mexpr,blk)



    mexpr=regexprep(mexpr,'\s','');


    if isempty(mexpr)
        DAStudio.error('Slci:slci:mtreeEmptyExpr');
    else

        mt=mtree(mexpr);
        if strcmp(mt.root.kind,'ERR')
            DAStudio.error('Slci:slci:mtreeParseError',mexpr);
        end


        [isAstNeeded,SFAst]=slci.matlab.astTranslator.createMatlabAst(...
        mt.root,blk);
        assert(isAstNeeded&&~isempty(SFAst));
    end
end
