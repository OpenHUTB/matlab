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
        function o=EnvelopeEvaluator(dae,tones,transform,method,debugging)
            o.Dae=dae;
            o.Transform=transform;
            o.Freqs=transform.freqs(tones);
            o.DebuggingMode=debugging;

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
                o.SavedStates=zeros(o.Dae.NumTimeEquations,o.NumTimePoints);
            case 'ndf2'
                o.SavedStates=zeros(o.NumVariables,2*o.NumTimePoints);
            end
        end

































        function evaluate(o,X,evaluateJacobian,Xprev,h,U,States,method,isSteadyState)
            x=o.Transform.ifft(X);
            u=o.Transform.ifft(U);
            o.Timestep=h;



            if isempty(o.isSteadyState)||o.isSteadyState~=isSteadyState
                o.isSteadyState=isSteadyState;
                o.DXF_freq=o.Dae.MultipleFreqDomainDFX(o.Freqs,isSteadyState);
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




            dae=o.Dae;
            F_time=dae.MultipleTimeDomainF_negative(x,u);
            if evaluateJacobian

                [o.DXF_time,o.DXF_time_average]=dae.MultipleTimeDomainDXF_negative(x,u,scale);
                o.DXF_time_sum_abs=sparse(size(o.DXF_time{1},1),size(o.DXF_time{1},2));
                for i=1:o.NumTimePoints
                    o.DXF_time_sum_abs=o.DXF_time_sum_abs+abs(o.DXF_time{i});
                end
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




            freq_domain_residue=o.linear_freq_equations(X)+...
            o.convolution_residue;

            nDelay=o.Dae.NumDelayEquations;
            delay_history_residue=o.Dae.MultipleDelayF(o.Freqs,h);
            freq_domain_residue(end-nDelay+1:end,:)=freq_domain_residue(end-nDelay+1:end,:)-delay_history_residue;

            o.Residue=[residue;freq_domain_residue];




            ssc_rf_log(2,'    Right Hand Side, delay',delay_history_residue');
            ssc_rf_log(2,'    X time',x');
            ssc_rf_log(2,'    U time',u');
            zero_padding=zeros(size(x,1)-size(F_time,1),size(F_time,2));
            ssc_rf_log(2,'    F time',[-F_time;zero_padding]');
            ssc_rf_log(2,'    Residue',o.Residue');


            if(evaluateJacobian)
                preconditioner=cell(numFreqs,1);

                M=o.M;

                At=o.DXF_time_average+M/h;




                preconditioner{1}=[At;
                o.DXF_freq{1};
                o.DXF_delay{1}];

                ssc_rf_log(3,'        Preconditioner for frequency 0',full(preconditioner{1}));





                w=2*pi*o.Freqs;
                n=o.Dae.NumFreqEquations;
                m=o.Dae.NumDelayEquations;
                for i=2:numFreqs
                    wM=w(i)*M*scale;
                    B=o.DXF_freq{i};
                    C=o.DXF_delay{i};

                    preconditioner{i}=[At,-wM;
                    B(1:n,:);
                    C(1:m,:);
                    wM,At;
                    B(n+1:end,:);
                    C(m+1:end,:)];

                    ssc_rf_log(3,sprintf('        Preconditioner for frequency %g',o.Freqs(i)),full(preconditioner{i}));
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
            y=zeros(o.Dae.NumTimeEquations,o.NumTimePoints);
            G=o.DXF_time;
            for i=1:size(y,2)
                if use_average_DXF
                    y(:,i)=o.DXF_time_average*x(:,i);
                else
                    y(:,i)=G{i}*x(:,i);
                end
            end
            Y=o.Transform.fft(y);



            Y=Y+o.M*X/o.Timestep+o.jwM(X*o.IntegrationScale);
            Y=[Y;o.linear_freq_equations(X)];


            Y=Y(:);
        end




        function d=jwM(o,X)





            MX=o.M*X;
            w=2*pi*o.Freqs;
            d=zeros(size(MX));

            for i=2:length(w)
                q=i+length(w)-1;

                d(:,i)=-w(i)*MX(:,q);
                d(:,q)=w(i)*MX(:,i);
            end
        end








        function d=linear_freq_equations(o,X)
            nf=o.Dae.NumFreqEquations;
            nd=o.Dae.NumDelayEquations;
            d=zeros(nf+nd,size(X,2));

            B=o.DXF_freq;
            C=o.DXF_delay;
            d(:,1)=[B{1};C{1}]*X(:,1);

            nFreqs=length(o.Freqs);
            for i=2:nFreqs
                q=i+nFreqs-1;

                x=[X(:,i);X(:,q)];
                freq_residue=B{i}*x;
                delay_residue=C{i}*x;

                d(:,i)=[freq_residue(1:nf);
                delay_residue(1:nd)];
                d(:,q)=[freq_residue(nf+1:end);
                delay_residue(nd+1:end)];
            end
        end


        function d=eps_linear_freq_equations(o,X)
            nf=o.Dae.NumFreqEquations;
            nd=o.Dae.NumDelayEquations;
            d=zeros(nf+nd,size(X,2));

            B=o.DXF_freq;
            C=o.DXF_delay;
            d(:,1)=abs([B{1};C{1}])*eps(X(:,1));

            nFreqs=length(o.Freqs);
            for i=2:nFreqs
                q=i+nFreqs-1;

                x=eps([X(:,i);X(:,q)]);
                freq_residue=abs(B{i})*x;
                delay_residue=abs(C{i})*x;

                d(:,i)=[freq_residue(1:nf);
                delay_residue(1:nd)];
                d(:,q)=[freq_residue(nf+1:end);
                delay_residue(nd+1:end)];
            end
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



            for i=2:numFreqs
                q=i+numFreqs-1;

                res=o.Preconditioner{i}\[X(:,i);X(:,q)];

                Y(:,i)=res(1:o.NumVariables);
                Y(:,q)=res(o.NumVariables+1:end);
            end
            Y=Y(:);

            warning(w3.state,w3.identifier);
            warning(w2.state,w2.identifier);
            warning(w1.state,w1.identifier);
        end

        function x=reshape(o,x)
            assert(numel(x)==o.NumVariables*o.NumTimePoints,'x size is not correct')
            x=reshape(x,o.NumVariables,o.NumTimePoints);
        end



        function[J,M]=dump_jacobian(o)
            n=o.NumVariables*o.NumTimePoints;
            x=zeros(n,1);
            J=zeros(n,n);
            M=zeros(n,n);

            for i=1:n
                x(i)=1;
                J(:,i)=o.jacobian_multiply(x);
                M(:,i)=o.precondition(x);
                x(i)=0;
            end
            J=sparse(J);
            M=sparse(M);
        end


        function test_linearized_jacobian(o)
            n=o.NumVariables*o.NumTimePoints;
            x=zeros(n,1);
            use_linearized_jacobian=true;
            for i=1:n
                x(i)=1;
                y=o.precondition(x);
                z=o.jacobian_multiply(y,use_linearized_jacobian);
                assert(norm(z-x)<1e-6,'Linearized jacobian and preconditioner are different for i=%d',i);
                x(i)=0;
            end
        end

    end
end