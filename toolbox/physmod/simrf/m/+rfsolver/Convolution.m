
classdef Convolution<handle
    properties
ImpulseResponses
History
    end

    methods




        function o=Convolution(step,carrier_freqs,dae,X)
            [variables,tau,variableToShift]=dae.ConvolutionVariables;
            num_variables=length(tau);

            if num_variables==0
                o.History=rfsolver.History(step,0,[],[]);
                o.ImpulseResponses=zeros(0,length(carrier_freqs),0);
                return;
            end

            num_samples=floor(tau/step+0.5);
            num_samples=min(num_samples,2048);
            num_samples=max(num_samples,1);

            num_samples_max=max(num_samples);
            assert(all(num_samples_max>0&num_samples_max<1e5),'impulse response is too short/long');

            ifftlen=2^ceil(log2(num_samples_max));

            if ifftlen==1
                freq_range=0;
            else
                freq_range=((-ifftlen/2):(ifftlen/2-1))/(ifftlen*step);
            end

            impulse=zeros(num_variables,length(carrier_freqs),num_samples_max);

            for i=1:length(carrier_freqs)
                f=freq_range+carrier_freqs(i);

                values=zeros(length(tau),length(f));
                for j=1:length(f)
                    v=dae.ConvolutionValues(abs(f(j)));
                    if f(j)<0
                        v=conj(v);
                    end
                    values(:,j)=v;
                end

                imp=rfsolver.ImpulseResponse(step,num_samples,carrier_freqs(i),f,values,variableToShift);

                impulse(:,i,:)=imp;
            end

            o.ImpulseResponses=impulse;
            history_lengths=ones(size(variables))*step*ifftlen;
            o.History=rfsolver.History(step,length(carrier_freqs),variables,history_lengths);
            o.History.initialize(X);
        end

        function v=DFX_values(o)
            if isempty(o.ImpulseResponses)
                v=[];
            else
                v=o.ImpulseResponses(:,:,1);
            end
        end

        function v=Convolve(o)
            if isempty(o.ImpulseResponses)
                num_freqs=size(o.ImpulseResponses,2);
                v=zeros(1,num_freqs);
            else
                v=o.History.convolve(o.ImpulseResponses);
            end
        end

    end
end