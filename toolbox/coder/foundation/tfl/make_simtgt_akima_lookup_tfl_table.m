function hLib=make_simtgt_akima_lookup_tfl_table
    hLib=RTW.TflTable;





    for i=2:6












        e=RTW.TflCFunctionEntry;

        loc_setTflCFunctionEntryParameters(e,false,true);


        loc_addConceptualArgsForCoeff(e,'double',i,false);


        loc_addImplementationArgsForCoeff(e,'double');

        hLib.addEntry(e);














        e=RTW.TflCFunctionEntry;

        loc_setTflCFunctionEntryParameters(e,false,false);


        loc_addConceptualArgsForCoeff(e,'single',i,false);


        loc_addImplementationArgsForCoeff(e,'single');

        hLib.addEntry(e);
    end












    e=RTW.TflCFunctionEntry;

    loc_setTflCFunctionEntryParameters(e,false,true);


    loc_addConceptualArgsForCoeff(e,'double',2,true);


    loc_addImplementationArgsForCoeff(e,'double');

    hLib.addEntry(e);














    e=RTW.TflCFunctionEntry;

    loc_setTflCFunctionEntryParameters(e,false,false);


    loc_addConceptualArgsForCoeff(e,'single',2,true);


    loc_addImplementationArgsForCoeff(e,'single');

    hLib.addEntry(e);





















    e=RTW.TflCFunctionEntry;

    loc_setTflCFunctionEntryParameters(e,true,true);


    loc_addConceptualArgsForInterp(e,'double',false,false);


    loc_addImplementationArgsForInterp(e,'double');

    hLib.addEntry(e);






















    e=RTW.TflCFunctionEntry;

    loc_setTflCFunctionEntryParameters(e,true,false);


    loc_addConceptualArgsForInterp(e,'single',false,false);


    loc_addImplementationArgsForInterp(e,'single');


    hLib.addEntry(e);




















    e=RTW.TflCFunctionEntry;

    loc_setTflCFunctionEntryParameters(e,true,true);


    loc_addConceptualArgsForInterp(e,'double',true,false);


    loc_addImplementationArgsForInterp(e,'double');

    hLib.addEntry(e);























    e=RTW.TflCFunctionEntry;

    loc_setTflCFunctionEntryParameters(e,true,false);


    loc_addConceptualArgsForInterp(e,'single',true,false);


    loc_addImplementationArgsForInterp(e,'single');

    hLib.addEntry(e);




















    e=RTW.TflCFunctionEntry;
    loc_setTflCFunctionEntryParameters(e,true,true);


    loc_addConceptualArgsForInterp(e,'double',false,true);


    loc_addImplementationArgsForInterp(e,'double');

    hLib.addEntry(e);























    e=RTW.TflCFunctionEntry;

    loc_setTflCFunctionEntryParameters(e,true,false);


    loc_addConceptualArgsForInterp(e,'single',false,true);


    loc_addImplementationArgsForInterp(e,'single');

    hLib.addEntry(e);





















    e=RTW.TflCFunctionEntry;

    loc_setTflCFunctionEntryParameters(e,true,true);


    loc_addConceptualArgsForInterp(e,'double',true,true);


    loc_addImplementationArgsForInterp(e,'double');


    hLib.addEntry(e);
























    e=RTW.TflCFunctionEntry;

    loc_setTflCFunctionEntryParameters(e,true,false);


    loc_addConceptualArgsForInterp(e,'single',true,true);


    loc_addImplementationArgsForInterp(e,'single');

    hLib.addEntry(e);
end


function loc_setTflCFunctionEntryParameters(entry,isInterp,isDouble)

    if ispc
        libExt='lib';
    elseif ismac
        libExt='dylib';
    else
        libExt='so';
    end


    LibPath='$getBlasRtwLibPath$';



    HeaderPath=fullfile('$(MATLAB_ROOT)',...
    'rtw',...
    'c',...
    'src',...
    'rapid',...
    'akima');
    if isInterp
        key='akimaFixedGrid_interpolate';
    else
        key='akimaFixedGrid_precompute';
    end
    if isDouble
        sufix='double';
    else
        sufix='float';
    end
    entry.setTflCFunctionEntryParameters('Key',key,...
    'Priority',80,...
    'ImplementationName',[key,'_',sufix],...
    'ImplementationHeaderFile',['akimaEvaluation_',sufix,'.h'],...
    'ImplementationHeaderPath',HeaderPath,...
    'AdditionalLinkObjs',{['libmwmfl_interp.',libExt]},...
    'AdditionalLinkObjsPaths',{LibPath});
end



function loc_addConceptualArgsForCoeff(e,dtype,i,isGridSizeScalar)


    loc_addConceptualArgForMatrix(e,'y1',dtype,'RTW_IO_OUTPUT');


    loc_addConceptualArgForscalar(e,'u1','uint64','RTW_IO_INPUT');


    if isGridSizeScalar
        loc_addConceptualArgForscalar(e,'u2','uint64','RTW_IO_INPUT');
    else
        loc_addConceptualArgForMatrix(e,'u2','uint64','RTW_IO_INPUT');
    end


    arg=RTW.TflArgMatrix('u3','RTW_IO_INPUT',[dtype,'*']);
    arg.DimRange=[1,1;inf,inf];
    arg.Type.BaseType.BaseType.ReadOnly=true;
    e.addConceptualArg(arg);


    arg=RTW.TflArgMatrix('u4','RTW_IO_INPUT',dtype);
    arg.DimRange=[ones(1,i);inf*ones(1,i)];
    e.addConceptualArg(arg);


    loc_addConceptualArgForMatrix(e,'u5',dtype,'RTW_IO_INPUT');


    loc_addConceptualArgForMatrix(e,'u6','uint64','RTW_IO_INPUT');

