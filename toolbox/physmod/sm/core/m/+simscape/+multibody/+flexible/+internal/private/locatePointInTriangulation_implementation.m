




function[tIdx,bC]=...
    locatePointInTriangulation_implementation(triangles,points,Qxy)

    try
        tr=triangulation(triangles,points);
        [tIdx,bC]=tr.pointLocation(Qxy);
    catch caughtException




        ME=MException('simscape:multibody:internal:TriangulationProblem',...
        'A problem was encountered during triangulation.');
        ME=addCause(ME,caughtException);
        throw(ME);

    end

end
