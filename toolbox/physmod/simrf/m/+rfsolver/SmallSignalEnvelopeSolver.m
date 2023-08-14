




classdef SmallSignalEnvelopeSolver<rfsolver.EnvelopeSolver

    properties

M

At
Af
isSteadyState

B

Freqs

SimFreqs

SimFreqsInd

SimFreqsHasDC

IsNDF2

XSS

USS
    end

    methods

        function o=SmallSignalEnvelopeSolver(dae,tones,harmonics,params)

            o@rfsolver.EnvelopeSolver(dae,tones,harmonics,params);
            o.Freqs=(o.freqs);
            if o.Parameters.AllSimFreqs
                o.SimFreqsInd=1:length(o.Freqs);
            else
                assert(all(ismember(o.Parameters.SimFreqs,o.Freqs)),'small signal frequencies should be contained in frequencies defined by tones and harmonics.');
                o.SimFreqsInd=find(ismember(abs(o.Freqs),o.Parameters.SimFreqs));

            end
            o.SimFreqs=o.Freqs(o.SimFreqsInd);
            o.SimFreqsHasDC=(o.SimFreqs(1)==0);

            fprintf('linear small-signal DAE has %d states, including %d frequency-domain states\n',dae.NumStates,dae.NumFreqStates);
            assert(o.Freqs(1)==0,'DC always included');
            assert(dae.Dae.NumModes==0,'linear model has minor modes');



            o.M=dae.TimeDomainMatrix('M');

            o.IsNDF2=strcmp(o.Parameters.HbIntegrationMethod,'ndf2');

        end

        function[X,SavedStates,success]=TakeStep(o,U,X_prev,U_prev,SavedStates,h,integration_method,isSteadyState)
            if isSteadyState

                [X,SavedStates,success]=TakeStep@rfsolver.EnvelopeSolver(o,U,X_prev,U_prev,SavedStates,h,integration_method,isSteadyState);
                o.isSteadyState=isSteadyState;
            else
                n_freq_equations=o.Dae.NumFreqEquations;
                n_delay_equations=o.Dae.NumDelayEquations;


                if isempty(o.isSteadyState)||o.isSteadyState~=isSteadyState
                    o.isSteadyState=isSteadyState;
                    o.Af=o.PickSimFreqs(o.Dae.MultipleFreqDomainDFX(o.Freqs,isSteadyState).',false,false).';
                    o.PopulateLinearMatrices(X_prev,U_prev,integration_method,n_freq_equations+n_delay_equations);
                    o.XSS=X_prev;



                    X_prev=0*X_prev;
                    o.Dae.History.initialize(X_prev);
                    o.Dae.Convolution=rfsolver.Convolution(h,o.Freqs,o.Dae,X_prev);
                    X_prev=o.PickSimFreqs(X_prev,false,true);


                    o.USS=U_prev;
                    U_prev=0*o.PickSimFreqs(U_prev,false,true);
                    if o.IsNDF2
                        X_prev2=0*X_prev;
                        X_prev3=0*X_prev;
                    end
                else
                    if o.IsNDF2
                        [X_prev2,X_prev3]=o.Extract(SavedStates);
                    end
                    U_prev=o.PickSimFreqs(U_prev-o.USS,false,true);
                    X_prev=o.PickSimFreqs(X_prev,false,true);
                end

                U=o.PickSimFreqs(U-o.USS,false,true);

                w=2*pi*o.SimFreqs;




                MXprev=o.M*X_prev;
                switch integration_method
                case 'be'
                    scale=1;
                    b=MXprev/h+reshape(cell2mat(o.B)*U(:),size(o.B{1,1},1),[]);
                case 'trap'
                    scale=0.5;
                    b=MXprev/h+reshape(cell2mat(o.B)*(U(:)+U_prev(:))/2+cell2mat(o.At)*X_prev(:)/2,size(o.B{1,1},1),[]);

                    for i=1+o.SimFreqsHasDC:length(w)
                        q=i+length(w)-1;
                        b(:,i)=b(:,i)+w(i)*MXprev(:,q)/2;
                        b(:,q)=b(:,q)-w(i)*MXprev(:,i)/2;
                    end
                case 'ndf2'
                    scale=3/5;
                    b=o.M/h*(3/2*X_prev-3/5*X_prev2+X_prev3/10)+3/5*reshape(cell2mat(o.B)*U(:),size(o.B{1,1},1),[]);
                otherwise
                    assert(false,'incorrect integration method');
                end











                Mfull=repmat({o.M},1,size(o.At,1));
                Jt=blkdiag(Mfull{:})/h-scale*cell2mat(o.At);
                J=Jt;

                rhs_delay=o.Dae.MultipleDelayF(o.Freqs,h);
                rhs_delay=o.PickSimFreqs(rhs_delay,false,true);

                if o.isSteadyState
                    rhs_freq=zeros(n_freq_equations,length(o.SimFreqs)*2-o.SimFreqsHasDC);
                else
                    rhs_freq=-o.Dae.MultipleConvolutionF;
                    rhs_freq=o.PickSimFreqs(rhs_freq,false,true);
                end
                rhs=b(:);

                if o.SimFreqsHasDC
                    Jdelay=o.Dae.FreqDomainDelayDXF(0,true,h);
                    J(size(o.M,1)+1-n_freq_equations-n_delay_equations:size(o.M,1)-n_delay_equations,1:size(o.M,2))=o.Af{1};
                    J(size(o.M,1)+1-n_delay_equations:size(o.M,1),1:size(o.M,2))=Jdelay;

                    rhs(size(o.M,1)+1-n_freq_equations-n_delay_equations:size(o.M,1)-n_delay_equations)=rhs_freq(:,1);
                    rhs(size(o.M,1)+1-n_delay_equations:size(o.M,1))=rhs_delay(:,1);
                end



                ssc_rf_log(1,'    Right Hand Side',b');
                ssc_rf_log(1,'    Right Hand Side, delay',rhs_delay');
                ssc_rf_log(1,'    Right Hand Side, convolution',rhs_freq');
                ssc_rf_log(2,'        Jacobian for frequency 0',full(J));




                NumStates=o.Dae.NumStates;
                for i=1+o.SimFreqsHasDC:length(w)
                    q=i+length(w)-o.SimFreqsHasDC;

                    wM=scale*w(i)*o.M;
                    Jdelay=o.Dae.FreqDomainDelayDXF(o.Freqs(i),false,h);

                    [Mi,Mj,wMv]=find(wM);
                    J=J+sparse(Mi+(i-1)*NumStates,Mj+(q-1)*NumStates,-wMv,size(J,1),size(J,2));
                    J=J+sparse(Mi+(q-1)*NumStates,Mj+(i-1)*NumStates,wMv,size(J,1),size(J,2));

                    if(n_freq_equations+n_delay_equations)>0
                        J((i-1)*NumStates+(NumStates+1-n_freq_equations-n_delay_equations:NumStates-n_delay_equations),(i-1)*NumStates+(1:NumStates))=o.Af{i}(1:n_freq_equations,1:NumStates);
                        J((i-1)*NumStates+(NumStates+1-n_delay_equations:NumStates),(i-1)*NumStates+(1:NumStates))=Jdelay(1:n_delay_equations,1:NumStates);
                        J((i-1)*NumStates+(NumStates+1-n_freq_equations-n_delay_equations:NumStates-n_delay_equations),(q-1)*NumStates+(1:NumStates))=o.Af{i}(1:n_freq_equations,NumStates+(1:NumStates));
                        J((i-1)*NumStates+(NumStates+1-n_delay_equations:NumStates),(q-1)*NumStates+(1:NumStates))=Jdelay(1:n_delay_equations,NumStates+(1:NumStates));
                        J((q-1)*NumStates+(NumStates+1-n_freq_equations-n_delay_equations:NumStates-n_delay_equations),(i-1)*NumStates+(1:NumStates))=o.Af{i}(n_freq_equations+(1:n_freq_equations),1:NumStates);
                        J((q-1)*NumStates+(NumStates+1-n_delay_equations:NumStates),(i-1)*NumStates+(1:NumStates))=Jdelay(n_delay_equations+(1:n_delay_equations),1:NumStates);
                        J((q-1)*NumStates+(NumStates+1-n_freq_equations-n_delay_equations:NumStates-n_delay_equations),(q-1)*NumStates+(1:NumStates))=o.Af{i}(n_freq_equations+(1:n_freq_equations),NumStates+(1:NumStates));
                        J((q-1)*NumStates+(NumStates+1-n_delay_equations:NumStates),(q-1)*NumStates+(1:NumStates))=Jdelay(n_delay_equations+(1:n_delay_equations),NumStates+(1:NumStates));

                        rhs((i-1)*NumStates+(NumStates+1-n_freq_equations-n_delay_equations:NumStates-n_delay_equations))=rhs_freq(:,i);
                        rhs((i-1)*NumStates+(NumStates+1-n_delay_equations:NumStates))=rhs_delay(:,i);
                        rhs((q-1)*NumStates+(NumStates+1-n_freq_equations-n_delay_equations:NumStates-n_delay_equations))=rhs_freq(:,q);
                        rhs((q-1)*NumStates+(NumStates+1-n_delay_equations:NumStates))=rhs_delay(:,q);
                    end
                end

                ssc_rf_log(2,sprintf('        Jacobian for frequency %g',o.Freqs(i)),full(J));

                res=J\rhs;
                X=o.XonAllFreqs(reshape(res,size(b)));

                if o.IsNDF2

                    X_prev_full=o.XonAllFreqs(X_prev);
                    X_prev2_full=o.XonAllFreqs(X_prev2);
                    SavedStates=[X_prev_full(:);X_prev2_full(:)];
                end

                ssc_rf_log(1,'    Solution',X');

                success=true;
            end
        end

        function PopulateLinearMatrices(o,X,U,method,NumofFreqDelayEq)
            x=o.Transform.ifft(X);
            u=o.Transform.ifft(U);
            switch method
            case 'be'
                scale=1;
            case 'trap'
                scale=0.5;
            case 'ndf2'
                scale=3/5;
            end
            DUF_time=o.Dae.MultipleTimeDomainDUF_negative(x,u,scale);
            DXF_time=o.Dae.MultipleTimeDomainDXF_negative(x,u,scale);
            DXF_time_for_FFT=-cell2mat(reshape(cellfun(@(x)reshape(x,[],1),DXF_time,'UniformOutput',false),1,[]));
            DXFfull_m=size(DXF_time_for_FFT,1);
            DXF_time_FFT=cellfun(@(x)o.PickSimFreqs(sparse(o.Transform.fftxifft(full(diag(x)))),true,true),...
            mat2cell(DXF_time_for_FFT,ones(1,DXFfull_m)),'UniformOutput',false);
            DXFfull_n=size(DXF_time_FFT{1},1);
            o.At=cellfun(@(x)sparse([reshape(x,size(DXF_time{1}));zeros(NumofFreqDelayEq,size(DXF_time{1},2))]),...
            squeeze(permute(mat2cell(reshape(full(cell2mat(DXF_time_FFT)),DXFfull_n,DXFfull_m,DXFfull_n),ones(1,DXFfull_n),DXFfull_m,ones(1,DXFfull_n)),[2,1,3])),'UniformOutput',false);

            DUF_time_for_FFT=-cell2mat(reshape(cellfun(@(x)reshape(x,[],1),DUF_time,'UniformOutput',false),1,[]));
            DUFfull_m=size(DUF_time_for_FFT,1);
            DUF_time_FFT=cellfun(@(x)o.PickSimFreqs(sparse(o.Transform.fftxifft(full(diag(x)))),true,true),...
            mat2cell(DUF_time_for_FFT,ones(1,DUFfull_m)),'UniformOutput',false);
            DUFfull_n=size(DUF_time_FFT{1},1);
            o.B=cellfun(@(x)sparse([reshape(x,size(DUF_time{1}));zeros(NumofFreqDelayEq,size(DUF_time{1},2))]),...
            squeeze(permute(mat2cell(reshape(full(cell2mat(DUF_time_FFT)),DUFfull_n,DUFfull_m,DUFfull_n),ones(1,DUFfull_n),DUFfull_m,ones(1,DUFfull_n)),[2,1,3])),'UniformOutput',false);
            o.M=[o.M;zeros(NumofFreqDelayEq,size(o.M,2))];
        end

        function matOut=PickSimFreqs(o,matIn,isMat,seperateIQmats)
            if~o.Parameters.AllSimFreqs
                indVec=o.SimFreqsInd;
                if seperateIQmats
                    indVec=[indVec;(length(o.Freqs)-1)+o.SimFreqsInd(1+o.SimFreqsHasDC:end)];
                end
                if~isMat
                    matOut=matIn(:,indVec);
                else
                    matOut=matIn(indVec,indVec);
                end
            else
                matOut=matIn;
            end
        end

        function Xout=XonAllFreqs(o,Xin)
            if~o.Parameters.AllSimFreqs
                Xout=0*o.XSS;
                indVec=[o.SimFreqsInd;(length(o.Freqs)-1)+o.SimFreqsInd(1+o.SimFreqsHasDC:end)];
                Xout(:,indVec)=Xin;
            else
                Xout=Xin;
            end
        end

        function n=NumStates(o)
            n=o.Dae.NumStates;
        end

        function[x2,x3]=Extract(o,SavedStates)
            n=o.NumStates;
            m=2*length(o.Freqs)-1;
            x2=o.PickSimFreqs(reshape(SavedStates(1:n*m),n,m),false,true);
            x3=o.PickSimFreqs(reshape(SavedStates(n*m+1:end),n,m),false,true);
        end





        function n=nSavedStates(o)
            n=numel(o.Evaluator.SavedStates);
        end










    end
end