function instance=AxisContainerFactory(root,sys,inst)






    category=asam.cdfx.mf0.getCategory(inst);


    switch category
    case "FIX_AXIS"

        instance=asam.cdfx.axis.FixedAxis(inst);
    case "STD_AXIS"

        instance=asam.cdfx.axis.StandardAxis(inst);
    case "COM_AXIS"

        instance=asam.cdfx.axis.CommonAxis(inst);
    case "CURVE_AXIS"

        instance=asam.cdfx.axis.CurveAxis(inst);
    case "RES_AXIS"

        instance=asam.cdfx.axis.RescaledAxis(inst);
    end

end


