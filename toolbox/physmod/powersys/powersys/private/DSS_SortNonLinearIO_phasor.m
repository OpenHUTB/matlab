function SPS=DSS_SortNonLinearIO_phasor(SPS)

















    for i=1:length(SPS.DSS.block)
        NonLinear_Inputs(i,1:size(SPS.DSS.block(i).inputs,2))=SPS.DSS.block(i).inputs;
        NonLinear_Outputs(i,1:size(SPS.DSS.block(i).outputs,2))=SPS.DSS.block(i).outputs;
    end


    NINPUT=length(SPS.InputsNotDistLine);
    NOUTPUT=length(SPS.OutputsNotDistLine);
    N_NONLINEAR=size(NonLinear_Outputs,1);

    Ncol=size(NonLinear_Inputs,2);
    NonLinear_Inputs_Vec=reshape(NonLinear_Inputs',1,N_NONLINEAR*Ncol);
    Ncol=size(NonLinear_Outputs,2);
    NonLinear_Outputs_Vec=reshape(NonLinear_Outputs',1,N_NONLINEAR*Ncol);


    n=find(NonLinear_Inputs_Vec~=0);
    NonLinear_Inputs_Vec=NonLinear_Inputs_Vec(n);

    n=find(NonLinear_Outputs_Vec~=0);
    NonLinear_Outputs_Vec=NonLinear_Outputs_Vec(n);


    N_NonLinearInputs=length(NonLinear_Inputs_Vec);

    N_NonLinearOutputs=length(NonLinear_Outputs_Vec);




    Index_ColNumber_H=zeros(1,2*NINPUT);
    k=0;
    for i=1:2*NINPUT
        if~any(NonLinear_Inputs_Vec==i)
            k=k+1;
            Index_ColNumber_H(k)=i;
        end
    end
    Index_ColNumber_H(k+1:end)=NonLinear_Inputs_Vec;




    Index_RowNumber_H=zeros(1,2*NOUTPUT);
    k=0;
    for i=1:2*NOUTPUT
        if~any(NonLinear_Outputs_Vec==i)
            k=k+1;
            Index_RowNumber_H(k)=i;
        end
    end
    Index_RowNumber_H(k+1:end)=NonLinear_Outputs_Vec;



    NonLinear_Inputs_New=NonLinear_Inputs;
    Ncol=size(NonLinear_Inputs,2);
    for iline=1:N_NONLINEAR
        for icol=1:Ncol
            if NonLinear_Inputs(iline,icol)>0
                n=find(Index_ColNumber_H==NonLinear_Inputs(iline,icol));
                NonLinear_Inputs_New(iline,icol)=n;
            end
        end
    end

    SPS.DSS.model.NonLinear_Inputs=NonLinear_Inputs_New;


    NonLinear_Outputs_New=NonLinear_Outputs;
    Ncol=size(NonLinear_Outputs,2);
    for iline=1:N_NONLINEAR
        for icol=1:Ncol
            if NonLinear_Outputs(iline,icol)>0
                n=find(Index_RowNumber_H==NonLinear_Outputs(iline,icol));
                NonLinear_Outputs_New(iline,icol)=n;
            end
        end
    end

    SPS.DSS.model.NonLinear_Outputs=NonLinear_Outputs_New;

    SPS.DSS.model.Index_RowNumber_H=Index_RowNumber_H;
    SPS.DSS.model.Index_ColNumber_H=Index_ColNumber_H;


    SPS.DSS.model.reordersrc.indices=Index_ColNumber_H;
    SPS.DSS.model.reordersrc.width=2*NINPUT;

    [~,SPS.DSS.model.reorderout.indices]=sort(Index_RowNumber_H);
    SPS.DSS.model.reorderout.width=2*NOUTPUT;

