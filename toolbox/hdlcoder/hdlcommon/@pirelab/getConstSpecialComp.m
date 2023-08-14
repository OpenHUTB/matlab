function hBlackBoxComp=getConstSpecialComp(hN,hOutSignals,constValue,compName)




    if nargin<4
        compName='const';
    end


    hBlackBoxComp=hN.addComponent('black_box_comp','emission',0,0);

    hBlackBoxComp.addOutputPort('const_out');

    hOutSig=hOutSignals(1);
    hOutSig.addDriver(hBlackBoxComp,0);


    if hdlgetparameter('isverilog')
        hOutSig.VType(pirgetvtype(hOutSig));
    end


    params={};


    hBlackBoxImpl=hdldefaults.ConstantSpecialHDLEmission;
    hBlackBoxImpl.setImplParams({...
    'Value',constValue,...
    });


    firstArgs={hBlackBoxImpl,hBlackBoxComp};
    userData.CodeGenFunction='emit';
    userData.CodeGenParams={firstArgs{:},params{:}};
    userData.generateSLBlockFunction='generateSLBlock';
    userData.generateSLBlockParams=firstArgs;
    hBlackBoxComp.ImplementationData=userData;


    hBlackBoxComp.SimulinkHandle=-1;
    hBlackBoxComp.Name=compName;


