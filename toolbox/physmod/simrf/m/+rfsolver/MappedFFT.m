classdef MappedFFT
    properties(SetAccess=private)
NumHarmonics
FreqHarmonics

nFreqs
nTimepoints
    end

    properties
MappedTones
    end

    methods
        function o=MappedFFT(harmonics)

            ntones=length(harmonics);

            o.NumHarmonics=harmonics(:)';


            allfreqs=prod(2*harmonics+1);
            nfreqs=(allfreqs-1)/2+1;
            K=zeros(nfreqs,ntones);
            x=(nfreqs:allfreqs)'-1;
            for j=1:ntones

                y=2*harmonics(j)+1;
                n=floor(x/y);
                K(:,j)=x-n*y-harmonics(j);
                x=n;
            end


            o.FreqHarmonics=K;


            mapped_tones=cumprod([1,2*harmonics(:)'+1]);
            o.MappedTones=mapped_tones(1:end-1);
            mapped_freqs=K*o.MappedTones';

            assert(all(mapped_freqs'==0:nfreqs-1),'incorrect frequency mapping');

            o.nFreqs=size(o.FreqHarmonics,1);
            o.nTimepoints=o.nFreqs*2-1;
        end

        function f=freqs(o,tones)
            f=o.FreqHarmonics*tones(:);
        end

        function x=ifft(o,X)
            assert(size(X,2)==o.nTimepoints,'incorrect X size');
            X=[X(:,1)*2,X(:,2:o.nFreqs)+1j*X(:,o.nFreqs+1:end)];

            X=[X,conj(X(:,end:-1:2))];
            x=ifft(X,[],2,'symmetric')*o.nTimepoints/2;
        end

        function X=fft(o,x)
            assert(size(x,2)==o.nTimepoints,'incorrect x size');
            X=fft(x,[],2);
            X=X(:,1:o.nFreqs)/o.nTimepoints*2;

            X=[X(:,1)/2,real(X(:,2:end)),imag(X(:,2:end))];
        end


















        function AFxiFiA=fftxifft(o,x)
            n=o.nTimepoints;
            assert(size(x,2)==n,'incorrect x size');
            Fx=fft(x,[],1);
            FxiF=ifft(Fx,[],2);

            iA=conj([[2,zeros(1,n-1)];[zeros(n-1,1),[eye((n-1)/2);flipud(eye((n-1)/2))],-1j*[eye((n-1)/2);-flipud(eye((n-1)/2))]]])/2;

            A=2*iA'-[[1,zeros(1,n-1)];zeros(n-1,n)];

            FxiFiA=FxiF*iA;
            AFxiFiA=real(A*FxiFiA);
        end




        function X=generateIQ(o,harmonics,values)
            X=zeros(length(o.Freqs),1);
            index=harmonics2index(o,harmonics);
            assert(length(unique(abs(index)))==length(index));
            X(index(index>0))=values(index>0);
            X(-index(index<0))=conj(values(index<0));
        end

        function index=harmonics2index(o,harmonics)
            index=harmonics*o.MappedTones';
            index=index+sign(index)+(index==0);
            h=o.FreqHarmonics(abs(index),:);
            test=all((h==harmonics)')|all((h==-harmonics)');
            assert(all(test));
        end

        function disp_nonzeros(o,X)
            assert(size(X,1)==size(o.Freqs,1));
            nonzeros=find(abs(X)>sum(abs(X))*sqrt(eps));
            fprintf('\n');
            for i=nonzeros'
                fprintf('harmonics: [');
                fprintf('%d ',o.FreqHarmonics(i,:));
                fprintf('\b], value: [%f,%fi]\n',real(X(i)),imag(X(i)));
            end
        end
    end
end

