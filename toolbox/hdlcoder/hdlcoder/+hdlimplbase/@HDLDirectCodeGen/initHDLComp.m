function initHDLComp(this,hC,Name,HDLComp,BlockParam,input,output)




    params={};

    if isa(HDLComp,'hdlimplbase.HDLDirectCodeGen')
        if isa(HDLComp,'hdldefaults.HDLC')
            BlockParam.component=HDLComp.component;
            firstArgs={HDLComp,hC,BlockParam.component};
        else
            firstArgs={HDLComp,hC};
        end

        userData.CodeGenParams={firstArgs{:},params{:}};
        userData.CodeGenFunction=HDLComp.CodeGenFunction;

        userData.generateSLBlockFunction=HDLComp.generateSLBlockFunction;
        this.setCompIoPortNames(hC,HDLComp);
    else
        firstArgs={this,hC};
        userData.CodeGenParams={firstArgs{:},params{:}};
        userData.CodeGenFunction=HDLComp;

        userData.generateSLBlockFunction='';

    end

    userData.generateSLBlockParams=firstArgs;

    hC.ImplementationData=userData;

    hC.Name=Name;


    setHDLUserData(this,hC,BlockParam);


    this.connectHDLBlk(hC,input,output);
