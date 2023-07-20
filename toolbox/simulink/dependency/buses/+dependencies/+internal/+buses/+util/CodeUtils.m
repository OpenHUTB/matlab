classdef(Abstract)CodeUtils




    methods(Static)
        function match=codeMatch(code,busElement)
            import dependencies.internal.buses.util.CodeUtils;
            [~,lines]=CodeUtils.searchCode(code,busElement);
            match=~isempty(lines);
        end

        function[pos,line]=search(file,field)
            tree=mtree(file,'-file');
            [pos,line]=i_searchTree(tree,field);
        end

        function[pos,line]=searchCode(code,field)
            tree=mtree(code);
            [pos,line]=i_searchTree(tree,field);
        end

        function[code,noChange]=refactorCode(code,oldElement,newElement)
            import dependencies.internal.buses.util.CodeUtils;
            pos=CodeUtils.searchCode(code,oldElement);

            noChange=isempty(pos);
            if noChange
                return;
            end

            pos=flip(unique(pos))';

            oldLength=length(oldElement);
            for p=pos
                code=[code(1:p-1),newElement,code(p+oldLength:end)];
            end
        end
    end
end


function[pos,line]=i_searchTree(tree,field)
    direct=tree.mtfind('Kind',{'ID','FIELD','CHARVECTOR','STRING'},'String',field);

    quoted=tree.mtfind('Kind','CHARVECTOR','String',['''',field,''''])...
    |tree.mtfind('Kind','STRING','String',['"',field,'"']);

    pos=[direct.position;quoted.position+1];
    line=[direct.lineno;quoted.lineno];
end
