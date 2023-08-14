function[retVal,schema]=Render(hThis,schema)











    retVal=true;




    listener=@(source,dialog,value,tag)hThis.OnFluidPropertyChange(dialog);

    fluidH=pmsl_getobjecthandle(hThis,...
    'class','PMDialogs.DynDropDown',...
    'Label','Hydraulic fluid');
    fluidH.addListener(listener);
    hThis.ChildHandles.hFluid=fluidH;

    tempH=pmsl_getobjecthandle(hThis,...
    'class','PMDialogs.DynEditBox',...
    'Label','System temperature (C)');
    tempH.addListener(listener);
    hThis.ChildHandles.hTemp=tempH;

    viscDer=pmsl_getobjecthandle(hThis,...
    'class','PMDialogs.DynEditBox',...
    'Label','Viscosity derating factor');
    viscDer.addListener(listener);
    hThis.ChildHandles.hVisc=viscDer;




    hThis.FluidDb=struct2cell(sh_stockfluidproperties());
    [viscValStr,densValStr,bulkValStr,errStr,panelVis]=ComputePropsAsStrings(hThis);














    [retval,schema]=hThis.renderChildren();
    schema=schema{1};


    [displaySchema,displayPath]=pmsl_extractdialogschema(schema,...
    'Type','panel',...
    'Name','dummy');
    displaySchema.Visible=panelVis(1);
    hThis.ChildTags.props=displaySchema.Tag;
    schema=pmsl_updatedialogschema(schema,displaySchema,displayPath);


    [densitySchema,densityPath]=pmsl_extractdialogschema(schema,...
    'Type','edit',...
    'Name','Density (kg/m^3):');
    densitySchema.Value=densValStr;
    hThis.ChildTags.density=densitySchema.Tag;
    schema=pmsl_updatedialogschema(schema,densitySchema,densityPath);


    [viscositySchema,viscosityPath]=pmsl_extractdialogschema(schema,...
    'Type','edit',...
    'Name','Viscosity (cSt):');
    viscositySchema.Value=viscValStr;
    hThis.ChildTags.viscosity=viscositySchema.Tag;
    schema=pmsl_updatedialogschema(schema,viscositySchema,viscosityPath);


    [modulusSchema,modulusPath]=pmsl_extractdialogschema(schema,...
    'Type','edit',...
    'Name',sprintf('Bulk modulus (Pa) at atm. pressure and no gas:'));
    modulusSchema.Value=bulkValStr;
    hThis.ChildTags.modulus=modulusSchema.Tag;
    schema=pmsl_updatedialogschema(schema,modulusSchema,modulusPath);


    [errorSchema,errorPath]=pmsl_extractdialogschema(schema,...
    'Type','text',...
    'Name','Error:');
    errorSchema.Visible=panelVis(2);
    hThis.ChildTags.error=errorSchema.Tag;
    errorSchema.Name=errStr;
    schema=pmsl_updatedialogschema(schema,errorSchema,errorPath);

end
