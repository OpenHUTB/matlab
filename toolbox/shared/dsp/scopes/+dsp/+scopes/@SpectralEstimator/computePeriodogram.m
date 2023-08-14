function P=computePeriodogram(obj,x)




    x=bsxfun(@times,x,obj.pWindowData);
    if obj.pDataWrapFlag

        x=wrapData(obj,x);
    end

    X=fft(x,obj.pNFFT,1);


    P=real(X.*conj(X))/obj.pWindowPower;
end
