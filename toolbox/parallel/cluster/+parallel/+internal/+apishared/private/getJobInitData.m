function data=getJobInitData(job)










    assert(isa(job,'parallel.Job'),...
    'init data must be called with a job as the first input');
    persistent plainTextForInteractiveJob;
    persistent plainTextForBatchJob;




    builtin('license','checkout','distrib_computing_toolbox');

    if isempty(plainTextForInteractiveJob)




        if system_dependent('isdmlworker')
            inUse=license('inuse');
            clientProducts={inUse.feature}.';
            if isempty(clientProducts)
                error(message('parallel:job:FailedToGetLicensedProducts'));
            end
            disabledBatchProducts=iGetDisabledProducts;


            plainTextForBatchJob=iMakePlainText(clientProducts,disabledBatchProducts);
            plainTextForInteractiveJob=plainTextForBatchJob;
        else

            clientProducts=system_dependent('lmfeaturelist',2);
            if isempty(clientProducts)
                error(message('parallel:job:FailedToGetLicensedProducts'));
            end

            [disabledBatchProducts,disabledInteractiveProducts]=iGetDisabledProducts;

            plainTextForInteractiveJob=iMakePlainText(clientProducts,disabledInteractiveProducts);
            plainTextForBatchJob=iMakePlainText(clientProducts,disabledBatchProducts);
        end
    end




    if job.pIsMatlabPoolJob&&job.pIsInteractivePool
        plainText=plainTextForInteractiveJob;
    else
        plainText=plainTextForBatchJob;
    end









    s=RandStream('mt19937ar','seed',sum(100*clock));

    KEY_LENGTH=100;

    key=randi(s,[0,255],1,KEY_LENGTH,'uint8');
    numelPlainText=numel(plainText);
    cypherText=zeros(1,numelPlainText,'uint8');

    for i=1:KEY_LENGTH:numelPlainText
        textStart=i;
        textEnd=min(numelPlainText,textStart+KEY_LENGTH-1);
        keyStart=1;
        keyEnd=textEnd-textStart+1;
        cypherText(textStart:textEnd)=bitxor(plainText(textStart:textEnd),key(keyStart:keyEnd));
    end
    data=[key,cypherText];


    if system_dependent('isdmlworker')
        plainTextForInteractiveJob=[];
        plainTextForBatchJob=[];
    end

    function[disabledBatchProducts,disabledInteractiveProducts]=iGetDisabledProducts






        disabledInteractiveProducts={'Excel_Link';
        'Compiler';
        'MATLAB_Excel_Builder';
        'MATLAB_COM_Builder';
        'MATLAB_Builder_for_Java';
        'MATLAB_Builder_for_dot_Net';
        'MATLAB_Web_Server';
        'MATLAB_Runtime_Server';
        'Cert_Kit_IEC';
        'Qual_Kit_DO';
        'Simulink_Compiler';
        };

        disabledInteractiveProducts=iAddStudentVersionsToList(disabledInteractiveProducts);

        disabledBatchProducts={'Real-Time_Workshop';
        'RTW_Embedded_Coder';
        'MATLAB_Coder';
        'Simulink_Design_Verifier';
        'XPC_Target';
        'XPC_Embedded_Option';
        'Filter_Design_HDL_Coder';
        'Simulink_HDL_Coder';
        'Simulink_PLC_Coder';
        'GPU_Coder';
        'Simulink_Code_Inspector';
        };

        disabledBatchProducts=[disabledInteractiveProducts;...
        iAddStudentVersionsToList(disabledBatchProducts)];



        if isdeployed
            disabledDeployedProducts={'SIMULINK'
'Extend_Symbolic_Toolbox'
'Symbolic_Toolbox'
'MBC_Toolbox'
'Robust_Toolbox'
'SimBiology'
'SystemTest'
'Autosar_Blockset'
'Aerospace_Blockset'
'DDS_Blockset'
'Dial_and_Gauge_Blocks'
'RF_Blockset'
'LTE_HDL_Toolbox'
'Mixed_Signal_Blockset'
'Motor_Control_Blockset'
'Powertrain_Blockset'
'Real-Time_Win_Target'
'SimDriveline'
'SimEvents'
'SimElectronics'
'SimHydraulics'
'SimMechanics'
'Simscape'
'Simscape_Battery'
'Power_System_Blocks'
'Simulink_Control_Design'
'Fixed-Point_Blocks'
'Simulink_Param_Estimation'
'SIMULINK_Report_Gen'
'EDA_Simulator_Link'
'NCD_Toolbox'
'Simulink_Requirements'
'Simulink_Coverage'
'Simulink_Design_Optim'
'Simulink_Test'
'SL_Verification_Validation'
'SOC_Blockset'
'Stateflow'
'System_Composer'
'Vehicle_Dynamics_Blockset'
            };


            disabledInteractiveProducts=[disabledBatchProducts;...
            iAddStudentVersionsToList(disabledDeployedProducts)];
            disabledBatchProducts=disabledInteractiveProducts;
        end

        function plainText=iMakePlainText(clientProducts,disabledProducts)

            found=ismember(lower(clientProducts),lower(disabledProducts));

            clientProducts(found)=[];
            assert(~isempty(clientProducts),'List of licensed products was empty.');

            clientProducts=string(clientProducts);

            sessionKey='';
            publicKey='';
            if isdeployed
                [sessionKey,publicKey]=getmcrappkeys();
            end
            sector=getSetSector();
            initData={isdeployed,sessionKey,publicKey,sector,clientProducts};

            plainText=distcompserialize(initData);


            function list=iAddStudentVersionsToList(list)
                list=[list;strcat('SR_',list)];
