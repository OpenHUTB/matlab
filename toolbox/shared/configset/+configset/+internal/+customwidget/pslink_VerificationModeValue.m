function out=pslink_VerificationModeValue(cs,name,direction,widgetVals)




    if direction==0
        if pslink.util.Helper.isProverAvailable()
            out={cs.get_param(name)};
        else
            out={'BugFinder'};
        end
    elseif direction==1
        out=widgetVals{1};
    end

