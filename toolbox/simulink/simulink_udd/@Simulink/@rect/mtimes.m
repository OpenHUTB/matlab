function slr3=mtimes(slr1,slr2)







    if isempty(slr1)|isempty(slr2),
        slr3=Simulink.rect;
    else
        slr3=Simulink.rect;




        if(slr1.right<slr2.left)|...
            (slr1.left>slr2.right)|...
            (slr1.top>=slr2.bottom)|...
            (slr1.bottom<=slr2.top),
            return;
        end




        slr3.left=max(slr1.left,slr2.left);
        slr3.top=max(slr1.top,slr2.top);
        slr3.right=min(slr1.right,slr2.right);
        slr3.bottom=min(slr1.bottom,slr2.bottom);
    end
