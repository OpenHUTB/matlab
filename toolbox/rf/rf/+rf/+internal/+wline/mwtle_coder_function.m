function mwtle_coder_function(tempDir,dispflag)
















    f=coder.internal.FeatureControl;
    f.Developer=1;








    cfg=coder.config('lib','ecoder',true);
    cfg.GenerateReport=false;
    cfg.ReportPotentialDifferences=false;
    if 1==1
        cfg.BuildConfiguration='Faster Runs';
        cfg.RuntimeChecks=0;
        f.NullCopyDebug=0;
    else
        cfg.BuildConfiguration='Debug';
        cfg.PreserveVariableNames='UserNames';
        cfg.RuntimeChecks=1;
        f.NullCopyDebug=1;
    end
    cfg.GenCodeOnly=true;



    SSSTRUCT=struct;
    SSSTRUCT.nOut=coder.typeof(int32(0));
    SSSTRUCT.Asub=coder.typeof(0,[Inf,1],[1,0]);
    SSSTRUCT.Adiag=coder.typeof(0,[Inf,1],[1,0]);
    SSSTRUCT.Asuper=coder.typeof(0,[Inf,1],[1,0]);
    SSSTRUCT.B=coder.typeof(0,[Inf,1],[1,0]);
    SSSTRUCT.C=coder.typeof(0,[Inf,Inf],[1,1]);
    SSSTRUCT.D=coder.typeof(0,[Inf,1],[1,0]);
    SSSTRUCT.xold=coder.typeof(0,[Inf,2],[1,0]);
    SSSTRUCT.xnew=coder.typeof(0,[Inf,2],[1,0]);
    SSSTRUCT.uold=coder.typeof(0,[1,2],[0,0]);

    ARGS_MWTLE_DATA=struct;
    ARGS_MWTLE_DATA.nLines=coder.typeof(int32(0));
    ARGS_MWTLE_DATA.Yo=coder.typeof({SSSTRUCT},[Inf,1],[1,0]);
    ARGS_MWTLE_DATA.Xo=coder.typeof({SSSTRUCT},[Inf,Inf],[1,1]);
    ARGS_MWTLE_DATA.MV=coder.typeof(0,[Inf,Inf],[1,1]);
    ARGS_MWTLE_DATA.DCR=coder.typeof(0,[Inf,Inf],[1,1]);
    ARGS_MWTLE_DATA.DCalphaV=coder.typeof(0,[Inf,Inf],[1,1]);
    ARGS_MWTLE_DATA.DCalphaD=coder.typeof(0,[Inf,1],[1,0]);
    ARGS_MWTLE_DATA.YoDC=coder.typeof(0,[Inf,Inf],[1,1]);
    ARGS_MWTLE_DATA.XoDC=coder.typeof(0,[Inf,Inf],[1,1]);
    ARGS_MWTLE_DATA.tau=coder.typeof(0,[Inf,1],[1,0]);
    ARGS_MWTLE_DATA.dcStamp=coder.typeof(0,[Inf,Inf],[1,1]);
    ARGS_MWTLE_DATA.curTime=coder.typeof(0);
    ARGS_MWTLE_DATA.timestep=coder.typeof(0);
    ARGS_MWTLE_DATA.nTime=coder.typeof(int32(0));
    ARGS_MWTLE_DATA.time=coder.typeof(0,[Inf,1],[1,0]);
    ARGS_MWTLE_DATA.timeCapacity=coder.typeof(int32(0));
    ARGS_MWTLE_DATA.iw1=coder.typeof(0,[Inf,Inf],[1,1]);
    ARGS_MWTLE_DATA.iw2=coder.typeof(0,[Inf,Inf],[1,1]);


    ARGS{2}=cell(1,1);
    ARGS{2}{1}=coder.typeof(ARGS_MWTLE_DATA);


    ARGS{3}=cell(4,1);
    ARGS{3}{1}=coder.typeof(int32(0));
    ARGS{3}{2}=coder.typeof(0);
    ARGS{3}{3}=coder.typeof('X',[Inf,1],[1,0]);
    ARGS{3}{4}=coder.typeof(0);


    ARGS{4}=cell(9,1);
    ARGS{4}{1}=coder.typeof(int32(0));
    ARGS{4}{2}=coder.typeof(0);
    ARGS{4}{3}=coder.typeof(0,[Inf,Inf],[1,1]);
    ARGS{4}{4}=coder.typeof(0,[Inf,Inf],[1,1]);
    ARGS{4}{5}=coder.typeof(0,[Inf,Inf],[1,1]);
    ARGS{4}{6}=coder.typeof(0,[Inf,Inf],[1,1]);
    ARGS{4}{7}=coder.typeof(0,[Inf,Inf],[1,1]);
    ARGS{4}{8}=coder.typeof(0,[Inf,Inf],[1,1]);
    ARGS{4}{9}=coder.typeof(0);


    ARGS{5}=cell(16,1);
    ARGS{5}{1}=coder.typeof(int32(0));
    ARGS{5}{2}=coder.typeof(0);
    ARGS{5}{3}=coder.typeof(int32(0));
    ARGS{5}{4}=coder.typeof(0,[Inf,1],[1,0]);
    ARGS{5}{5}=coder.typeof(0,[Inf,Inf],[1,1]);
    ARGS{5}{6}=coder.typeof(int32(0));
    ARGS{5}{7}=coder.typeof(0,[Inf,1],[1,0]);
    ARGS{5}{8}=coder.typeof(0,[Inf,Inf],[1,1]);
    ARGS{5}{9}=coder.typeof(int32(0));
    ARGS{5}{10}=coder.typeof(0,[Inf,1],[1,0]);
    ARGS{5}{11}=coder.typeof(0,[Inf,Inf],[1,1]);
    ARGS{5}{12}=coder.typeof(int32(0));
    ARGS{5}{13}=coder.typeof(0,[Inf,1],[1,0]);
    ARGS{5}{14}=coder.typeof(0,[Inf,Inf],[1,1]);
    ARGS{5}{15}=coder.typeof(int32(0));
    ARGS{5}{16}=coder.typeof(0);


    ARGS{6}=cell(10,1);
    ARGS{6}{1}=coder.typeof(ARGS_MWTLE_DATA);
    ARGS{6}{2}=coder.typeof(int32(0));
    ARGS{6}{3}=coder.typeof(0);
    ARGS{6}{4}=coder.typeof(0,[Inf,1],[1,0]);
    ARGS{6}{5}=coder.typeof(0,[Inf,1],[1,0]);
    ARGS{6}{6}=coder.typeof(0,[Inf,1],[1,0]);
    ARGS{6}{7}=coder.typeof(0,[Inf,1],[1,0]);
    ARGS{6}{8}=coder.typeof(0,[Inf,1],[1,0]);
    ARGS{6}{9}=coder.typeof(0,[Inf,1],[1,0]);
    ARGS{6}{10}=coder.typeof(0);


    ARGS{7}=cell(1,1);
    ARGS{7}{1}=coder.typeof(ARGS_MWTLE_DATA);
    ARGS{7}{2}=coder.typeof(0,[Inf,1],[1,0]);
    ARGS{7}{3}=coder.typeof(0,[Inf,1],[1,0]);


    ARGS{8}=cell(1,1);
    ARGS{8}{1}=coder.typeof(ARGS_MWTLE_DATA);


    ARGS{9}=cell(1,1);
    ARGS{9}{1}=coder.typeof(ARGS_MWTLE_DATA);


    ARGS{10}=cell(1,1);
    ARGS{10}{1}=coder.typeof(ARGS_MWTLE_DATA);


    ARGS{11}=cell(2,1);
    ARGS{11}{1}=coder.typeof(ARGS_MWTLE_DATA);
    ARGS{11}{2}=coder.typeof(0,[Inf,1],[1,0]);


    ARGS{12}=cell(1,1);
    ARGS{12}{1}=coder.typeof(ARGS_MWTLE_DATA);


    ARGS{13}=cell(1,1);
    ARGS{13}{1}=coder.typeof(ARGS_MWTLE_DATA);


    ARGS{14}=cell(1,1);
    ARGS{14}{1}=coder.typeof(ARGS_MWTLE_DATA);


    ARGS{15}=cell(3,1);
    ARGS{15}{1}=coder.typeof(ARGS_MWTLE_DATA);
    ARGS{15}{2}=coder.typeof(0,[Inf,1],[1,0]);
    ARGS{15}{3}=coder.typeof(0,[Inf,1],[1,0]);


    ARGS{16}=cell(1,1);
    ARGS{16}{1}=coder.typeof(ARGS_MWTLE_DATA);
    ARGS{16}{2}=coder.typeof(0,[Inf,Inf],[1,1]);
    ARGS{16}{3}=coder.typeof(0,[Inf,Inf],[1,1]);
    ARGS{16}{4}=coder.typeof(0,[Inf,1],[1,0]);
    ARGS{16}{5}=coder.typeof(0,[Inf,1],[1,0]);


    ARGS{17}=cell(6,1);
    ARGS{17}{1}=coder.typeof(ARGS_MWTLE_DATA);
    ARGS{17}{2}=coder.typeof(0);
    ARGS{17}{3}=coder.typeof(0);
    ARGS{17}{4}=coder.typeof(0,[Inf,1],[1,0]);
    ARGS{17}{5}=coder.typeof(0,[Inf,1],[1,0]);
    ARGS{17}{6}=coder.typeof(int32(0));


    ARGS{18}=cell(1,1);
    ARGS{18}{1}=coder.typeof(int32(0));


    funNames=cell(18,1);
    funNames{2}='mltle_createDCTleElement';
    funNames{3}='mltle_createTleData';
    funNames{4}='mltle_createTleDataMat';
    funNames{5}='mltle_createTleDataTable';
    funNames{6}='mltle_createTleDataVec';
    funNames{7}='mltle_createTranTlElement';
    funNames{8}='mltle_deleteDCTleElement';
    funNames{9}='mltle_deleteTleData';
    funNames{10}='mltle_deleteTranTleElement';
    funNames{11}='mltle_getDCTleCurrent';
    funNames{12}='mltle_getDCTleStamp';
    funNames{13}='mltle_getMinDelay';
    funNames{14}='mltle_getTleCapacitance';
    funNames{15}='mltle_getTranTleCurrent';
    funNames{16}='mltle_getTranTleStamp';
    funNames{17}='mltle_tleTranStep';
    funNames{18}='mltle_ntri';

    codegenStr=sprintf('codegen -v -feature f -config cfg -package %s -d %s -o mwtle',...
    fullfile(tempDir,'mwtle.zip'),fullfile(tempDir,'codegen'));
    for i=2:18
        temp=fullfile(matlabroot,'toolbox','rf','rf','+rf','+internal','+wline',funNames{i});
        istr=sprintf(' %s.m -args ARGS{%d}',temp,i);
        codegenStr=strcat(codegenStr,istr);
    end

    if dispflag
        eval(codegenStr);
    else
        evalc(codegenStr);
    end

end
