function CFunctionInputOutput(obj)


    if isR2020aOrEarlier(obj.ver)
        cFcnBlocks=obj.findBlocksOfType('CFunction');
        for i=1:numel(cFcnBlocks)
            hBlock=get_param(cFcnBlocks{i},'Handle');
            objSymbolSpec=get_param(hBlock,'SymbolSpec');
            scopeSet={objSymbolSpec.Symbols.Scope};


            if any(strcmp(scopeSet,'InputOutput'))
                obj.replaceWithEmptySubsystem(cFcnBlocks{i});
            end
        end
    end
