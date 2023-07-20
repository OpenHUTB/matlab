function[visibility]=set_group_visibility(sigCnt,grpCnt)







    if(nargin<2)
        error(message('sigbldr_ui:set_group_visibility:badNumOfInputArguments'))
    end

    maxDisp=15;

    if sigCnt<=maxDisp
        visibility=ones(sigCnt,grpCnt);
    else
        visibility=[ones(maxDisp,grpCnt);zeros(sigCnt-maxDisp,grpCnt)];
    end

end

