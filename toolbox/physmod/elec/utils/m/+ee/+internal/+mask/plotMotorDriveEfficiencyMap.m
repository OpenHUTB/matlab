function hFigure=plotMotorDriveEfficiencyMap(blockName)














    model=ee.internal.mask.motordrive.effmap.Model(blockName);
    view=ee.internal.mask.motordrive.effmap.View();

    controller=ee.internal.mask.motordrive.effmap.Control(model,view);

    hFigure=controller.View.UIFigure;

end
