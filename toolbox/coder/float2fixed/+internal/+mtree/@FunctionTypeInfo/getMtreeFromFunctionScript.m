
function fcnTree=getMtreeFromFunctionScript(this,scriptText,fcnMxLocations)




    fcnTree=coder.internal.translator.F2FMTree(scriptText,'-comments');


    if~isempty(fcnMxLocations)
        mxLocations=fcnMxLocations([fcnMxLocations.TextStart]>0);
    else
        mxLocations=fcnMxLocations;
    end

    if~isempty(mxLocations)
        performLocCheck=true;
        medianTextStart=median([mxLocations.TextStart]);
    else
        performLocCheck=false;
        medianTextStart=Inf;
    end


    fcns=mtfind(fcnTree,'Kind','FUNCTION');
    indices=fcns.indices;
    for i=1:length(indices)
        index=indices(i);
        node=fcns.select(index);
        fcnName=string(node.Fname);





        isNodeInRange=@(fcnNode)fcnNode.lefttreepos<medianTextStart&&medianTextStart<fcnNode.righttreepos;

        if performLocCheck
            if strcmp(fcnName,this.functionName)&&isNodeInRange(node)
                fcnTree=node;
                return;
            end
        elseif strcmp(fcnName,this.functionName)
            fcnTree=node;
            return;
        end
    end

    fcnTree=coder.internal.translator.F2FMTree('');
end


