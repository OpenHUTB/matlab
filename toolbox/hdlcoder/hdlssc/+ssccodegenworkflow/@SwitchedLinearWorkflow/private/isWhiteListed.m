function boolFlag=isWhiteListed(blk)




    fullBlkName=blk.object;
    blkMask=get_param(fullBlkName,'MaskObject');
    blkType=blkMask.Type;

    switch blkType
    case 'Nonlinear Inductor'
        param_opt=get_param(fullBlkName,'parameterization_option');
        interp_opt=get_param(fullBlkName,'interpolation_option');
        if(strcmp(param_opt,'3')&&strcmp(interp_opt,'1'))
            boolFlag=true;
        else
            boolFlag=false;
        end

    otherwise
        boolFlag=false;
    end

end