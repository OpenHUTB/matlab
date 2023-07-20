classdef EnvelopeEvaluator<handle




    properties
Dae
Freqs

Residue
MaxAbsX

Timestep
IntegrationScale
isSteadyState

DUF_time
DXF_time
DXF_time_average
DXF_time_sum_abs
DXF_freq


DXF_delay

Preconditioner

M




SavedStates
SavingMethod

NumVariables
NumTimePoints
FullPreconditionerMatricies


Transform

DebuggingMode
    end

    methods
        function o=EnvelopeEvaluator(dae,tones,transform,method,debug)
            o.Dae=dae;
            o.Transform=transform;
            o.Freqs=transform.freqs(tones);
            o.DebuggingMode=debug;

            o.NumVariables=dae.NumStates;
            o.NumTimePoints=transform.nTimepoints;

            o.M=dae.TimeDomainMatrix('M');


            o.FullPreconditionerMatricies=o.NumVariables<50;
            if o.FullPreconditionerMatricies
                o.M=full(o.M);
            end


            o.DXF_delay=cell(length(o.Freqs),1);

            o.MaxAbsX=zeros(o.NumVariables,o.NumTimePoints);

            o.SavingMethod=method;
            switch o.SavingMethod
            case 'trap'

                o.SavedStates=...
                zeros(o.Dae.NumTimeEquations,o.NumTimePoints);
            case 'ndf2'

                o.SavedStates=...
                zeros(o.NumVariables,2*o.NumTimePoints);
            end
        end
































        function evaluate(o,X,evalJ,Xprev,h,U,States,method,isSteadyState)
            x=o.Transform.ifft(X);
            u=o.Transform.ifft(U);
            o.Timestep=h;



            if isempty(o.isSteadyState)||o.isSteadyState~=isSteadyState
                o.isSteadyState=isSteadyState;

                o.DXF_freq=...
                o.Dae.MultipleFreqDomainDFX(o.Freqs,isSteadyState);
            end

            [Fprev,Xprev2,Xprev3]=o.ExtractFromSavedStates(States);

            switch method
            case 'be'
                scale=1;
            case 'trap'

                scale=0.5;
            case 'ndf2'
                scale=3/5;
            end
            o.IntegrationScale=scale;


            if evalJ
                [o.DXF_time,o.DXF_time_average,o.DXF_time_sum_abs,F_time]=...
                o.Dae.MultipleTimeDomainDXFandF_negative(x,u,scale);
            else
                F_time=o.Dae.MultipleTimeDomainF_negative(x,u);
            end




            o.MaxAbsX=max(abs(X),o.MaxAbsX);
            switch o.SavingMethod
            case 'trap'
                o.SavedStates=F_time;
            case 'ndf2'
                o.SavedStates=[Xprev,Xprev2];
            end

            if strcmp(method,'trap')
                F_time=F_time+Fprev;
            end


            residue=o.Transform.fft(F_time)*scale;


            if strcmp(method,'ndf2')
                residue=residue+o.M*(X-3/2*Xprev+3/5*Xprev2-Xprev3/10)/h;
            else
                residue=residue+o.M*(X-Xprev)/h;
            end


            if strcmp(method,'trap')
                residue=residue+o.jwM((X+Xprev)/2);
            else
                residue=residue+o.jwM(X)*scale;
            end





            numFreqs=o.Transform.nFreqs;
            for i=1:numFreqs
                isDC=i==1;

                o.DXF_delay{i}=o.Dae.FreqDomainDelayDXF(o.Freqs(i),isDC,h);
            end



            freqDomainResidue=o.linear_freq_equations(X)+...
            o.convolution_residue;

            nDelay=o.Dae.NumDelayEquations;

            delayHistoryResidue=o.Dae.MultipleDelayF(o.Freqs,h);
            freqDomainResidue(end-nDelay+1:end,:)=...
            freqDomainResidue(end-nDelay+1:end,:)-delayHistoryResidue;

            o.Residue=[residue;freqDomainResidue];


            if evalJ
                preconditioner=cell(numFreqs,1);


                At=o.DXF_time_average+o.M/h;


                preconditioner{1}=...
                decomposition([At;o.DXF_freq{1};o.DXF_delay{1}]);




                w=2*pi*o.Freqs;
                n=o.Dae.NumFreqEquations;
                m=o.Dae.NumDelayEquations;
                for i=2:numFreqs
                    wM=w(i)*o.M*scale;
                    B=o.DXF_freq{i};
                    C=o.DXF_delay{i};

                    preconditioner{i}=...
                    decomposition([At,-wM;B(1:n,:);C(1:m,:);...
                    wM,At;B(n+1:end,:);C(m+1:end,:)]);
                end

                o.Preconditioner=preconditioner;
            end


            if o.DebuggingMode
                o.test_linearized_jacobian;
            end
        end

        function[f,x2,x3]=ExtractFromSavedStates(o,States)

            f=[];
            x2=[];
            x3=[];
            switch o.SavingMethod
            case 'trap'

                f=reshape(States,o.Dae.NumTimeEquations,o.NumTimePoints);
            case 'ndf2'
                n=o.NumVariables;
                m=o.NumTimePoints;
                x2=reshape(States(1:n*m),n,m);
                x3=reshape(States(n*m+1:end),n,m);
            end
        end

        function Y=jacobian_multiply(o,X,varargin)
            X=reshape(X,o.NumVariables,o.NumTimePoints);

            use_average_DXF=false;
            if~isempty(varargin)
                use_average_DXF=varargin{1};
            end



            x=o.Transform.ifft(X);
            if use_average_DXF
                y=o.DXF_time_average*x;
            else
                y=reshape(o.DXF_time*x(:),o.Dae.NumTimeEquations,[]);
            end
            Y=o.Transform.fft(y);




            Y=Y+o.M*X/o.Timestep+o.jwM(X*o.IntegrationScale);

            Y=[Y;o.linear_freq_equations(X)];


            Y=Y(:);
        end


        function d=jwM(o,X)



            MX=o.M*X;
            w=2*pi*o.Freqs.';
            d=zeros(size(MX));


            nw=length(w);
            i=(2:nw);
            d(:,2:end)=[-w(i).*MX(:,i+nw-1),w(i).*MX(:,i)];
        end






        function d=linear_freq_equations(o,X)
            nf=o.Dae.NumFreqEquations;
            nd=o.Dae.NumDelayEquations;
            d=zeros(nf+nd,size(X,2));

            B=o.DXF_freq;
            C=o.DXF_delay;
            d(:,1)=[B{1};C{1}]*X(:,1);

            nFreqs=length(o.Freqs);
            i=(2:nFreqs);
            x=[X(:,i);X(:,i+nFreqs-1)];
            freq_residue=zeros(size(B{2},1),nFreqs-1);
            delay_residue=zeros(size(C{2},1),nFreqs-1);

            for k=1:nFreqs-1
                freq_residue(:,k)=B{k+1}*x(:,k);
                delay_residue(:,k)=C{k+1}*x(:,k);
            end
            d(:,2:end)=[freq_residue(1:nf,:),freq_residue(nf+1:end,:);
            delay_residue(1:nd,:),delay_residue(nd+1:end,:)];
        end

        function d=convolution_residue(o)
            nf=o.Dae.NumFreqEquations;
            nd=o.Dae.NumDelayEquations;
            num_freqs=length(o.Freqs);
            d=zeros(nf+nd,2*num_freqs-1);
            if o.isSteadyState

                return;
            end

            d(1:nf,:)=o.Dae.MultipleConvolutionF;
        end



        function Y=precondition(o,X)
            X=reshape(X,o.NumVariables,o.NumTimePoints);
            numFreqs=length(o.Freqs);
            Y=zeros(size(X));

            lastwarn('');
            w1=warning('off','MATLAB:singularMatrix');
            w2=warning('off','MATLAB:illConditionedMatrix');
            w3=warning('off','MATLAB:nearlySingularMatrix');


            Y(:,1)=o.Preconditioner{1}\X(:,1);



            Xi=X(:,2:numFreqs);
            Xq=X(:,(2:numFreqs)+numFreqs-1);
            Xcomb=[Xi;Xq];
            res=zeros(2*size(Y,1),numFreqs-1);
            for i=1:numFreqs-1
                res(:,i)=o.Preconditioner{i+1}\Xcomb(:,i);
            end
            Y(:,2:end)=...
            [res(1:o.NumVariables,:),res(o.NumVariables+1:end,:)];
            Y=Y(:);

            warning(w3.state,w3.identifier)
            warning(w2.state,w2.identifier)
            warning(w1.state,w1.identifier)
        end

        function x=reshape(o,x)


            x=reshape(x,o.NumVariables,o.NumTimePoints);
        end


        function test_linearized_jacobian(o)
            n=o.NumVariables*o.NumTimePoints;
            x=zeros(n,1);

            for i=1:n
                x(i)=1;




                x(i)=0;
            end
        end
    end
end
