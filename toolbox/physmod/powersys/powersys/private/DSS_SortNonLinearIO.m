function SPS=DSS_SortNonLinearIO(SPS)





    for i=1:length(SPS.DSS.block)
        NonLinear_Inputs(i,1:size(SPS.DSS.block(i).inputs,2))=SPS.DSS.block(i).inputs;%#ok
        NonLinear_Outputs(i,1:size(SPS.DSS.block(i).outputs,2))=SPS.DSS.block(i).outputs;%#ok
    end

    [NOUTPUT,NINPUT]=size(SPS.Ddiscrete);
    N_NONLINEAR=size(NonLinear_Outputs,1);
    Ncol=size(NonLinear_Inputs,2);
    NonLinear_Inputs_Vec=reshape(NonLinear_Inputs',1,N_NONLINEAR*Ncol);
    Ncol=size(NonLinear_Outputs,2);
    NonLinear_Outputs_Vec=reshape(NonLinear_Outputs',1,N_NONLINEAR*Ncol);


    NonLinear_Inputs_Vec=NonLinear_Inputs_Vec(NonLinear_Inputs_Vec~=0);
    NonLinear_Outputs_Vec=NonLinear_Outputs_Vec(NonLinear_Outputs_Vec~=0);

    Index_ColNumber_BD=zeros(1,NINPUT);
    k=0;
    for i=1:NINPUT
        if~any(NonLinear_Inputs_Vec==i)
            k=k+1;
            Index_ColNumber_BD(k)=i;
        end
    end

    Index_ColNumber_BD(k+1:end)=NonLinear_Inputs_Vec;

    Index_RowNumber_CD=zeros(1,NOUTPUT);
    k=0;
    for i=1:NOUTPUT
        if~any(NonLinear_Outputs_Vec==i)
            k=k+1;
            Index_RowNumber_CD(k)=i;
        end
    end

    Index_RowNumber_CD(k+1:end)=NonLinear_Outputs_Vec;


    NonLinear_Inputs_New=NonLinear_Inputs;

    for iline=1:N_NONLINEAR
        for icol=1:size(NonLinear_Inputs,2)
            if NonLinear_Inputs(iline,icol)>0
                NonLinear_Inputs_New(iline,icol)=find(Index_ColNumber_BD==NonLinear_Inputs(iline,icol));
            end
        end
    end

    SPS.DSS.model.Nonlinear_Inputs=NonLinear_Inputs_New;


    NonLinear_Outputs_New=NonLinear_Outputs;

    for iline=1:N_NONLINEAR
        for icol=1:size(NonLinear_Outputs,2)
            if NonLinear_Outputs(iline,icol)>0
                NonLinear_Outputs_New(iline,icol)=find(Index_RowNumber_CD==NonLinear_Outputs(iline,icol));
            end
        end
    end

    SPS.DSS.model.Nonlinear_Outputs=NonLinear_Outputs_New;

    [~,SPS.DSS.model.reorderout.indices]=sort(Index_RowNumber_CD);
    SPS.DSS.model.reordersrc.indices=Index_ColNumber_BD;

    SPS.DSS.model.reordersrc.width=NINPUT;
    SPS.DSS.model.reorderout.width=NOUTPUT;


    SPS.DSS.model.Ad_sort=SPS.Adiscrete;
    SPS.DSS.model.Bd_sort=SPS.Bdiscrete(:,Index_ColNumber_BD);
    SPS.DSS.model.Cd_sort=SPS.Cdiscrete(Index_RowNumber_CD,:);
    SPS.DSS.model.Dd_sort=SPS.Ddiscrete(Index_RowNumber_CD,Index_ColNumber_BD);