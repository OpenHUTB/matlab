function[viscValStr,densValStr,bulkValStr,errStr,panelVis]=ComputePropsAsStrings(hThis)


















    densValStr='';
    viscValStr='';
    bulkValStr='';
    errStr='';
    success=true;

    try
        hObjs=hThis.ChildHandles;
        selFluidIdx=find(strcmp(hObjs.hFluid.Value,hObjs.hFluid.Choices));
        item=hThis.FluidDb{selFluidIdx};

        sysTemp=hObjs.hTemp.Value;
        viscDer=hObjs.hVisc.Value;
        tempVal=evalin('base',sysTemp);
        viscDerVal=evalin('base',viscDer);
        visVal=0.0;%#ok
        densVal=0.0;%#ok
        bulkVal=0.0;%#ok
        [visVal,densVal,bulkVal]=item.prop(tempVal);
        visVal=viscDerVal*visVal;


        visVal=visVal*pm_unit('m^2/s','cSt','linear');

        densValStr=hThis.NumToString(densVal);
        viscValStr=hThis.NumToString(visVal);
        bulkValStr=hThis.NumToString(bulkVal);
    catch myException
        errStr=myException.message;
        success=false;
    end

    panelVis=[success,~success];


end
