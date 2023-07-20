function R=findBoundingSphereRadius(obj)





    G=getGeometry(obj);


    if iscell(G)
        R=0;
        for i=1:numel(G)
            B=G{i}.BorderVertices;
            R=max(R,findMaxDistance(B));
        end
    else
        B=G.BorderVertices;
        R=findMaxDistance(B);
    end

end

function dmax=findMaxDistance(B)
    dmax=max(cellfun(@(x)norm(x),num2cell(B,2)));
end