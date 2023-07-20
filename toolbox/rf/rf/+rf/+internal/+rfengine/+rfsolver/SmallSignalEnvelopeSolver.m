classdef SmallSignalEnvelopeSolver<...
    rf.internal.rfengine.rfsolver.EnvelopeSolver





    properties
M
At
Af
isSteadyState
B
Jfull
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
            o@rf.internal.rfengine.rfsolver.EnvelopeSolver(...
            dae,tones,harmonics,params);
            o.Freqs=(o.freqs);
            if o.Parameters.AllSimFreqs
                o.SimFreqsInd=1:length(o.Freqs);
            else




                o.SimFreqsInd=...
                find(ismember(abs(o.Freqs),o.Parameters.SimFreqs));



            end
            o.SimFreqs=o.Freqs(o.SimFreqsInd);
            o.SimFreqsHasDC=(o.SimFreqs(1)==0);

            if params.HbVerbose
                fprintf(['linear small-signal DAE has %d states, '...
                ,'including %d frequency-domain states\n'],...
                dae.NumStates,dae.NumFreqStates);
            end





            o.M=dae.TimeDomainMatrix('M');

            o.IsNDF2=strcmp(o.Parameters.HbIntegrationMethod,'ndf2');
        end

        function[X,SavedStates,success]=...
            TakeStep(o,U,Xprev,Uprev,SavedStates,h,method,isSteadyState)
            if isSteadyState

                [X,SavedStates,success]=...
                TakeStep@rf.internal.rfengine.rfsolver.EnvelopeSolver(...
                o,U,Xprev,Uprev,SavedStates,h,method,isSteadyState);
                o.isSteadyState=isSteadyState;
            else
                nF=o.Dae.NumFreqEquations;
                nD=o.Dae.NumDelayEquations;


                if isempty(o.isSteadyState)||...
                    o.isSteadyState~=isSteadyState
                    o.isSteadyState=isSteadyState;

                    o.Af=o.PickSimFreqs(...
                    o.Dae.MultipleFreqDomainDFX(...
                    o.Freqs,isSteadyState).',false,false).';
                    o.PopulateLinearMatrices(Xprev,Uprev,method,nF+nD);
                    o.XSS=Xprev;
                    Xprev=0*Xprev;
                    o.Dae.History.initialize(Xprev);

                    o.Dae.Convolution=...
                    rf.internal.rfengine.rfsolver.Convolution(...
                    h,o.Freqs,o.Dae,Xprev);
                    Xprev=o.PickSimFreqs(Xprev,false,true);


                    o.USS=Uprev;
                    Uprev=0*o.PickSimFreqs(Uprev,false,true);
                    if o.IsNDF2
                        Xprev2=0*Xprev;
                        Xprev3=0*Xprev;
                    end


                    Mfull=repmat({o.M},1,size(Xprev,2));
                    scale=1;
                    Jt=blkdiag(Mfull{:})/h-scale*o.At;
                    J=Jt;
                    if o.SimFreqsHasDC

                        Jdelay=o.Dae.FreqDomainDelayDXF(0,true,h);
                        [mM,nM]=size(o.M);
                        J(mM+1-nF-nD:mM-nD,1:nM)=o.Af{1};
                        J(mM+1-nD:mM,1:nM)=Jdelay;
                    end

                    w=2*pi*o.SimFreqs;
                    nS=o.Dae.NumStates;
                    [mJ,nJ]=size(J);
                    [Mi,Mj,Mv]=find(o.M);
                    if nF+nD>0
                        for i=1+o.SimFreqsHasDC:length(w)
                            q=i+length(w)-o.SimFreqsHasDC;

                            wMv=scale*w(i)*Mv;
                            J=J+...
                            sparse(Mi+(i-1)*nS,Mj+(q-1)*nS,-wMv,mJ,nJ)+...
                            sparse(Mi+(q-1)*nS,Mj+(i-1)*nS,wMv,mJ,nJ);


                            Jdelay=...
                            o.Dae.FreqDomainDelayDXF(o.Freqs(i),false,h);

                            J((i-1)*nS+(nS+1-nF-nD:nS-nD),(i-1)*nS+(1:nS))=...
                            o.Af{i}(1:nF,1:nS);

                            J((i-1)*nS+(nS+1-nD:nS),(i-1)*nS+(1:nS))=...
                            Jdelay(1:nD,1:nS);

                            J((i-1)*nS+(nS+1-nF-nD:nS-nD),(q-1)*nS+(1:nS))=...
                            o.Af{i}(1:nF,nS+(1:nS));

                            J((i-1)*nS+(nS+1-nD:nS),(q-1)*nS+(1:nS))=...
                            Jdelay(1:nD,nS+(1:nS));

                            J((q-1)*nS+(nS+1-nF-nD:nS-nD),(i-1)*nS+(1:nS))=...
                            o.Af{i}(nF+(1:nF),1:nS);

                            J((q-1)*nS+(nS+1-nD:nS),(i-1)*nS+(1:nS))=...
                            Jdelay(nD+(1:nD),1:nS);

                            J((q-1)*nS+(nS+1-nF-nD:nS-nD),(q-1)*nS+(1:nS))=...
                            o.Af{i}(nF+(1:nF),nS+(1:nS));

                            J((q-1)*nS+(nS+1-nD:nS),(q-1)*nS+(1:nS))=...
                            Jdelay(nD+(1:nD),nS+(1:nS));
                        end
                    else
                        for i=1+o.SimFreqsHasDC:length(w)
                            q=i+length(w)-o.SimFreqsHasDC;

                            wMv=scale*w(i)*Mv;
                            J=J+...
                            sparse(Mi+(i-1)*nS,Mj+(q-1)*nS,-wMv,mJ,nJ)+...
                            sparse(Mi+(q-1)*nS,Mj+(i-1)*nS,wMv,mJ,nJ);
                        end
                    end

                    o.Jfull=J;
                else
                    if o.IsNDF2

                        [Xprev2,Xprev3]=o.Extract(SavedStates);
                    end
                    Uprev=o.PickSimFreqs(Uprev-o.USS,false,true);
                    Xprev=o.PickSimFreqs(Xprev,false,true);
                end

                U=o.PickSimFreqs(U-o.USS,false,true);

                w=2*pi*o.SimFreqs;


                MXprev=o.M*Xprev;
                switch method
                case 'be'

                    b=MXprev/h+reshape(o.B*U(:),size(Xprev,1),[]);
                case 'trap'

                    b=MXprev/h+reshape(o.B*(U(:)+Uprev(:))/2+...
                    o.At*Xprev(:)/2,size(Xprev,1),[]);


                    for i=1+o.SimFreqsHasDC:length(w)
                        q=i+length(w)-1;
                        b(:,i)=b(:,i)+w(i)*MXprev(:,q)/2;
                        b(:,q)=b(:,q)-w(i)*MXprev(:,i)/2;
                    end
                case 'ndf2'

                    b=o.M/h*(3/2*Xprev-3/5*Xprev2+Xprev3/10)+...
                    3/5*reshape(o.B*U(:),size(Xprev,1),[]);
                otherwise

                end












                rhs_delay=o.Dae.MultipleDelayF(o.Freqs,h);
                rhs_delay=o.PickSimFreqs(rhs_delay,false,true);

                if o.isSteadyState
                    rhsFreq=zeros(nF,numel(o.SimFreqs)*2-o.SimFreqsHasDC);
                else

                    rhsFreq=-o.Dae.MultipleConvolutionF;
                    rhsFreq=o.PickSimFreqs(rhsFreq,false,true);
                end
                rhs=b(:);

                if o.SimFreqsHasDC

                    rhs(mM+1-nF-nD:mM-nD)=rhsFreq(:,1);

                    rhs(mM+1-nD:mM)=rhs_delay(:,1);
                end


                if nF+nD>0
                    nS=o.Dae.NumStates;
                    i=(1+o.SimFreqsHasDC:length(w)).';
                    q=i+length(w)-o.SimFreqsHasDC;

                    rhs((i-1)*nS+(nS+1-nF-nD:nS-nD))=rhsFreq(:,i);

                    rhs((i-1)*nS+(nS+1-nD:nS))=rhs_delay(:,i);

                    rhs((q-1)*nS+(nS+1-nF-nD:nS-nD))=rhsFreq(:,q);

                    rhs((q-1)*nS+(nS+1-nD:nS))=rhs_delay(:,q);
                end

                res=o.Jfull\rhs;
                X=o.XonAllFreqs(reshape(res,size(b)));

                if o.IsNDF2

                    Xprev_full=o.XonAllFreqs(Xprev);
                    Xprev2_full=o.XonAllFreqs(Xprev2);
                    SavedStates=[Xprev_full(:);Xprev2_full(:)];
                end

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




            n=o.Transform.nTimepoints;
            r=((1:n)+n*(0:n-1));
            A=zeros(n,n);

            e1=eye((n-1)/2);
            iT=conj([2,zeros(1,n-1);...
            [zeros(n-1,1),[e1;flipud(e1)],-1j*[e1;-flipud(e1)]]])/2;
            T=2*iT'-[[1,zeros(1,n-1)];zeros(n-1,n)];
            iT=sparse(iT);
            T=sparse(T);

            [DXF_time_for_FFT,idxJ]=...
            o.Dae.MultipleTimeDomainDXF(x,u,scale);
            i=[];
            j=[];
            v=[];
            if o.Parameters.AllSimFreqs
                for k=idxJ.'
                    A(r)=DXF_time_for_FFT(:,k);
                    [iF,jF,vF]=o.fftxifft(A,iT,T,n);
                    i=[i;iF+n*(jF-1)];%#ok<AGROW>
                    j=[j;k*ones(size(iF))];%#ok<AGROW>
                    v=[v;vF];%#ok<AGROW>
                end
            else
                for k=idxJ.'
                    A(r)=DXF_time_for_FFT(:,k);
                    [iF,jF,vF]=o.fftxifft(A,iT,T,n);
                    iFF=o.PickSimFreqs(sparse(iF,jF,vF,n,n),true,true);
                    [iF,jF,vF]=find(iFF);
                    i=[i;iF+n*(jF-1)];%#ok<AGROW>
                    j=[j;k*ones(size(iF))];%#ok<AGROW>
                    v=[v;vF];%#ok<AGROW>
                end
            end
            j1=mod(j-1,o.Dae.NumTimeEquations)+1;
            j2=floor((j-1)/o.Dae.NumTimeEquations)+1;
            i1=mod(i-1,n)+1;
            i2=floor((i-1)/n)+1;
            o.At=sparse(...
            j1+o.Dae.NumStates*(i1-1),j2+o.Dae.NumStates*(i2-1),v,...
            n*o.Dae.NumStates,n*o.Dae.NumStates);

            [DUF_time_for_FFT,idxJ]=...
            o.Dae.MultipleTimeDomainDUF(x,u,scale);
            i=[];
            j=[];
            v=[];
            if o.Parameters.AllSimFreqs
                for k=idxJ.'
                    A(r)=DUF_time_for_FFT(:,k);
                    [iF,jF,vF]=o.fftxifft(A,iT,T,n);
                    i=[i;iF+n*(jF-1)];%#ok<AGROW>
                    j=[j;k*ones(size(iF))];%#ok<AGROW>
                    v=[v;vF];%#ok<AGROW>
                end
            else
                for k=idxJ.'
                    A(r)=DUF_time_for_FFT(:,k);
                    [iF,jF,vF]=o.fftxifft(A,iT,T,n);
                    iFF=o.PickSimFreqs(sparse(iF,jF,vF,n,n),true,true);
                    [iF,jF,vF]=find(iFF);
                    i=[i;iF+n*(jF-1)];%#ok<AGROW>
                    j=[j;k*ones(size(iF))];%#ok<AGROW>
                    v=[v;vF];%#ok<AGROW>
                end
            end
            j1=mod(j-1,o.Dae.NumTimeEquations)+1;
            j2=floor((j-1)/o.Dae.NumTimeEquations)+1;
            i1=mod(i-1,n)+1;
            i2=floor((i-1)/n)+1;
            o.B=sparse(...
            j1+o.Dae.NumStates*(i1-1),j2+o.Dae.NumInputs*(i2-1),v,...
            n*o.Dae.NumStates,n*o.Dae.NumInputs);

            o.M=[o.M;zeros(NumofFreqDelayEq,size(o.M,2))];
        end

        function[i,j,v]=fftxifft(~,x,iT,T,m)

            iFF=ifft(fft(x,[],1),[],2);
            out=real(T*(iFF*iT));
            ao=abs(out);
            [i,j]=find(ao>=100*eps*max(ao,[],'all'));
            v=reshape(out(i+m*(j-1)),[],1);
        end

        function matOut=PickSimFreqs(o,matIn,isMat,separateIQmats)
            if~o.Parameters.AllSimFreqs
                indVec=o.SimFreqsInd;
                if separateIQmats
                    indVec=[indVec;...
                    (length(o.Freqs)-1)+...
                    o.SimFreqsInd(1+o.SimFreqsHasDC:end)];
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
                indVec=[o.SimFreqsInd;...
                (length(o.Freqs)-1)+...
                o.SimFreqsInd(1+o.SimFreqsHasDC:end)];
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
            x2=o.PickSimFreqs(reshape(SavedStates(1:n*m),n,m),...
            false,true);
            x3=o.PickSimFreqs(reshape(SavedStates(n*m+1:end),n,m),...
            false,true);
        end



        function n=nSavedStates(o)
            n=numel(o.Evaluator.SavedStates);
        end
    end
end
