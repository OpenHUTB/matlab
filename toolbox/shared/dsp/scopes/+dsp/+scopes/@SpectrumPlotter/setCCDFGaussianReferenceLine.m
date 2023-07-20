function setCCDFGaussianReferenceLine(this,flag)



    if(flag)
        addCCDFGaussianReferenceLine(this);
        this.CCDFGaussianReferenceFlag=true;
    else
        this.CCDFGaussianReferenceFlag=false;
        if~isempty(this.CCDFGaussianReferenceLine)
            delete(this.CCDFGaussianReferenceLine);
            this.CCDFGaussianReferenceLine=[];
        end
    end
end
