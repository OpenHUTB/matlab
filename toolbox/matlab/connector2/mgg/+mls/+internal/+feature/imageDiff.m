function value=imageDiff(value)


    if(strcmp(value,'status')==1)
        value='Status argument not implemented';
    else
        com.mathworks.matlabserver.jcp.GraphicsAndGuis.setImageDifferenceStrategy(value);
    end

end

