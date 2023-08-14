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



            o.nFreqs=size(o.FreqHarmonics,1);
            o.nTimepoints=o.nFreqs*2-1;
        end

        function f=freqs(o,tones)
            f=o.FreqHarmonics*tones(:);
        end

        function x=ifft(o,X)

            X=[X(:,1)*2,X(:,2:o.nFreqs)+1j*X(:,o.nFreqs+1:end)];

            X=[X,conj(X(:,end:-1:2))];
            x=ifft(X,[],2,'symmetric')*o.nTimepoints/2;
        end

        function X=fft(o,x)

            X=fft(x,[],2);
            X=X(:,1:o.nFreqs)/o.nTimepoints*2;

            X=[X(:,1)/2,real(X(:,2:end)),imag(X(:,2:end))];
        end




        function X=generateIQ(o,harmonics,values)
            X=zeros(length(o.Freqs),1);
            index=harmonics2index(o,harmonics);

            X(index(index>0))=values(index>0);
            X(-index(index<0))=conj(values(index<0));
        end

        function index=harmonics2index(o,harmonics)
            index=harmonics*o.MappedTones';
            index=index+sign(index)+(index==0);



        end

        function disp_nonzeros(o,X)

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
