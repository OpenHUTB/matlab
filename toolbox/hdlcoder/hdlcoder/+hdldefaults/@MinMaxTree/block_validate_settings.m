function v_settings=block_validate_settings(this,hC)







    v_settings=struct;


    v_settings.checkserialization=true;



    if~isempty(hC)
        if isa(hC,'hdlcoder.sysobj_comp')
            sysObjHandle=hC.getSysObjImpl;
            blockInfo=this.getSysObjInfo(sysObjHandle);
        else
            blockInfo=this.getBlockInfo(hC);
        end
        fcnString=blockInfo.fcnString;
    else
        fcnString=[];
    end



    v_settings.checkportdatatypes=targetcodegen.targetCodeGenerationUtils.isFloatingPointMode&&strcmpi(fcnString,'Value');

    v_settings.checknfp=false;
    v_settings.checknfpdouble=false;
    v_settings.checknfphalf=false;

    if~isempty(hC)&&isHalfType(hC.PirInputSignals(1).Type.BaseType)
        v_settings.incompatibleforxilinx=true;
        v_settings.incompatibleforaltera=true;
    end
    if any(strcmpi({'Index','Value and Index'},fcnString))


        v_settings.checkretimeblackbox=true;


        v_settings.checksharing=true;
    end
