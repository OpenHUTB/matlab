function propValue=dfs_propagate(items,parentIdx,startvalue,preFcn,postFcn,initPropValue)





    if nargin<6
        propValue=[];
    else
        propValue=initPropValue;
    end



    ancestors=1;
    depth=1;
    children={[]};


    itemIdx=2;
    prevIdx=[];
    lastItem=length(items);

    while(itemIdx<=lastItem)

        if(parentIdx(itemIdx)~=ancestors(end))
            lastAncestorIdx=find(ancestors==parentIdx(itemIdx));
            if isempty(lastAncestorIdx)

                ancestors=[ancestors,parentIdx(itemIdx)];%#ok<*AGROW>
                depth=depth+1;
                children=[children,{[]}];
            else

                ancestorL=length(ancestors);




                if~isempty(postFcn)

                    [values,ind]=feval(postFcn,prevIdx,[],items,parentIdx,startvalue,propValue);
                    propValue(ind)=values;


                    for ppDepth=ancestorL:-1:(lastAncestorIdx+1)
                        ppIdx=ancestors(ppDepth);
                        childIdx=children{ppDepth};
                        [values,ind]=feval(postFcn,ppIdx,childIdx,items,parentIdx,startvalue,propValue);
                        propValue(ind)=values;
                    end
                end

                ancestors=ancestors(1:lastAncestorIdx);
                depth=lastAncestorIdx;
                children=children(1:lastAncestorIdx);
            end
        else
            if~isempty(postFcn)&&~isempty(prevIdx)
                [values,ind]=feval(postFcn,prevIdx,[],items,parentIdx,startvalue,propValue);
                propValue(ind)=values;
            end
        end






        if~isempty(preFcn)
            [values,ind,cont]=feval(preFcn,itemIdx,items,parentIdx,startvalue,propValue);
            propValue(ind)=values;
        else
            cont=true;
        end



        children{end}(end+1)=itemIdx;


        prevIdx=itemIdx;


        itemIdx=itemIdx+1;
        if(~cont&&itemIdx<=lastItem)
            mxParentIdx=ancestors(end);
            while(itemIdx<=lastItem&&parentIdx(itemIdx)>mxParentIdx)
                itemIdx=itemIdx+1;
            end
        end
    end




    ancestorL=length(ancestors);
    lastAncestorIdx=0;
    if~isempty(postFcn)

        [values,ind]=feval(postFcn,prevIdx,[],items,parentIdx,startvalue,propValue);
        propValue(ind)=values;

        for ppDepth=ancestorL:-1:(lastAncestorIdx+1)
            ppIdx=ancestors(ppDepth);
            childIdx=children{ppDepth};
            [values,ind]=feval(postFcn,ppIdx,childIdx,items,parentIdx,startvalue,propValue);
            propValue(ind)=values;
        end
    end
end
