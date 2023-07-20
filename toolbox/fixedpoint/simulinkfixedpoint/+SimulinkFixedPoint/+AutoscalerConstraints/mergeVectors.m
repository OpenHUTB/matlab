function[hasConflict,newVector]=mergeVectors(vector1,vector2)























    [xGrid,yGrid]=meshgrid(vector1,vector2);

    if isempty(xGrid)
        hasConflict=false;
        if isempty(vector1)

            newVector=vector2;
        elseif isempty(vector2)

            newVector=vector1;
        end
    else









        diffGrid=xGrid-yGrid;



        newVector=vector2(~all(diffGrid,2));


        hasConflict=isempty(newVector);
    end
end
