function[methodinfo,structs,enuminfo,ThunkLibName]=mw_rp_proto




    ival={cell(1,0)};
    structs=[];enuminfo=[];fcnNum=1;
    fcns=struct('name',ival,'calltype',ival,'LHS',ival,'RHS',ival,'alias',ival,'thunkname',ival);
    MfilePath=fileparts(mfilename('fullpath'));
    ThunkLibName=fullfile(MfilePath,'mw_rp_thunk_win64');

    fcns.thunkname{fcnNum}='voidvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrcstringint32Thunk';fcns.name{fcnNum}='CRITPdll';fcns.calltype{fcnNum}='Thunk';fcns.LHS{fcnNum}=[];fcns.RHS{fcnNum}={'doublePtr','doublePtr','doublePtr','doublePtr','int32Ptr','cstring','int32'};fcnNum=fcnNum+1;

    fcns.thunkname{fcnNum}='voidvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrThunk';fcns.name{fcnNum}='INFOdll';fcns.calltype{fcnNum}='Thunk';fcns.LHS{fcnNum}=[];fcns.RHS{fcnNum}={'int32Ptr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr'};fcnNum=fcnNum+1;

    fcns.thunkname{fcnNum}='voidcstringvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrint32Thunk';fcns.name{fcnNum}='LIMITSdll';fcns.calltype{fcnNum}='Thunk';fcns.LHS{fcnNum}=[];fcns.RHS{fcnNum}={'cstring','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','int32'};fcnNum=fcnNum+1;

    fcns.thunkname{fcnNum}='voidvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrcstringint32Thunk';fcns.name{fcnNum}='PDFLSHdll';fcns.calltype{fcnNum}='Thunk';fcns.LHS{fcnNum}=[];fcns.RHS{fcnNum}={'doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','int32Ptr','cstring','int32'};fcnNum=fcnNum+1;

    fcns.thunkname{fcnNum}='voidvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrcstringint32Thunk';fcns.name{fcnNum}='PEFLSHdll';fcns.calltype{fcnNum}='Thunk';fcns.LHS{fcnNum}=[];fcns.RHS{fcnNum}={'doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','int32Ptr','cstring','int32'};fcnNum=fcnNum+1;

    fcns.thunkname{fcnNum}='voidvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrcstringint32Thunk';fcns.name{fcnNum}='PQFLSHdll';fcns.calltype{fcnNum}='Thunk';fcns.LHS{fcnNum}=[];fcns.RHS{fcnNum}={'doublePtr','doublePtr','doublePtr','int32Ptr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','int32Ptr','cstring','int32'};fcnNum=fcnNum+1;

    fcns.thunkname{fcnNum}='voidvoidPtrvoidPtrcstringint32Thunk';fcns.name{fcnNum}='SATSPLNdll';fcns.calltype{fcnNum}='Thunk';fcns.LHS{fcnNum}=[];fcns.RHS{fcnNum}={'doublePtr','int32Ptr','cstring','int32'};fcnNum=fcnNum+1;

    fcns.thunkname{fcnNum}='voidcstringcstringcstringvoidPtrcstringvoidPtrvoidPtrcstringint32int32int32int32int32Thunk';fcns.name{fcnNum}='SETMIXdll';fcns.calltype{fcnNum}='Thunk';fcns.LHS{fcnNum}=[];fcns.RHS{fcnNum}={'cstring','cstring','cstring','int32Ptr','cstring','doublePtr','int32Ptr','cstring','int32','int32','int32','int32','int32'};fcnNum=fcnNum+1;

    fcns.thunkname{fcnNum}='voidcstringint32Thunk';fcns.name{fcnNum}='SETPATHdll';fcns.calltype{fcnNum}='Thunk';fcns.LHS{fcnNum}=[];fcns.RHS{fcnNum}={'cstring','int32'};fcnNum=fcnNum+1;

    fcns.thunkname{fcnNum}='voidvoidPtrcstringcstringcstringvoidPtrcstringint32int32int32int32Thunk';fcns.name{fcnNum}='SETUPdll';fcns.calltype{fcnNum}='Thunk';fcns.LHS{fcnNum}=[];fcns.RHS{fcnNum}={'int32Ptr','cstring','cstring','cstring','int32Ptr','cstring','int32','int32','int32','int32'};fcnNum=fcnNum+1;

    fcns.thunkname{fcnNum}='voidvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrcstringint32Thunk';fcns.name{fcnNum}='TQFLSHdll';fcns.calltype{fcnNum}='Thunk';fcns.LHS{fcnNum}=[];fcns.RHS{fcnNum}={'doublePtr','doublePtr','doublePtr','int32Ptr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','int32Ptr','cstring','int32'};fcnNum=fcnNum+1;

    fcns.thunkname{fcnNum}='voidvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrvoidPtrcstringint32Thunk';fcns.name{fcnNum}='TRNPRPdll';fcns.calltype{fcnNum}='Thunk';fcns.LHS{fcnNum}=[];fcns.RHS{fcnNum}={'doublePtr','doublePtr','doublePtr','doublePtr','doublePtr','int32Ptr','cstring','int32'};fcnNum=fcnNum+1;

    fcns.thunkname{fcnNum}='voidvoidPtrvoidPtrThunk';fcns.name{fcnNum}='WMOLdll';fcns.calltype{fcnNum}='Thunk';fcns.LHS{fcnNum}=[];fcns.RHS{fcnNum}={'doublePtr','doublePtr'};fcnNum=fcnNum+1;
    methodinfo=fcns;