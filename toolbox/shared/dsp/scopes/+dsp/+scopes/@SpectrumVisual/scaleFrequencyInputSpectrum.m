function data=scaleFrequencyInputSpectrum(this,data)




    if(strcmp(this.pInputUnits,this.pSpectrumUnits)||strcmp(this.pSpectrumUnits,'Auto'))&&...
        this.pReferenceLoad==1
        return;
    end

    switch this.pInputUnits

    case 'dBm'
        switch this.pSpectrumUnits
        case 'dBW'
            data=data-30;
        case 'Watts'
            data=10.^((data-30)/10);
        case 'Vrms'
            data_w=10.^((data-30)/10);
            data=sqrt(data_w./this.pReferenceLoad+eps(0));
        case 'dBV'
            data_w=10.^((data-30)/10);
            data_v=sqrt(data_w/this.pReferenceLoad+eps(0));
            data=20.*log10(data_v+eps(0));
        end

    case 'dBW'
        switch this.pSpectrumUnits
        case 'dBm'
            data=data+30;
        case 'Watts'
            data=10.^(data./10);
        case 'Vrms'
            data_w=10.^(data./10);
            data=sqrt(data_w./this.pReferenceLoad+eps(0));
        case 'dBV'
            data_w=10.^(data./10);
            data_v=sqrt(data_w./this.pReferenceLoad+eps(0));
            data=20.*log10(data_v+eps(0));
        end

    case 'Watts'
        switch this.pSpectrumUnits
        case 'dBm'
            data=10.*log10(data+eps(0))+30;
        case 'dBW'
            data=10.*log10(data+eps(0));
        case 'Vrms'
            data=sqrt(data./this.pReferenceLoad+eps(0));
        case 'dBV'
            data_v=sqrt(data./this.pReferenceLoad+eps(0));
            data=20.*log10(data_v+eps(0));
        end

    case 'Vrms'
        switch this.pSpectrumUnits
        case 'dBm'
            data_w=(data.^2)./this.pReferenceLoad;
            data=10.*log10(data_w+eps(0))+30;
        case 'dBW'
            data_w=(data.^2)./this.pReferenceLoad;
            data=10.*log10(data_w+eps(0));
        case 'Watts'
            data=(data.^2)./this.pReferenceLoad;
        case 'dBV'
            data=20.*log10(data+eps(0));
        end

    case 'dBV'
        switch this.pSpectrumUnits
        case 'dBm'
            data_v=10.^(data./20);
            data_w=(data_v.^2)./this.pReferenceLoad;
            data=10.*log10(data_w+eps(0))+30;
        case 'dBW'
            data_v=10.^(data./20);
            data_w=(data_v.^2)./this.pReferenceLoad;
            data=10.*log10(data_w+eps(0));
        case 'Watts'
            data_v=10.^(data./20);
            data=(data_v.^2)./this.pReferenceLoad;
        case 'Vrms'
            data=10.^(data./20);
        end
    end