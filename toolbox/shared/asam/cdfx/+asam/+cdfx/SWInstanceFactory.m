function instance=SWInstanceFactory(root,sys,inst)

    category=inst.CATEGORY.elementValue;

    switch category
    case "VALUE"
        instance=asam.cdfx.instance.Value(root,sys,inst);
    case "BOOLEAN"
        instance=asam.cdfx.instance.Boolean(root,sys,inst);
    case "BLOB"

        instance=asam.cdfx.instance.Blob(root,sys,inst);
    case "ASCII"

        instance=asam.cdfx.instance.ASCII(root,sys,inst);
    case "DEPENDENT_VALUE"

        instance=asam.cdfx.instance.DependentValue(root,sys,inst);
    case "VAL_BLK"

        instance=asam.cdfx.instance.ValueBlock(root,sys,inst);
    case "CURVE"

        instance=asam.cdfx.instance.Curve(root,sys,inst);
    case "MAP"

        instance=asam.cdfx.instance.Map(root,sys,inst);
    case "CUBOID"

        instance=asam.cdfx.instance.Cuboid(root,sys,inst);
    case "CUBE_4"

        instance=asam.cdfx.instance.Cube4(root,sys,inst);
    case "CUBE_5"

        instance=asam.cdfx.instance.Cube5(root,sys,inst);
    case "COM_AXIS"

        instance=asam.cdfx.instance.CommonAxis(root,sys,inst);
    case "CURVE_AXIS"

        instance=asam.cdfx.instance.CurveAxis(root,sys,inst);
    case "RES_AXIS"

        instance=asam.cdfx.instance.RescaledAxis(root,sys,inst);
    case "STRUCTURE"

        instance=asam.cdfx.instance.Structure(root,sys,inst);
    otherwise

        warning(message('asam_cdfx:CDFX:UnsupportedInstance',category));
    end

end


