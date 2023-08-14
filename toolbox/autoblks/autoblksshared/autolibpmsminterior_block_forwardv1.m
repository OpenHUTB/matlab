function[outData]=autolibpmsminterior_block_forwardv1(inData)



    outData.NewBlockPath='';
    outData.NewInstanceData=[];

    instanceData=inData.InstanceData;


    [InParameterNames{1:length(instanceData)}]=instanceData.Name;


    OutParameterNames={'ContentPreviewEnabled',...
    'port_config',...
    'sim_type',...
    'Ts',...
    'FilePath',...
    'P',...
    'Rs',...
    'Ldq',...
    'KConstText',...
    'KConst',...
    'mechanical',...
    'idq0',...
    'theta_init',...
    'omega_init',...
    'lambda_pm_calc',...
    'lambda_pm',...
    'Ke',...
    'Kt',...
    'RefBlkName',...
    'aMode'};


    outData.NewInstanceData(1).Name='ContentPreviewEnabled';
    outData.NewInstanceData(1).Value='off';

    outData.NewInstanceData(2).Name='port_config';
    outData.NewInstanceData(2).Value='Torque';

    outData.NewInstanceData(3).Name='sim_type';
    outData.NewInstanceData(3).Value='Continuous';

    outData.NewInstanceData(4).Name='Ts';
    outData.NewInstanceData(4).Value='0';

    outData.NewInstanceData(5).Name='FilePath';
    outData.NewInstanceData(5).Value='';

    outData.NewInstanceData(6).Name='P';
    outData.NewInstanceData(6).Value='4';

    outData.NewInstanceData(7).Name='Rs';
    outData.NewInstanceData(7).Value='0.2';

    outData.NewInstanceData(8).Name='Ldq';
    outData.NewInstanceData(8).Value='[0.0017 0.0017]';

    outData.NewInstanceData(9).Name='KConstText';
    outData.NewInstanceData(9).Value='Permanent flux linkage constant (lambda_pm):';

    outData.NewInstanceData(10).Name='KConst';
    outData.NewInstanceData(10).Value='0.2205';

    outData.NewInstanceData(11).Name='mechanical';
    outData.NewInstanceData(11).Value='[0.0027, 4.924e-4, 0]';

    outData.NewInstanceData(12).Name='idq0';
    outData.NewInstanceData(12).Value='[0 0]';

    outData.NewInstanceData(13).Name='theta_init';
    outData.NewInstanceData(13).Value='0';

    outData.NewInstanceData(14).Name='omega_init';
    outData.NewInstanceData(14).Value='0';

    outData.NewInstanceData(15).Name='lambda_pm_calc';
    outData.NewInstanceData(15).Value='0.2205';

    outData.NewInstanceData(16).Name='lambda_pm';
    outData.NewInstanceData(16).Value='0.2205';

    outData.NewInstanceData(17).Name='Ke';
    outData.NewInstanceData(17).Value='159.9771';

    outData.NewInstanceData(18).Name='Kt';
    outData.NewInstanceData(18).Value='1.323';

    outData.NewInstanceData(19).Name='RefBlkName';
    outData.NewInstanceData(19).Value='autolibpmsmexterior/Surface Mount PMSM';

    outData.NewInstanceData(20).Name='aMode';
    outData.NewInstanceData(20).Value='1';


    for index=1:1:length(InParameterNames)
        paramIdx=strcmp(OutParameterNames,InParameterNames(index));
        if any(paramIdx)
            outData.NewInstanceData(paramIdx).Name=inData.InstanceData(index).Name;
            outData.NewInstanceData(paramIdx).Value=inData.InstanceData(index).Value;
        end
    end


    outData.NewInstanceData(10).Name='KConst';
    outData.NewInstanceData(10).Value=outData.NewInstanceData(16).Value;


    outData.NewInstanceData(15).Name='lambda_pm_calc';
    outData.NewInstanceData(15).Value=outData.NewInstanceData(16).Value;


end




























































































































