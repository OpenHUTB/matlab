function codegendir=hdlGetCodegendir(forceFilterMode)


    if nargin==0
        hdlcd=which('hdlcurrentdriver');


        forceFilterMode=isempty(hdlcd)||...
        isempty(strfind(hdlcd,['hdlcoder',filesep,'hdlcommon',filesep,'hdlcurrentdriver']));
    end

    if forceFilterMode==true
        codegendir=hdlgetparameter('codegendir');
    else
        hDrv=hdlcurrentdriver;
        if isempty(hDrv)
            codegendir=hdlgetparameter('codegendir');
        else
            try
                codegendir=hDrv.hdlGetCodegendir;
            catch me
                codegendir=hdlgetparameter('codegendir');
            end
        end
    end
end
