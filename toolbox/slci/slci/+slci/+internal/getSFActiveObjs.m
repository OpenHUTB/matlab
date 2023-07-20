


function activeObjs=getSFActiveObjs(originalObjs)
    activeObjs=[];
    try
        for i=1:numel(originalObjs)





            if~originalObjs(i).IsExplicitlyCommented...
                &&~originalObjs(i).IsImplicitlyCommented
                activeObjs=[activeObjs;originalObjs(i)];%#ok
            end
        end
    catch
        activeObjs=[];
    end
end
