function getExtensionUpdate(hObj,event)









































    cs=hObj.getConfigSet();
    if isempty(cs),return;end
    model=cs.getModel();

    switch(event)
    case{'pre-activate','deactivate','attach','update_host_model'}

        setValAndEnForce(cs,'GenerateMakefile','on',false);
        setValAndEnForce(cs,'MakeCommand','make_rtw',false);
        setValAndEnForce(cs,'RTWCompilerOptimization','off',false);
        setProp(hObj,'UseToolchainInfoCompliant','on');
        setPropEnabled(cs,'GenCodeOnly',true);

    case 'deselect_target'
        dirtyBit=get_param(model,'Dirty');
        set_param(model,'Dirty',dirtyBit);

    case{'switch_target','activate'}







        dirtyBit=get_param(model,'Dirty');




        setValAndEn(cs,'GenerateCodeInfo','on',false);









        setValAndEn(cs,'MaxIdLength',256,true);


        setValAndEn(cs,'SolverType','Fixed-step',false);
        setValAndEn(cs,'EnableMultiTasking','off',false);



        setValAndEn(cs,'InlineParams','on',true);

        setValAndEn(cs,'BlockReduction','off',true);
        setValAndEn(cs,'OptimizeBlockIOStorage','off',true);
        setValAndEn(cs,'RTWCAPISignals','on',true);














        Porting=isempty(model)||...
        (strcmp(get_param(model,'Toolchain'),'Mentor Graphics QuestaSim/Modelsim (32-bit Windows)')||...
        (ispc&&(strcmp(get_param(model,'Toolchain'),'Mentor Graphics QuestaSim/Modelsim (64-bit Linux)')||...
        strcmp(get_param(model,'Toolchain'),'Cadence Xcelium (64-bit Linux)'))));



        if strcmp(event,'switch_target')||~Porting
            wl=rtwhostwordlengths;
            setValAndEnForce(cs,'TargetHWDeviceType','Generic->Custom',true);
            setValAndEnForce(cs,'TargetBitPerChar',wl.CharNumBits,true);
            setValAndEnForce(cs,'TargetBitPerShort',wl.ShortNumBits,true);
            setValAndEnForce(cs,'TargetBitPerInt',wl.IntNumBits,true);
            setValAndEnForce(cs,'TargetBitPerLong',wl.LongNumBits,true);
            setValAndEnForce(cs,'TargetBitPerLongLong',wl.LongLongNumBits,true);
            setValAndEnForce(cs,'TargetWordSize',wl.WordSize,true);
            setValAndEnForce(cs,'TargetBitPerPointer',wl.PointerNumBits,true);
            setValAndEnForce(cs,'TargetBitPerSizeT',wl.SizeTNumBits,true);
            setValAndEnForce(cs,'TargetBitPerPtrDiffT',wl.PtrDiffTNumBits,true);


            if(wl.LongLongMode)
                setValAndEnForce(cs,'TargetLongLongMode','on',true);
            else
                setValAndEnForce(cs,'TargetLongLongMode','off',true);
            end

            imp=rtw_host_implementation_props;

            setValAndEnForce(cs,'TargetEndianess',imp.Endianess,true);
            if(imp.ShiftRightIntArith)
                setValAndEnForce(cs,'TargetShiftRightIntArith','on',true);
            else
                setValAndEnForce(cs,'TargetShiftRightIntArith','off',true);
            end

            switch(imp.IntDivRoundTo)
            case 'Undefined',...
                setValAndEnForce(cs,'TargetIntDivRoundTo','Zero',true);
            otherwise,...
                setValAndEnForce(cs,'TargetIntDivRoundTo',imp.IntDivRoundTo,true);
            end

            setValAndEnForce(cs,'TargetUnknown','off',true);
        end



        setValAndEn(cs,'TargetLang','C',false);
        set_param(cs,'TargetLangStandard','C89/C90 (ANSI)');
        setValAndEn(cs,'GenerateMakefile','on',false);
        setValAndEnForce(cs,'MakeCommand','make_rtw',false);

        setValAndEnForce(cs,'UseToolchainInfoCompliant','on',true);



        setValAndEnForce(cs,'RTWCompilerOptimization','off',false);

        setValAndEn(cs,'CombineSignalStateStructs','on',false);





        setValAndEnForce(cs,'SuppressErrorStatus','off',true);
        setValAndEn(cs,'PurelyIntegerCode','off',false);
        setValAndEn(cs,'SupportNonFinite','on',false);
        setValAndEn(cs,'SupportComplex','on',false);
        setValAndEn(cs,'SupportAbsoluteTime','on',false);




        setValAndEn(cs,'CodeInterfacePackaging','Reusable function',false);

        setValAndEnForce(cs,'MultiInstanceErrorCode','Error',true);

        if strcmp(event,'switch_target')
            setValAndEn(cs,'CombineOutputUpdateFcns','off',true);
        end
        setValAndEn(cs,'GRTInterface','off',false);



        setValAndEnForce(cs,'ZeroExternalMemoryAtStartup','on',false);
        setValAndEnForce(cs,'ZeroInternalMemoryAtStartup','on',false);



        set_param(model,'Dirty',dirtyBit);
    end
end





function setValAndEn(cs,prop,val,en)
    if(cs.getPropEnabled(prop))



        set_param(cs,prop,val);
        cs.setPropEnabled(prop,en);
    else
        assert(en==false);
    end
end

function setValAndEnForce(cs,prop,val,en)
    cs.setPropEnabled(prop,true);
    setValAndEn(cs,prop,val,en);
end