end


function loc_addImplementationArgsForCoeff(e,dtype)




    loc_addImplementationArg(e,'u1','uint64',false,false);


    loc_addImplementationArg(e,'u2','uint64*',false,true);


    loc_addPtrToPtrImplementationArg(e,'u3',dtype);


    loc_addImplementationArg(e,'u4',[dtype,'*'],false,true);


    loc_addImplementationArg(e,'u5',[dtype,'*'],false,false);


    loc_addImplementationArg(e,'u6','uint64*',false,false);


    loc_addImplementationArg(e,'y1',[dtype,'*'],true,false);


    arg=e.getTflArgFromString('y2','void');
    arg.IOType='RTW_IO_OUTPUT';
    e.Implementation.setReturn(arg);

end



function loc_addConceptualArgsForInterp(e,dtype,isY1Scalar,isGridSizeScalar)


    if isY1Scalar
        loc_addConceptualArgForscalar(e,'y1',dtype,'RTW_IO_OUTPUT');
    else
        loc_addConceptualArgForMatrix(e,'y1',dtype,'RTW_IO_OUTPUT');
    end


    loc_addConceptualArgForscalar(e,'u1','uint64','RTW_IO_INPUT');


    if isGridSizeScalar
        loc_addConceptualArgForscalar(e,'u2','uint64','RTW_IO_INPUT');
    else
        loc_addConceptualArgForMatrix(e,'u2','uint64','RTW_IO_INPUT');
    end


    arg=RTW.TflArgMatrix('u3','RTW_IO_INPUT',[dtype,'*']);
    arg.DimRange=[1,1;inf,inf];
    arg.Type.BaseType.BaseType.ReadOnly=true;
    e.addConceptualArg(arg);


    loc_addConceptualArgForscalar(e,'u4','uint64','RTW_IO_INPUT');


    loc_addConceptualArgForscalar(e,'u5','uint64','RTW_IO_INPUT');


    loc_addConceptualArgForMatrix(e,'u6',dtype,'RTW_IO_INPUT');


    loc_addConceptualArgForMatrix(e,'u7','uint64','RTW_IO_INPUT');


    loc_addConceptualArgForMatrix(e,'u8',dtype,'RTW_IO_INPUT');


    loc_addConceptualArgForscalar(e,'u9','uint64','RTW_IO_INPUT');


    arg=RTW.TflArgMatrix('u10','RTW_IO_INPUT',[dtype,'*']);
    arg.DimRange=[1,1;inf,inf];
    arg.Type.BaseType.BaseType.ReadOnly=true;
    e.addConceptualArg(arg);


    ptType=embedded.pointertype;
    ptType.BaseType=numerictype(false,64,0);
    arg=RTW.TflArgPointer('u11');
    arg.Type.BaseType=ptType;
    e.addConceptualArg(arg);


end


function loc_addImplementationArgsForInterp(e,dtype)




    loc_addImplementationArg(e,'u1','uint64',false,false);


    loc_addImplementationArg(e,'u2','uint64*',false,true);


    loc_addPtrToPtrImplementationArg(e,'u3',dtype);


    loc_addImplementationArg(e,'u4','uint64',false,false);


    loc_addImplementationArg(e,'u5','uint64',false,false);


    loc_addImplementationArg(e,'u6',[dtype,'*'],false,false);


    loc_addImplementationArg(e,'u7','uint64*',false,false);


    loc_addImplementationArg(e,'u8',[dtype,'*'],false,false);


    loc_addImplementationArg(e,'u9','uint64',false,false);


    loc_addPtrToPtrImplementationArg(e,'u10',dtype);



    ptType=embedded.pointertype;
    ptType.BaseType=numerictype(false,64,0);
    arg=RTW.TflArgPointer('u11');
    arg.Type.BaseType=ptType;
    e.Implementation.addArgument(arg);


    loc_addImplementationArg(e,'y1',[dtype,'*'],true,false);


    arg=e.getTflArgFromString('y2','void');
    arg.IOType='RTW_IO_OUTPUT';
    e.Implementation.setReturn(arg);

end



function loc_addConceptualArgForscalar(e,argName,argType,IOType)
    arg=e.getTflArgFromString(argName,argType);
    arg.IOType=IOType;
    e.addConceptualArg(arg);
end



function loc_addConceptualArgForMatrix(e,argName,argType,IOType)
    arg=RTW.TflArgMatrix(argName,IOType,argType);
    arg.DimRange=[1,1;inf,inf];
    e.addConceptualArg(arg);
end



function loc_addImplementationArg(e,argName,argType,is_IO_OUT,isReadOnly)
    arg=e.getTflArgFromString(argName,argType);
    if is_IO_OUT
        arg.IOType='RTW_IO_OUTPUT';
    end
    if isReadOnly
        arg.Type.BaseType.ReadOnly=true;
    end
    e.Implementation.addArgument(arg);
end




function loc_addPtrToPtrImplementationArg(e,argName,argType)
    ptType=embedded.pointertype;
    ptType.BaseType=embedded.numerictype;
    ptType.BaseType.DataTypeMode=argType;
    ptType.BaseType.ReadOnly=true;
    arg=RTW.TflArgPointer(argName);
    arg.Type.BaseType=ptType;
    e.Implementation.addArgument(arg);
end
