function str=mat2str(matrix)








    s=size(matrix);
    if length(s)<=2
        str=mat2str(matrix);
    else


        str="reshape("+mat2str(matrix(:))+","+strjoin(string(s),',')+")";
    end