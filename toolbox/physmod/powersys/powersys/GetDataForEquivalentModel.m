function S=GetDataForEquivalentModel(SimulationType,block,SwTol)







    SPS=get_param(block,'UserData');

    if isempty(SPS)
        S=[];
        return
    end

    switch SimulationType

    case 'Phasor'

        S.H=SPS.Hswo(SPS.OutputsNotDistLine,SPS.InputsNotDistLine);
        S.Rswitch=SPS.Rswitch;
        S.InputsNonZero=[length(SPS.Rswitch)+1:length(SPS.InputsNotDistLine)];

        return

    case 'Discrete phasor'

        S.H=SPS.Hswo(SPS.OutputsNotDistLine,SPS.InputsNotDistLine);
        [NOUTPUT,NINPUT]=size(S.H);
        S.Ninputs=NINPUT;
        S.Noutputs=NOUTPUT;
        S.Rswitch=SPS.Rswitch;
        S.InputsNonZero=[length(SPS.Rswitch)+1:length(SPS.InputsNotDistLine)];
        S.Ts=SPS.PowerguiInfo.Ts;
        S.NonLinearDim=SPS.DSS.model.NonLinearDim;
        S.NonLinear_Inputs_Sort=SPS.DSS.model.NonLinear_Inputs;
        S.NonLinear_Outputs_Sort=SPS.DSS.model.NonLinear_Outputs;
        S.Index_RowNumber_H=SPS.DSS.model.Index_RowNumber_H;
        S.Index_ColNumber_H=SPS.DSS.model.Index_ColNumber_H;
        S.Index_OutputNumber=SPS.DSS.model.reorderout.indices;
        S.inMux=SPS.DSS.model.inMux;

        return
    end

    S.SwitchResistance=SPS.SwitchResistance;
    S.SwitchVf=SPS.SwitchVf;
    S.SwitchType=SPS.SwitchType;
    S.SwitchGateInitialValue=SPS.SwitchGateInitialValue';
    S.EnableUseOfTLC=SPS.PowerguiInfo.EnableUseOfTLC;
    S.OutputsToResetToZero=SPS.YSwitchCurrent;
    S.NoErrorOnMaxIteration=SPS.NoErrorOnMaxIteration;
    S.Ts=SPS.PowerguiInfo.Ts;
    S.Interpolate=SPS.PowerguiInfo.Interpolate;
    S.SaveMatrices=SPS.PowerguiInfo.SaveMatrices;
    S.BufferSize=SPS.PowerguiInfo.BufferSize;
    S.TBEON=strcmp(SPS.PowerguiInfo.SolverType,'Tustin/Backward Euler (TBE)');


    switch SimulationType

    case 'Continuous'




        S.A=SPS.A;
        S.B=SPS.B;
        S.C=SPS.C;
        S.D=SPS.D;
        S.x0=SPS.x0;

    case 'Discrete'

        S.A=SPS.Adiscrete;
        S.B=SPS.Bdiscrete;
        S.C=SPS.Cdiscrete;
        S.D=SPS.Ddiscrete;
        S.x0=SPS.x0discrete;


        if~isempty(SPS.DSS)
            if~isempty(SPS.DSS.block)

                S.A=SPS.DSS.model.Ad_sort;
                S.B=SPS.DSS.model.Bd_sort;
                S.C=SPS.DSS.model.Cd_sort;
                S.D=SPS.DSS.model.Dd_sort;
                S.NonLinear_Inputs=SPS.DSS.model.Nonlinear_Inputs;
                S.NonLinear_Outputs=SPS.DSS.model.Nonlinear_Outputs;
                S.NonLinearDim=SPS.DSS.model.NonLinearDim;
                S.NonLinearxInit=SPS.DSS.model.NonLinearxInit;
                S.NonLinearIterative=SPS.DSS.model.NonLinearIterative;
                S.NonLinear_VI=SPS.DSS.model.NonLinear_VI;
                S.NonLinear_SizeVI=SPS.DSS.model.NonLinear_SizeVI;
                S.NonLinear_Method=SPS.DSS.model.NonLinear_Method;
                S.NonLinear_InitialOutputs=SPS.DSS.model.NonLinear_InitialOutputs;
                S.Nonlinear_Tolerance=double(str2num(SPS.PowerguiInfo.Nonlinear_Tolerance));
                S.nMaxIteration=double(str2num(SPS.PowerguiInfo.nMaxIteration));

                switch SPS.PowerguiInfo.ContinueOnMaxIteration
                case 'on'
                    S.ContinueOnMaxIteration=1;
                case 'off'
                    S.ContinueOnMaxIteration=0;
                end

            end
        end

    case 'SPID'

        BDK=ConvertForSFun(SPS);

        S.Mg=BDK.Mg;
        S.MgColNames=char(BDK.MgColNames);
        S.nb=BDK.nb;

        S.x0=SPS.x0spid;
        S.S=SPS;

        if length(SwTol)==length(S.SwitchResistance)
            S.SwitchTolerance=SwTol;
        else
            S.SwitchTolerance=SwTol*ones(size(S.SwitchResistance));
        end

    case 'Interpolate'










        I=eye(size(SPS.A));
        InvA=inv(I-SPS.A*S.Ts/2);
        Ad=InvA*(I+SPS.A*S.Ts/2);
        Bd=InvA*SPS.B*S.Ts/2;
        Cd=SPS.C;
        Dd=SPS.D;

        nswitch=length(SPS.SwitchType(SPS.SwitchType~=8));
        Yswitch=1./SPS.SwitchResistance(SPS.SwitchType~=8);

        D2=zeros(size(SPS.D,2),size(SPS.D,1));
        D2(1:nswitch,1:nswitch)=diag(Yswitch.*SPS.SwitchGateInitialValue(SPS.SwitchType~=8));

        Iu=eye(size(SPS.D,2),size(SPS.D,2));
        Dx=inv(Iu-D2*Dd);
        BdTr=Bd*Dx;
        DdTr=Dd*Dx;
        AdTr=Ad+BdTr*D2*Cd;
        CdTr=Cd+DdTr*D2*Cd;


        EdTr=inv(I-BdTr*D2*Cd);
        AdTr=EdTr*AdTr;
        BdTr=EdTr*BdTr;

        S.A=AdTr;
        S.B=BdTr;
        S.C=CdTr;
        S.D=DdTr;
        S.x0=SPS.x0;

        S.BridgeSrcV=SPS.BridgeSrcV;

    end