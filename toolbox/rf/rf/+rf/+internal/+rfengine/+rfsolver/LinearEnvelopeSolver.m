









classdef LinearEnvelopeSolver<handle




    properties
Dae

M

At
Af
isSteadyState

B

F0t

Freqs
Parameters

IsNDF2
    end

    methods


        function o=LinearEnvelopeSolver(dae,freqs,params)
            o.Dae=dae;
            o.Freqs=freqs;
            o.Parameters=params;

            fprintf('linear DAE has %d states, including %d frequency-domain states\n',dae.NumStates,dae.NumFreqStates);







            o.M=dae.TimeDomainMatrix('M');
            o.B=dae.TimeDomainMatrix('DUF');





            o.At=dae.TimeDomainMatrix('DXF');




            F0=dae.Dae.F(dae.Dae.inputs);
            o.F0t=F0(dae.EquationInfo.Time,1);

            o.IsNDF2=strcmp(o.Parameters.HbIntegrationMethod,'ndf2');




        end















        function[X,SavedStates,success]=TakeStep(o,U,X_prev,U_prev,SavedStates,h,integration_method,isSteadyState)

            if o.IsNDF2
                [X_prev2,X_prev3]=o.Extract(SavedStates);
            end



            if isempty(o.isSteadyState)||o.isSteadyState~=isSteadyState
                o.isSteadyState=isSteadyState;
                o.Af=o.Dae.MultipleFreqDomainDFX(o.Freqs,isSteadyState);
            end

            w=2*pi*o.Freqs;




            MXprev=o.M*X_prev;
            switch integration_method
            case 'be'
                scale=1;
                b=MXprev/h+o.B*U;
            case 'trap'
                scale=0.5;
                b=MXprev/h+o.B*(U+U_prev)/2+o.At*X_prev/2;

                for i=2:length(w)
                    q=i+length(w)-1;
                    b(:,i)=b(:,i)+w(i)*MXprev(:,q)/2;
                    b(:,q)=b(:,q)-w(i)*MXprev(:,i)/2;
                end
            case 'ndf2'
                scale=3/5;
                b=o.M/h*(3/2*X_prev-3/5*X_prev2+X_prev3/10)+3/5*o.B*U;
            otherwise
                error('incorrect integration method')
            end




            b(:,1)=b(:,1)+scale*o.F0t;
            X=zeros(size(X_prev));



            Jt=o.M/h-scale*o.At;
            Jdelay=o.Dae.FreqDomainDelayDXF(0,true,h);
            J=[Jt;
            o.Af{1};
            Jdelay];

            rhs_delay=o.Dae.MultipleDelayF(o.Freqs,h);

            n_freq_equations=size(o.Af{1},1);
            if o.isSteadyState
                rhs_freq=zeros(n_freq_equations,length(o.Freqs)*2-1);
            else
                rhs_freq=-o.Dae.MultipleConvolutionF;
            end

            rhs=[b(:,1);
            rhs_freq(:,1);
            rhs_delay(:,1)];

            X(:,1)=J\rhs;













            NumStates=o.Dae.NumStates;
            for i=2:length(w)
                q=i+length(w)-1;

                wM=scale*w(i)*o.M;
                Jdelay=o.Dae.FreqDomainDelayDXF(o.Freqs(i),false,h);
                J=[Jt,-wM;
                wM,Jt;
                o.Af{i};
                Jdelay];



                rhs=[b(:,i);
                b(:,q);
                rhs_freq(:,i);
                rhs_freq(:,q);
                rhs_delay(:,i);
                rhs_delay(:,q)];

                res=J\rhs;

                X(:,i)=res(1:NumStates);
                X(:,q)=res(NumStates+1:end);
            end

            SavedStates=[];
            if o.IsNDF2
                SavedStates=[X_prev(:);X_prev2(:)];
            end



            success=true;
        end

        function n=NumStates(o)
            n=o.Dae.NumStates;
        end

        function[x2,x3]=Extract(o,SavedStates)
            n=o.NumStates;
            m=2*length(o.Freqs)-1;
            x2=reshape(SavedStates(1:n*m),n,m);
            x3=reshape(SavedStates(n*m+1:end),n,m);
        end

        function n=nSavedStates(o)
            if o.IsNDF2
                n=2*o.NumStates*(2*length(o.Freqs)-1);
            else
                n=0;
            end
        end

    end
end

