function[x,y]=calculateZoomLineData(x_origpt,x_currpt,y_origpt,y_currpt,x_end,y_end,constraint)





    switch(constraint)
    case{"xyz","unconstrained"}












        x=[x_origpt,x_origpt,x_currpt,x_currpt,x_origpt];
        y=[y_origpt,y_currpt,y_currpt,y_origpt,y_origpt];

    case "x"









        x=[x_origpt,x_origpt,NaN,x_origpt,x_currpt,NaN,x_currpt,x_currpt];
        y=[y_end,NaN,y_origpt,y_origpt,NaN,y_end];

    case "y"












        x=[x_end,NaN,x_origpt,x_origpt,NaN,x_end];
        y=[y_origpt,y_origpt,NaN,y_origpt,y_currpt,NaN,y_currpt,y_currpt];
    end
