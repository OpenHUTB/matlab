function assign(this,comp,rhs,lhs)%#ok<INUSL>






    if~isempty(lhs)&&~isempty(rhs)
        if isa(rhs,'eda.internal.component.Port')

        elseif isa(rhs,'eda.internal.component.Signal')
            rhs.Dst(end+1).Node=comp;
            rhs.Dst(end).Port=lhs;
        elseif isa(rhs,'char')
            [rhsList,~]=findDst(rhs);
            for i=1:length(rhsList)
                [rhsValue,rhsType]=findDstHandle(comp,rhsList{i});
                if strcmpi(rhsType,'handle')&&~isa(rhsValue,'eda.internal.component.Port')
                    rhsValue.Dst(end+1).Node=comp;
                    rhsValue.Dst(end).Port=lhs;
                end
            end
        else
            error(message('EDALink:Edge:assign:NotSupportedRightHandSide'));
        end

        if isa(lhs,'eda.internal.component.Port')

        elseif isa(lhs,'eda.internal.component.Signal')

            if isa(rhs,'eda.internal.component.Signal')
                lhs.Src(end+1).Node=comp;
                lhs.Src(end).Port=rhs;
            elseif isa(rhs,'eda.internal.component.Port')
                lhs.Src(end+1).Node=comp;
                lhs.Src(end).Port=rhs;
            elseif isa(rhs,'char')
                [rhsList,fn]=findDst(rhs);
                lhs.Src.txfn=fn;
                lhs.Src.fnParam={};
                lhs.Src.Node={};
                lhs.Src.Port={};
                for i=1:length(rhsList)
                    [rhsValue,rhsType]=findDstHandle(comp,rhsList{i});
                    if strcmp(rhsType,'handle')
                        lhs.Src.Node{end+1}=comp;
                        lhs.Src.Port{end+1}=rhsValue;
                    else
                        lhs.Src.fnParam{end+1}=rhsValue;





                    end
                end
            end
        else
            error(message('EDALink:Edge:assign:NotSupportedRightHandSide'));
        end
    else
        error(message('EDALink:Edge:assign:NotSupportedFunctionArgument'));
    end
end

function[rhsList,fn]=findDst(rhs)
    fn='';
    fnList={'bitand','bitor','bitreplicate','bitsliceget','bitconcat','fi','zeros','padonezero'};
    rhsList={};
    fnTree=mtree(rhs);

    CALL=fnTree.mtfind('Kind','CALL');
    MUL=fnTree.mtfind('Kind','MUL');
    PLUS=fnTree.mtfind('Kind','PLUS');
    MINUS=fnTree.mtfind('Kind','MINUS');
    NOT=fnTree.mtfind('Kind','NOT');

    if~isempty(PLUS)



    elseif~isempty(MINUS)



    elseif~isempty(MUL)



    elseif~isempty(NOT)
        fn='not';
        rhsList=findSrcList(fnTree,fn);
    else
        indices=CALL.indices;
        fn=cell2mat(CALL.select(indices(1)).Left.strings);
        if~any(strcmpi(fn,fnList))
            error(message('EDALink:Edge:assign:FuncionNotSupported',fn));
        end
        rhsList=findSrcList(fnTree);
    end
end


function[rhsValue,rhsType]=findDstHandle(comp,signalName)
    rhsValue='';
    rhsType='';
    found=false;
    if~isempty(comp.findprop(signalName))
        if comp.flatten==1
            parent=comp.getParent;
            parentSignalName=comp.(signalName).signal.Name;
            [rhsValue,rhsType]=findDstHandle(parent,parentSignalName);
            found=true;%#ok<*NASGU>
            return;
        else
            rhsValue=comp.(signalName);
            rhsType='handle';
            found=true;%#ok<*NASGU>
            return;
        end
    else
        for ii=1:length(comp.ChildEdge)
            if strcmpi(comp.ChildEdge{ii}.Name,signalName)
                rhsValue=comp.ChildEdge{ii};
                rhsType='handle';
                found=true;
                return;
            end
        end
    end
    if found==false
        rhsValue=signalName;
        rhsType='param';
    end
end


function srcList=findSrcList(hTree,reserved_fn)
    srcList={};
    if nargin<2
        reserved_fn='';
    end
    for loop=hTree.indices
        if strcmpi(hTree.select(loop).kind,'CALL')
            startIdx=loop+2;
            break;
        elseif strcmpi(hTree.select(loop).kind,reserved_fn)
            startIdx=loop;
            break;
        end
    end

    for loop=startIdx:length(hTree.indices)
        if strcmpi(hTree.select(loop).kind,'DOT')
            srcList{end+1}=hTree.select(loop).Right.string;%#ok<*AGROW>
        elseif strcmpi(hTree.select(loop).kind,'CALL')
            srcList{end+1}=hTree.select(loop).Left.string;
        elseif strcmpi(hTree.select(loop).kind,'INT')
            srcList{end+1}=hTree.select(loop).string;
        end
    end

end
