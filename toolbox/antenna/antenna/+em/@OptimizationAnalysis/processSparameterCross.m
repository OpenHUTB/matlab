function rtn=processSparameterCross(obj,Type)







    switch Type
    case 'Constraint'
        sijVal=calcSparameter(obj,obj.OptimStruct.FrequencyRange);
        rtn=20*log10(sijVal);
    end

    function sReturn=calcSparameter(obj,BW)

        if isa(obj,'em.Array')

            s=sparameters(obj,BW,obj.OptimStruct.ReferenceImpedance);

            switch class(obj)
            case 'rectangularArray'
                l=prod(obj.Size);
            case{'circularArray','linearArray'}
                l=obj.NumElements;
            end

            sij=zeros(1,l);
            for i=1:l
                snj=zeros(1,l);
                for j=i+1:l
                    snj(j)=mean(abs(rfparam(s,i,j)));
                end
                snj=mean(snj);
                sij(i)=snj;
            end
            sReturn=mean(sij);

        end
    end
end