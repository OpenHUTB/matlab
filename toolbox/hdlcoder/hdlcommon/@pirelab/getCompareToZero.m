function hOutSignal=getCompareToZero(hN,hSignal,opName,outSigName,compName)







    if nargin<5
        compName=sprintf('%s_cmpto_0',hSignal.Name);
    end

    if nargin<4
        outSigName=sprintf('%s_is_not0',hSignal.Name);
    end

    if nargin<3
        opName='==';
    end

    if targetmapping.mode(hSignal)

        hOutSignal=targetmapping.getCompareToZero(hN,hSignal,opName,outSigName,compName);
    else
        hOutSignal=pircore.getCompareToZero(hN,hSignal,opName,outSigName,compName);
    end
