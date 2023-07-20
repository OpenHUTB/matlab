function[data,minVal,maxVal]=scaleFrequencyInputSpectrogram(this,data)





    minVal=1e-300;
    maxVal=1e300;

    if(strcmp(this.pInputUnits,this.pSpectrumUnits)||strcmp(this.pSpectrumUnits,'Auto'))&&...
        this.pReferenceLoad==1
        return;
    end

    switch this.pInputUnits

    case 'dBm'
        switch this.pSpectrumUnits
        case 'dBW'
            data=data-30;
            minVal=minVal-30;
            maxVal=maxVal-30;
        case 'Watts'
            data=10.^((data-30)/10);
            minVal=10.^((minVal-30)/10);
            maxVal=10.^((maxVal-30)/10);
        case 'Vrms'
            data_w=10.^((data-30)/10);
            data=sqrt(data_w./this.pReferenceLoad+eps(0));

            minVal_w=10.^((minVal-30)/10);
            minVal=sqrt(minVal_w./this.pReferenceLoad+eps(0));

            maxVal_w=10.^((maxVal-30)/10);
            maxVal=sqrt(maxVal_w./this.pReferenceLoad+eps(0));
        case 'dBV'
            data_w=10.^((data-30)/10);
            data_v=sqrt(data_w/this.pReferenceLoad+eps(0));
            data=20.*log10(data_v+eps(0));

            minVal_w=10.^((minVal-30)/10);
            minVal_v=sqrt(minVal_w/this.pReferenceLoad+eps(0));
            minVal=20.*log10(minVal_v+eps(0));

            maxVal_w=10.^((maxVal-30)/10);
            maxVal_v=sqrt(maxVal_w/this.pReferenceLoad+eps(0));
            maxVal=20.*log10(maxVal_v+eps(0));
        end

    case 'dBW'
        switch this.pSpectrumUnits
        case 'dBm'
            data=data+30;
            minVal=minVal+30;
            maxVal=maxVal+30;
        case 'Watts'
            data=10.^(data./10);
            minVal=10.^(minVal./10);
            maxVal=10.^(maxVal./10);
        case 'Vrms'
            data_w=10.^(data./10);
            data=sqrt(data_w./this.pReferenceLoad+eps(0));

            minVal_w=10.^(minVal./10);
            minVal=sqrt(minVal_w./this.pReferenceLoad+eps(0));

            maxVal_w=10.^(maxVal./10);
            maxVal=sqrt(maxVal_w./this.pReferenceLoad+eps(0));
        case 'dBV'
            data_w=10.^(data./10);
            data_v=sqrt(data_w./this.pReferenceLoad+eps(0));
            data=20.*log10(data_v+eps(0));

            minVal_w=10.^(minVal./10);
            minVal_v=sqrt(minVal_w./this.pReferenceLoad+eps(0));
            minVal=20.*log10(minVal_v+eps(0));

            maxVal_w=10.^(maxVal./10);
            maxVal_v=sqrt(maxVal_w./this.pReferenceLoad+eps(0));
            maxVal=20.*log10(maxVal_v+eps(0));
        end

    case 'Watts'
        switch this.pSpectrumUnits
        case 'dBm'
            data=10.*log10(data+eps(0))+30;
            minVal=10.*log10(minVal+eps(0))+30;
            maxVal=10.*log10(maxVal+eps(0))+30;
        case 'dBW'
            data=10.*log10(data+eps(0));
            minVal=10.*log10(minVal+eps(0));
            maxVal=10.*log10(maxVal+eps(0));
        case 'Vrms'
            data=sqrt(data./this.pReferenceLoad+eps(0));
            minVal=sqrt(minVal./this.pReferenceLoad+eps(0));
            maxVal=sqrt(maxVal./this.pReferenceLoad+eps(0));
        case 'dBV'
            data_v=sqrt(data./this.pReferenceLoad+eps(0));
            data=20.*log10(data_v+eps(0));

            minVal_v=sqrt(minVal./this.pReferenceLoad+eps(0));
            minVal=20.*log10(minVal_v+eps(0));

            maxVal_v=sqrt(maxVal./this.pReferenceLoad+eps(0));
            maxVal=20.*log10(maxVal_v+eps(0));
        end

    case 'Vrms'
        switch this.pSpectrumUnits
        case 'dBm'
            data_w=(data.^2)./this.pReferenceLoad;
            data=10.*log10(data_w+eps(0))+30;

            minVal_w=(minVal.^2)./this.pReferenceLoad;
            minVal=10.*log10(minVal_w+eps(0))+30;

            minVal_w=(minVal.^2)./this.pReferenceLoad;
            minVal=10.*log10(minVal_w+eps(0))+30;
        case 'dBW'
            data_w=(data.^2)./this.pReferenceLoad;
            data=10.*log10(data_w+eps(0));

            minVal_w=(minVal.^2)./this.pReferenceLoad;
            minVal=10.*log10(minVal_w+eps(0));

            maxVal_w=(maxVal.^2)./this.pReferenceLoad;
            maxVal=10.*log10(maxVal_w+eps(0));
        case 'Watts'
            data=(data.^2)./this.pReferenceLoad;
            minVal=(minVal.^2)./this.pReferenceLoad;
            maxVal=(maxVal.^2)./this.pReferenceLoad;
        case 'dBV'
            data=20.*log10(data+eps(0));
            minVal=20.*log10(minVal+eps(0));
            maxVal=20.*log10(maxVal+eps(0));
        end

    case 'dBV'
        switch this.pSpectrumUnits
        case 'dBm'
            data_v=10.^(data./20);
            data_w=(data_v.^2)./this.pReferenceLoad;
            data=10.*log10(data_w+eps(0))+30;

            minVal_v=10.^(minVal./20);
            minVal_w=(minVal_v.^2)./this.pReferenceLoad;
            minVal=10.*log10(minVal_w+eps(0))+30;

            maxVal_v=10.^(maxVal./20);
            maxVal_w=(maxVal_v.^2)./this.pReferenceLoad;
            maxVal=10.*log10(maxVal_w+eps(0))+30;
        case 'dBW'
            data_v=10.^(data./20);
            data_w=(data_v.^2)./this.pReferenceLoad;
            data=10.*log10(data_w+eps(0));

            minVal_v=10.^(minVal./20);
            minVal_w=(minVal_v.^2)./this.pReferenceLoad;
            minVal=10.*log10(minVal_w+eps(0));

            maxVal_v=10.^(maxVal./20);
            maxVal_w=(maxVal_v.^2)./this.pReferenceLoad;
            maxVal=10.*log10(maxVal_w+eps(0));
        case 'Watts'
            data_v=10.^(data./20);
            data=(data_v.^2)./this.pReferenceLoad;

            minVal_v=10.^(minVal./20);
            minVal=(minVal_v.^2)./this.pReferenceLoad;

            maxVal_v=10.^(maxVal./20);
            maxVal=(maxVal_v.^2)./this.pReferenceLoad;
        case 'Vrms'
            data=10.^(data./20);
            minVal=10.^(minVal./20);
            maxVal=10.^(maxVal./20);
        end
    end

