function subsArray=mtreeToSubsref(symbolName,fieldElement,exprMtree)
    subsArray=[];
    if(isempty(exprMtree))
        return;
    end
    root=exprMtree.root.Arg;

    while(~isempty(root))
        switch(root.kind)
        case 'DOT'
            subsArray(end+1).type='.';%#ok<AGROW>
            assert(strcmp(root.Right.kind,'FIELD'),'Invalid mtree field');
            subsArray(end).subs=root.Right.string;
            root=root.Left;

        case{'SUBSCR','CALL'}
            subsArray(end+1).type='()';%#ok<AGROW>
            subsArray(end).subs={};
            index=root.Right;
            if isempty(index)
                error(message('sltest:assessments:InvalidElementIndex',fieldElement,symbolName));
            end
            while true
                if~strcmp(index.kind,'INT')
                    error(message('sltest:assessments:InvalidElementIndex',fieldElement,symbolName));
                end
                subsArray(end).subs{end+1}=str2double(index.string);
                index=index.Next;
                if isempty(index)
                    break;
                end
            end
            root=root.Left;

        case 'ID'
            root=[];

        otherwise
            error(message('sltest:assessments:InvalidFieldElementExpression',fieldElement,symbolName));

        end
    end


    subsArray=flip(subsArray);
end
