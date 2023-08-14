function hdlcoder_license_checkout




    licenseAvailable=(license('checkout','Simulink_HDL_Coder')&&...
    license('checkout','MATLAB_Coder'));

    if~licenseAvailable

        error(message('HDLShared:hdldialog:nolicenseavailable'));
    end