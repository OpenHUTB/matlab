function meshExciter(obj)





    s=getMeshMode(obj.Exciter);
    edgeLength=getMeshEdgeLength(obj);
    if strcmpi(s,'auto')
        lambda=getMeshingLambda(obj);
        if~isempty(lambda)
            edgeLength_ex=calculateMeshParams(obj.Exciter,...
            lambda);







            if(obj.EnableProbeFeed==1)&&(edgeLength_ex>edgeLength)
                edgeLength_ex=edgeLength;
            end
        else
            edgeLength_ex=edgeLength;
        end
        meshconfig(obj.Exciter,'manual');
        if isHminUserSpecified(obj)


            minel=getMinContourEdgeLength(obj);
            [~]=mesh(obj.Exciter,'MaxEdgeLength',edgeLength_ex,'MinEdgeLength',minel);
        elseif isa(obj.Exciter,'em.PrintedAntenna')&&~isempty(getMinContourEdgeLength(obj.Exciter))
            minel=getMinContourEdgeLength(obj.Exciter);
            [~]=mesh(obj.Exciter,'MaxEdgeLength',edgeLength_ex,'MinEdgeLength',minel);
        else



            setMeshMinContourEdgeLength(obj.Exciter,[]);
            [~]=mesh(obj.Exciter,'MaxEdgeLength',edgeLength_ex);
        end
        meshconfig(obj.Exciter,'auto');
    end
