classdef PassivityCalculator







    properties(Constant)
        DefaultThreshold=1+1000*eps
    end

    methods(Static)
        function result=ispassive(s_data,thresh)






            cntr=0;
            result=true;
            nfreq=size(s_data,3);
            while result&&(cntr<nfreq)
                cntr=cntr+1;
                result=rf.internal.PassivityCalculator.isSingleFrequencyPassive(s_data(:,:,cntr),thresh);
            end
        end

        function idx=findNonPassiveIndices(s_params,thresh)






            nfreq=size(s_params,3);
            TF=true(1,nfreq);
            for n=1:nfreq
                TF(n)=~rf.internal.PassivityCalculator.isSingleFrequencyPassive(s_params(:,:,n),thresh);
            end
            idx=find(TF);
        end

        function s_params=makeImpedanceReal(s_params,z0)








            idx=find((imag(z0)~=0)|(real(z0)<0));
            if~isempty(idx)
                s_params(:,:,idx)=s2s(s_params(:,:,idx),z0(idx),50);
            end
        end

        function result=isSingleFrequencyPassive(s_data,thresh)

            result=norm(s_data,2)<=thresh;
        end
    end

end