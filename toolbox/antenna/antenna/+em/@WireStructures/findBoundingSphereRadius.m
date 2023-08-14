function R=findBoundingSphereRadius(obj)





    G=getGeometry(obj);


    if iscell(G.volDataReal.Surfaces)
        R=0;
        for i=1:numel(G.volDataReal.Surfaces)
            B=G.volDataReal.Surfaces{i}.Vertices;
            R=max(R,findMaxDistance(B));
        end
    else
        B=G.volDataReal.Surfaces.Vertices;
        R=findMaxDistance(B);
    end

end

function dmax=findMaxDistance(B)
    dmax=max(cellfun(@(x)norm(x),num2cell(B,2)));
end