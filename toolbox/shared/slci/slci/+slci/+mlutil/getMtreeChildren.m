



function[validNode,mtreeChildren]=getMtreeChildren(thisNode)

    assert(isa(thisNode,'mtree'),'Input must be an mtree node');

    validNode=true;
    mtreeChildren={};

    switch thisNode.kind

    case{'EXPR','PRINT','GLOBAL','PERSISTENT','ATTRIBUTES','QUEST',...
        'TRANS','DOTTRANS','NOT','UMINUS','UPLUS','PARENS',...
        'BLKCOM','LB','LC','ROW','IF'}


        if~isempty(thisNode.Arg)
            mtreeChildren=slci.mlutil.getListNodes(thisNode.Arg);
        end

    case{'CALL','DCALL','SUBSCR','CELL','ATTR','EVENT','LP'}




        if~isempty(thisNode.Left)
            mtreeChildren{end+1}=thisNode.Left;
        end




        if~isempty(thisNode.Right)


            mtreeChildren=[mtreeChildren...
            ,slci.mlutil.getListNodes(thisNode.Right)];
        end

    case{'ID','FIELD','ANONID','INT','DOUBLE','CHARVECTOR','BANG'...
        ,'BREAK','CONTINUE','RETURN','COMMENT','CELLMARK','ERR','ETC'}


        mtreeChildren={};

    case{'EQUALS','ANON'}



        if~isempty(thisNode.Left)
            mtreeChildren=slci.mlutil.getListNodes(thisNode.Left);
        end


        if~isempty(thisNode.Right)
            mtreeChildren=...
            [mtreeChildren,slci.mlutil.getListNodes(thisNode.Right)];
        end

    case{'FUNCTION','PROTO'}


        if~isempty(thisNode.Fname)
            mtreeChildren{end+1}=thisNode.Fname;
        end


        if~isempty(thisNode.Ins)
            mtreeChildren=...
            [mtreeChildren,slci.mlutil.getListNodes(thisNode.Ins)];
        end


        if~isempty(thisNode.Outs)
            mtreeChildren=...
            [mtreeChildren,slci.mlutil.getListNodes(thisNode.Outs)];
        end


        if~isempty(thisNode.Body)
            mtreeChildren=...
            [mtreeChildren,slci.mlutil.getListNodes(thisNode.Body)];
        end

    case{'FOR','PARFOR'}


        if~isempty(thisNode.Index)
            mtreeChildren{end+1}=thisNode.Index;
        end


        if~isempty(thisNode.Vector)
            mtreeChildren=...
            [mtreeChildren,slci.mlutil.getListNodes(thisNode.Vector)];
        end


        if~isempty(thisNode.Body)
            mtreeChildren=...
            [mtreeChildren,slci.mlutil.getListNodes(thisNode.Body)];
        end

    case{'IFHEAD','ELSEIF','CASE','SWITCH'}


        if~isempty(thisNode.Left)
            mtreeChildren{end+1}=thisNode.Left;
        end


        if~isempty(thisNode.Body)
            mtreeChildren=...
            [mtreeChildren,slci.mlutil.getListNodes(thisNode.Body)];
        end

    case 'AT'


        if~isempty(thisNode.Arg)
            mtreeChildren{end+1}=thisNode.Arg;
        end

    case 'DOT'


        if~isempty(thisNode.Left)
            mtreeChildren{end+1}=thisNode.Left;
        end


        if~isempty(thisNode.Right)
            mtreeChildren{end+1}=thisNode.Right;
        end

    case{'SPMD','WHILE'}



        if~isempty(thisNode.Left)
            mtreeChildren=...
            [mtreeChildren,slci.mlutil.getListNodes(thisNode.Left)];
        end



        if~isempty(thisNode.Body)
            mtreeChildren=[mtreeChildren,slci.mlutil.getListNodes(thisNode.Body)];
        end

    case 'TRY'


        if~isempty(thisNode.Try)
            mtreeChildren=slci.mlutil.getListNodes(thisNode.Try);
        end


        if~isempty(thisNode.Catch)
            mtreeChildren=...
            [mtreeChildren,slci.mlutil.getListNodes(thisNode.Catch)];
        end



        if~isempty(thisNode.CatchID)
            mtreeChildren=...
            [mtreeChildren,slci.mlutil.getListNodes(thisNode.CatchID)];
        end

    case 'CLASSDEF'


        if~isempty(thisNode.Cexpr)
            mtreeChildren=slci.mlutil.getListNodes(thisNode.Cexpr);
        end


        if~isempty(thisNode.Cattr)
            mtreeChildren=[mtreeChildren,slci.mlutil.getListNodes(thisNode.Cattr)];
        end


        if~isempty(thisNode.Body)
            mtreeChildren=...
            [mtreeChildren,slci.mlutil.getListNodes(thisNode.Body)];
        end

    case{'PROPERTIES','METHODS','ENUMERATION','EVENTS','ELSE',...
        'OTHERWISE'}






        if~isempty(thisNode.Body)
            mtreeChildren=slci.mlutil.getListNodes(thisNode.Body);
        end

    otherwise


        if(thisNode.isbop)

            if~isempty(thisNode.Left)
                mtreeChildren{end+1}=thisNode.Left;
                mtreeChildren{end+1}=thisNode.Right;
            end
        else

            validNode=false;
        end
    end

end
