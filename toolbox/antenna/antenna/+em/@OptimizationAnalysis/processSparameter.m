function rtn=processSparameter(obj,Type)







    switch Type
    case 'Max'
        s11=calcSparameter(obj,obj.OptimStruct.FrequencyRange);
        rtn=s11;
    case 'Min'
        BW=obj.OptimStruct.FrequencyRange;
        interceptCentFreq=find(obj.OptimStruct.FrequencyRange==obj.OptimStruct.CenterFrequency);
        if any(interceptCentFreq)
            BW(interceptCentFreq(1))=[];
        end
        s11=calcSparameter(obj,BW);
        sCenter=sparameters(obj,obj.OptimStruct.CenterFrequency);
        s11Center=rfparam(sCenter,1,1);
        rtn=mean(abs(s11))-2*abs(s11Center);
    case 'Constraint'
        s11=calcSparameter(obj,obj.OptimStruct.FrequencyRange);
        rtn=20*log10(s11);
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
            snn=zeros(1,l);
            for i=1:l
                snn(i)=mean(abs(rfparam(s,i,i)));
            end
            sReturn=mean(snn);
        elseif isa(obj,'em.Antenna')||...
            isa(obj,'em.BackingStructure')

            s=sparameters(obj,BW,obj.OptimStruct.ReferenceImpedance);
            sReturn=mean(abs(rfparam(s,1,1)));

        end
    end
end