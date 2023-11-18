function has=hasFixedPointDesigner()
    has=builtin('license','test','Fixed_Point_Toolbox')&&~isempty(ver('fixedpoint'));


    if has
        builtin('license','checkout','Fixed_Point_Toolbox');
    end


end

