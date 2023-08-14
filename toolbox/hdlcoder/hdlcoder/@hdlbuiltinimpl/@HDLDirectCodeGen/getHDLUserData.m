function hdldata=getHDLUserData(~,hC)












    if nargin<2||isempty(hC)
        error(message('hdlcoder:validate:invalidhdlargs'));
    end

    if~strcmp(hC.ClassName,'black_box_comp')
        error(message('hdlcoder:validate:invalidcomp'));
    end

    hdldata=hC.HDLUserData;
