function[inprate,outprate]=gettbclkrate(this)













    rcf=this.RateChangeFactors;

    if all(rcf(:,1)>=rcf(:,2))
        if strcmpi(this.Implementation,'localmultirate')


            clkreqs=analyzeImplementation(this);
            [~,~,~,inprate,outprate]=this.designTimingController(clkreqs);
        else
            rcf(end,:)=[ceil(rcf(end,1)/rcf(end,2)),1];
            inprate=prod(rcf(:,1))*hdlgetparameter('foldingfactor');
            outprate=hdlgetparameter('foldingfactor')/inprate;
        end
    elseif all(rcf(:,1)<=rcf(:,2))
        if strcmpi(this.Implementation,'localmultirate')


            clkreqs=analyzeImplementation(this);
            [~,~,~,inprate,outprate]=this.designTimingController(clkreqs);
        else
            inprate=hdlgetparameter('foldingfactor');
            outprate=1;
        end
    else
        error(message('HDLShared:hdlfilter:unsupportedMfiltCascade'));
    end


