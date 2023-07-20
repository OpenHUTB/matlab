function[xl,yl,zl]=UntransformLimits(ds,xl,yl,zl)


    warning_state=warning('off','MATLAB:nearlySingularMatrix');


    c=onCleanup(@()warning(warning_state));

    mat=makehgtform;
    norm_limits_bottom=matlab.graphics.internal.transformNormalizedToWorld(ds,mat,[xl(1);yl(1);zl(1)]);
    norm_limits_top=matlab.graphics.internal.transformNormalizedToWorld(ds,mat,[xl(2);yl(2);zl(2)]);

    bottom_data=matlab.graphics.internal.transformWorldToData(ds,mat,norm_limits_bottom(:));
    top_data=matlab.graphics.internal.transformWorldToData(ds,mat,norm_limits_top(:));

    xl=sort([bottom_data(1),top_data(1)]);
    yl=sort([bottom_data(2),top_data(2)]);
    zl=sort([bottom_data(3),top_data(3)]);