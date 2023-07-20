classdef F2FMTree<mtree
    properties(Constant)
        UNKNOWN=-2;
        UNDEF=-1;
        DOUBLE=0;
        CHAR=1;
        INT=2;
        ENUM=3;
        BOOLEAN=4;
        FIXPT=5;
        STRUCT=6;
    end

    methods(Hidden)












    end
    methods(Access=public)
        function val=getTag(this)
            val=this.tag;
        end
        function val=setTag(this,val)
            this.tag=val;
        end
        function res=isDOUBLE(S)
            res=~isempty(S.tag)&&(S.tag==S.DOUBLE);
        end

        function res=isCHAR(S)
            res=~isempty(S.tag)&&(S.tag==S.CHAR);
        end

        function res=isINT(S)
            res=~isempty(S.tag)&&(S.tag==S.INT);
        end

        function res=isENUM(S)
            res=~isempty(S.tag)&&(S.tag==S.ENUM);
        end

        function res=isBOOLEAN(S)
            res=~isempty(S.tag)&&(S.tag==S.BOOLEAN);
        end

        function res=isFIXPT(S)
            res=~isempty(S.tag)&&(S.tag==S.FIXPT);
        end

        function o=F2FMTree(text,varargin)
            o@mtree(text,varargin{:});
        end


        function[ind,sameLine]=getOriginalIndentString(node)
            ind='';
            sameLine=false;
            if~isempty(node)&&count(node)==1
                leftpos=node.lefttreepos;
                text=node.root.str;
                ch=leftpos-1;
                while ch>=1
                    if isspace(text(ch))
                        if text(ch)==char(10)




                            ind=text(ch+1:leftpos-1);
                            return;
                        else
                            ch=ch-1;
                        end
                    else



                        sameLine=true;
                        return;
                    end
                end
            end
        end

        function s=tree2str(o,varargin)
            s=smart_tree2str(o,varargin{:});

















        end

        function output_str=smart_tree2str(o,indent,onlySubtree,replacements)
            if nargin<4
                replacements={};
            end
            if nargin<3

                onlySubtree=true;
            end

            indent=0;

            if iswhole(o)
                o=o.root;
                onlySubtree=false;
                if isempty(o.Next)
                    onlySubtree=true;
                end
            end

            [startPos,endPos]=smart_tree2str_compute_pos(o,onlySubtree);
            textReplacements=convert_node_replacements_to_char_replacements(o,replacements,startPos,endPos);
            output_str=smart_tree2str_core(o,startPos,endPos,textReplacements);


            if count(o)==1&&onlySubtree&&strcmp(o.kind,'FUNCTION')
                fcnNode=o;

                nodeStartPos=fcnNode.lefttreepos;
                fcnOffset=nodeStartPos-startPos+1;
                replacementProvidedForEntireFunction=~isempty(textReplacements{fcnOffset});




                if~replacementProvidedForEntireFunction
                    stmt=fcnNode.Body;
                    addEnd=false;
                    if isempty(stmt)

                        addEnd=~strcmp(output_str(end-2:end),'end');
                    else
                        while~isempty(stmt)
                            lastStmt=stmt;
                            stmt=stmt.Next;
                        end
                        if lastStmt.righttreepos==fcnNode.righttreepos



                            addEnd=true;
                        end
                    end

                    if addEnd
                        indentStr=o.getOriginalIndentString();
                        output_str=[output_str,char(10),indentStr,'end'];
                    end
                end
            end
        end
    end

    methods(Access=private)
        function textReplacements=convert_node_replacements_to_char_replacements(o,replacements,startPos,endPos)
            textReplacements=cell(1,length(o.str));
            o_subtree=subtree(o);
            for ii=1:2:length(replacements)
                node=replacements{ii};
                if isempty(node)
                    continue;
                end






                if~(node<=o_subtree)
                    continue;
                end
                repStr=replacements{ii+1};
                nodeStartPos=node.lefttreepos;
                nodeEndPos=node.righttreepos;
                if nodeStartPos>=startPos&&nodeStartPos<=endPos
                    offset=nodeStartPos-startPos+1;
                    len=nodeEndPos-nodeStartPos+1;
                    if isempty(textReplacements{offset})
                        textReplacements{offset}={len,repStr,node,subtree(node)};
                    else








                        existingRep=textReplacements{offset};




                        if node==existingRep{3}||~(node<=existingRep{4})











                            textReplacements{offset}={len,repStr,node,subtree(node)};
                        end
                    end
                end
            end
        end

        function[startPos,endPos]=smart_tree2str_compute_pos(o,onlySubtree)
            nodeIdx=indices(o);
            startNode=o.select(nodeIdx(1));
            endNode=o.select(nodeIdx(end));
            startPos=startNode.lefttreepos;
            endPos=endNode.righttreepos;

            if~onlySubtree

                while~isempty(endNode)
                    endPos=endNode.righttreepos;
                    endNode=endNode.Next;
                end
            end
        end

        function output_str=smart_tree2str_core(o,startPos,endPos,textReplacements)

            size=0;
            ch=startPos;
            while ch<=endPos
                offset=ch-startPos+1;
                if~isempty(textReplacements{offset})
                    rep=textReplacements{offset};
                    size=size+length(rep{2});
                    ch=ch+rep{1};
                else
                    size=size+1;
                    ch=ch+1;
                end
            end
            output_str=repmat('?',1,size);


            idx=1;
            ch=startPos;
            while ch<=endPos
                offset=ch-startPos+1;
                if~isempty(textReplacements{offset})
                    rep=textReplacements{offset};
                    repStr=rep{2};
                    endIdx=idx+length(repStr)-1;
                    output_str(idx:endIdx)=repStr;
                    ch=ch+rep{1};
                    idx=endIdx+1;
                else
                    output_str(idx)=o.str(ch);
                    ch=ch+1;
                    idx=idx+1;
                end
            end
        end
    end

end