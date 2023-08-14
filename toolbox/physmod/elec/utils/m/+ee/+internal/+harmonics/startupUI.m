function startupUI()





    model=ee.internal.harmonics.Model();


    view=ee.internal.harmonics.View;


    control=ee.internal.harmonics.Control(model,view);





    view.Controller=control;
end


