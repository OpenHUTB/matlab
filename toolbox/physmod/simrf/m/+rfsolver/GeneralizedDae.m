















classdef GeneralizedDae<handle

    properties
Dae
EquationInfo
VariableInfo
DelayInfo


NumStates
NumInputs

NumFreqStates
NumTimeEquations
NumFreqEquations
NumDelayEquations

History
Convolution





ConvolutionPattern
    end

    methods




        function o=GeneralizedDae(dae)
            o.Dae=dae;

            domain={dae.EquationData.domain};
            equations.Time=logical(strcmp(domain,'TIME'));
            equations.FreqReal=logical(strcmp(domain,'FREQUENCY_REAL'));
            equations.FreqImag=logical(strcmp(domain,'FREQUENCY_IMAG'));
            equations.Complex=logical(strcmp(domain,'COMPLEX'));
            equations.Freq=equations.FreqReal|equations.FreqImag;
            equations.Delay=logical(strcmp(domain,'DELAY'));

            assert(sum(equations.Time+equations.Freq+equations.Delay)+sum(strcmp(domain,'COMPLEX'))==length(domain),'unknown equation type');
            assert(sum(equations.FreqReal)==sum(equations.FreqImag),'number of real- and imag- frequency-domain equations does not match');
            assert(sum(equations.FreqReal)==sum(equations.Complex),'number of real- and complex- frequency-domain equations does not match');






            inputs=dae.inputs;
            inputs.T=0.0;
            Y0=dae.Y(inputs);
            inputs.T=realmax;
            Y1=dae.Y(inputs);
            DTF=full(rfsolver.MakeMatrix(dae,'DTF'));
            assert(((~any(Y1-Y0))&&(~any(DTF(equations.Time)))),'Model contains SimRF blocks that include time explicitly. Time dependency can only be introduced via SimRF sources.');






            tau=DTF(equations.Complex);

            DXF=full(rfsolver.MakeMatrix(dae,'DXF'));
            DUF=full(rfsolver.MakeMatrix(dae,'DUF'));
            complex=DXF(equations.Complex,:);





            real_index=cell(1,size(complex,1));
            imag_index=real_index;
            imag_sign=real_index;
            assert(length(tau)==size(complex,1),'convolution equations are not correct')
            for i=1:size(complex,1)
                c=complex(i,:);
                scale=min(abs(c(c~=0)));
                c=round(c/scale);
                tau(i)=tau(i)/scale;


                [~,index,values]=find(abs(c));
                n=length(values);
                assert(n>0&&mod(n,2)==0,'complex equations do not have even number of variables');
                assert(all(sort(values)==1:n),'complex equations are not consecutive integers');


                [~,sorted]=sort(values);
                real_imag=index(sorted);







                real_index{i}=real_imag(1:2:end);
                imag_index{i}=real_imag(2:2:end);
                imag_sign{i}=sign(c(real_index{i})).*sign(c(imag_index{i}));
                assert(all(abs(imag_sign{i})==1),'complex variable signs are incorrect');
            end
            variables.Real=cell2mat(real_index);
            variables.Imag=cell2mat(imag_index);
            variables.ImagSign=cell2mat(imag_sign);
            variables.Time=true(1,dae.NumStates);
            variables.Time(variables.Imag)=false;
            actual=cumsum(variables.Time);
            variables.ActualIndex=actual(variables.Real);




            r=equations.FreqReal;
            equations.ConvolutionTau=zeros(size(r));
            equations.ConvolutionShift=false(size(r));
            equations.ConvolutionTau(r)=abs(tau);
            equations.ConvolutionShift(r)=(tau<0);

            assert(all(equations.ConvolutionTau>=0),'convolution delay is negative');







            F=dae.F(dae.inputs);
            delay_eqations=find(equations.Delay);
            delays=struct('Yindex',[],'Xindex',[],'Xscale',[],'Tau',[],'ModAndCarr',[]);

            for i=1:length(delay_eqations)
                eq=delay_eqations(i);
                vars=find(DXF(eq,:)~=0);
                inputs=find(DUF(eq,:)~=0);
                assert(length(vars)+length(inputs)==2&&length(inputs)<=1,'delay equation does not have two variables');
                if length(vars)==2
                    [~,indices]=sort(abs(DXF(eq,:)));
                    Yindex=indices(end-1);
                    Xindex=indices(end);
                    Yscale=DXF(eq,Yindex);
                    Xscale=DXF(eq,Xindex)/2;
                    Xis_variable=true;
                else
                    Yindex=vars;
                    Xindex=inputs;
                    Yscale=DXF(eq,Yindex);
                    Xscale=DUF(eq,Xindex)/2;
                    Xis_variable=false;
                    assert(false,'for now, X has to be the variable too');
                end

                delays.Yindex(i)=actual(Yindex);
                delays.Xindex(i)=actual(Xindex);
                delays.Xis_variable(i)=Xis_variable;
                delays.Xscale(i)=Xscale/Yscale;
                assert(abs(delays.Xscale(i))-1<1e-8,'incorrect variable elimination in delay equation');
                delays.Tau(i)=abs(F(delay_eqations(i))/Yscale);
                delays.ModAndCarr(i)=((F(delay_eqations(i))/Yscale)>=0);
            end

            assert(all(unique(variables.Imag,'legacy')==sort(variables.Imag)),'imaginary parts are not unique');

            o.EquationInfo=equations;
            o.VariableInfo=variables;
            o.DelayInfo=delays;

            o.NumStates=sum(o.VariableInfo.Time);
            o.NumFreqStates=length(unique(o.VariableInfo.ActualIndex,'legacy'));
            o.NumInputs=dae.NumInputs;
            o.NumTimeEquations=sum(equations.Time);
            o.NumDelayEquations=sum(equations.Delay);
            o.NumFreqEquations=o.NumStates-o.NumTimeEquations-o.NumDelayEquations;

            assert(sum(equations.Time)*2+sum(equations.Freq)+sum(equations.Delay)*2==2*o.NumStates,'something is wrong with freq-domain variables');





            input=o.Dae.inputs;
            m=double(o.Dae.DXF_P(input));
            o.ConvolutionPattern=m(equations.FreqReal,variables.Time);
            tau=(1-2*equations.ConvolutionShift(equations.FreqReal)).*equations.ConvolutionTau(equations.FreqReal);
            for i=1:o.NumFreqEquations
                p=o.ConvolutionPattern(i,:);
                o.ConvolutionPattern(i,p>0)=tau(i);
            end




            [G_row,G_col]=find(dae.DXF_P(dae.inputs));
            [M_row,M_col]=find(dae.M_P(dae.inputs));
            assert(length(unique([M_row;G_row],'legacy'))==dae.NumStates,'dae is structurally singular');
            assert(length(unique([M_col;G_col],'legacy'))==dae.NumStates,'dae is structurally singular');

            ssc_rf_log(1,'    Yindex ',delays.Yindex);
            ssc_rf_log(1,'    Xindex ',delays.Xindex);
            ssc_rf_log(1,'    Xscale ',delays.Xscale);
            ssc_rf_log(1,'    Tau ',delays.Tau);
        end

        function d=MaxDelay(o)
            if o.NumDelayEquations==0
                d=0;
            else
                d=max(o.DelayInfo.Tau);
            end
        end

        function m=TimeDomainMatrix(o,id,varargin)
            m=rfsolver.MakeMatrix(o.Dae,id,varargin{:});
            if o.NumFreqStates==0&&o.NumDelayEquations==0
                return;
            end

            i=find(o.EquationInfo.Time);
            j=find(o.VariableInfo.Time);
            switch id
            case 'M'
                assert_zeroes_outside_range(m,i,j);
                m=m(i,j);
            case 'DXF'
                m=m(i,j);
            case 'DUF'
                assert_zeroes_outside_range(m,i,1:size(m,2));
                m=m(i,:);
            case 'DXY'
                assert_zeroes_outside_range(m,1:size(m,1),j);
                m=m(:,j);
            case 'DUY'
            otherwise
                assert(false,'unknown matrix type');
            end
        end





        function m=FreqDomainConstMatrix(o,id,frequency,isDC)
            switch id
            case 'DXF'
                dFdI=true;
                real_eq=true;
                if isDC
                    m=DXFOriginalMatrix(o,0.0,dFdI,real_eq);
                else





                    a=DXFOriginalMatrix(o,frequency,dFdI,real_eq);
                    b=DXFOriginalMatrix(o,frequency,~dFdI,real_eq);
                    c=DXFOriginalMatrix(o,frequency,dFdI,~real_eq);
                    d=DXFOriginalMatrix(o,frequency,~dFdI,~real_eq);

                    m=[a,b;c,d];
                end
            otherwise
                assert(false,'unknown matrix type');
            end
        end





        function matrix=DXFOriginalMatrix(o,freq,dFdI,keep_real_equations)
            input=o.Dae.inputs;
            input.T=abs(freq);
            m=rfsolver.MakeMatrix(o.Dae,'DXF',input);

            if keep_real_equations
                m=m(o.EquationInfo.FreqReal,:);
            else
                m=m(o.EquationInfo.FreqImag,:);
            end






            if dFdI
                matrix=m(:,o.VariableInfo.Time);
            else





                matrix=sparse(size(m,1),o.NumStates);
                for i=1:length(o.VariableInfo.Imag)
                    k=o.VariableInfo.ActualIndex(i);
                    dae_imag_index=o.VariableInfo.Imag(i);
                    sign=o.VariableInfo.ImagSign(i);
                    matrix(:,k)=matrix(:,k)+m(:,dae_imag_index)*sign;
                end
            end










            if freq<0
                if(dFdI&&~keep_real_equations)||(~dFdI&&keep_real_equations)
                    matrix=-matrix;
                end
            end
        end






        function m=FreqDomainDelayDXF(o,frequency,isDC,step)
            input=o.Dae.inputs;
            m=rfsolver.MakeMatrix(o.Dae,'DXF',input);
            m=m(o.EquationInfo.Delay,o.VariableInfo.Time);
            if isDC







                for i=1:o.NumDelayEquations
                    a=max(1-o.DelayInfo.Tau(i)/step,0);
                    m(i,o.DelayInfo.Yindex(i))=1;
                    m(i,o.DelayInfo.Xindex(i))=-a;
                end
            else









                dI=m;
                dQ=m;
                for i=1:o.NumDelayEquations
                    wT=2*pi*frequency*o.DelayInfo.Tau(i)*o.DelayInfo.ModAndCarr(i);
                    a=max(1-o.DelayInfo.Tau(i)/step,0);
                    in=o.DelayInfo.Xindex(i);
                    out=o.DelayInfo.Yindex(i);
                    sign=o.DelayInfo.Xscale(i);

                    dI(i,out)=1;
                    dI(i,in)=-a*sign*cos(wT);
                    dQ(i,out)=0;
                    dQ(i,in)=-a*sign*sin(wT);
                end
                m=[dI,dQ;...
                -dQ,dI];
            end
        end





        function DXF=MultipleFreqDomainDFX(o,freqs,isSteadyState)
            assert(freqs(1)==0,'first frequency is not DC');
            DXF=cell(length(freqs),1);
            DXF{1}=o.FreqDomainConstMatrix('DXF',0,true);
            for i=2:length(freqs)
                DXF{i}=o.FreqDomainConstMatrix('DXF',freqs(i),false);
            end


            if~isSteadyState
                v=o.Convolution.DFX_values;
                if~isempty(v)
                    p=o.ConvolutionPattern;
                    pp=[p,p;p,p];
                    DXF{1}(p~=0)=v(:,1);
                    for i=2:length(freqs)
                        m=p;
                        m(m~=0)=v(:,i);
                        m=[real(m),-imag(m);imag(m),real(m)];
                        DXF{i}(pp~=0)=m(pp~=0);
                    end
                end
            end
        end




        function F=MultipleTimeDomainF_negative(o,x,u)
            dae=o.Dae;
            numTimePoints=size(x,2);
            input=dae.inputs;

            eq_index=find(o.EquationInfo.Time);
            var_index=o.VariableInfo.Time;

            F=zeros(o.NumTimeEquations,numTimePoints);

            for i=1:numTimePoints
                input.X(var_index)=x(:,i);
                input.U=u(:,i);

                input.M=dae.MODE(input);
                tmp=-dae.F(input);
                F(:,i)=tmp(eq_index);
            end
        end





        function F=MultipleDelayF(o,freqs,step)
            X_interp=o.History.interpolate;


            b=min(o.DelayInfo.Tau'/step,1);
            nFreqs=length(freqs);
            assert(size(X_interp,2)==2*nFreqs-1,'incorrect frequency list');

            F=zeros(size(X_interp));
            if~isempty(o.DelayInfo.Tau)
                F(:,1)=b.*X_interp(:,1);
                for i=2:nFreqs
                    q=i+nFreqs-1;

                    wT=2*pi*freqs(i)*(o.DelayInfo.Tau.*o.DelayInfo.ModAndCarr)';

                    F(:,i)=b.*(cos(wT).*X_interp(:,i)+sin(wT).*X_interp(:,q));
                    F(:,q)=b.*(cos(wT).*X_interp(:,q)-sin(wT).*X_interp(:,i));
                end
            end
        end






        function F=MultipleConvolutionF(o)
            V=o.Convolution.Convolve;
            num_freqs=size(V,2);
            num_equations=size(o.ConvolutionPattern,1);
            F=zeros(num_equations,2*num_freqs-1);

            if~isempty(o.ConvolutionPattern)
                for i=1:num_freqs
                    p=o.ConvolutionPattern;
                    p(p~=0)=V(:,i);
                    rhs=sum(p,2);

                    F(:,i)=real(rhs);
                    if i>1
                        q=i+num_freqs-1;
                        F(:,q)=imag(rhs);
                    end
                end
            end
        end




        function[DXF,meanDXF]=MultipleTimeDomainDXF_negative(o,x,u,scale)
            dae=o.Dae;
            numTimePoints=size(x,2);
            input=dae.inputs;

            eq_index=o.EquationInfo.Time;
            var_index=find(o.VariableInfo.Time);




            DXF=cell(numTimePoints,1);
            DXF_P=dae.DXF_P(input);
            [row,col]=find(DXF_P);
            selector=o.EquationInfo.Time(row)&o.VariableInfo.Time(col);
            [row,col]=find(DXF_P(eq_index,var_index));
            mean_values=zeros(size(row));

            for i=1:numTimePoints
                input.X(var_index)=x(:,i);
                input.U=u(:,i);
                input.M=dae.MODE(input);

                values=-dae.DXF(input);
                values=values(selector);
                mean_values=mean_values+values;
                DXF{i}=sparse(row,col,values*scale,o.NumTimeEquations,o.NumStates);
            end
            meanDXF=sparse(row,col,mean_values*scale/numTimePoints,o.NumTimeEquations,o.NumStates);
        end

        function[DUF,meanDUF]=MultipleTimeDomainDUF_negative(o,x,u,scale)
            dae=o.Dae;
            numTimePoints=size(x,2);
            input=dae.inputs;

            eq_index=o.EquationInfo.Time;




            DUF=cell(numTimePoints,1);
            DUF_P=dae.DUF_P(input);
            [row,~]=find(DUF_P);
            selector=o.EquationInfo.Time(row);
            [row,col]=find(DUF_P(eq_index,:));
            mean_values=zeros(numel(row),1);

            for i=1:numTimePoints
                input.X(o.VariableInfo.Time)=x(:,i);
                input.U=u(:,i);
                input.M=dae.MODE(input);

                values=-dae.DUF(input);
                values=values(selector);
                mean_values=mean_values+values;
                DUF{i}=sparse(row,col,values*scale,o.NumTimeEquations,o.NumInputs);
            end
            meanDUF=sparse(row,col,mean_values*scale/numTimePoints,o.NumTimeEquations,o.NumInputs);
        end

        function flag=IsLinear(o)
            dae=o.Dae;
            linearDXF=dae.DXF_V_X(dae.inputs);
            linearDUF=dae.DUF_V_X(dae.inputs);

            domain={dae.EquationData.domain};
            timedomain=strcmp(domain,'TIME');

            linearDXF=all(linearDXF(timedomain)==0);
            linearDUF=all(linearDUF(timedomain)==0);

            flag=linearDXF&&linearDUF;
        end


        function input=Input(o)
            input=o.Dae.Input;
        end

        function output=Output(o)
            output=o.Dae.Output;
        end

        function[indices,tau]=HistoryVariables(o)
            indices=o.DelayInfo.Xindex;
            tau=o.DelayInfo.Tau;
        end


        function values=ConvolutionValues(o,freq)
            p=o.ConvolutionPattern;
            assert(freq>=0,'frequency is negative');
            dFdI=true;
            real_eq=true;
            if freq==0
                DXF=o.DXFOriginalMatrix(freq,dFdI,real_eq);
                values=DXF(p~=0);
            else




                a=o.DXFOriginalMatrix(freq,dFdI,real_eq);
                b=o.DXFOriginalMatrix(freq,~dFdI,real_eq);

                m1=a-1j*b;
                values=m1(p~=0);

                c=o.DXFOriginalMatrix(freq,dFdI,~real_eq);
                d=o.DXFOriginalMatrix(freq,~dFdI,~real_eq);

                m2=1j*c+d;
                v2=m2(p~=0);

                assert(norm(values-v2)<1e-6*norm(values+v2)+1e-8,'values do not match')
            end
            values=full(values(:));
            assert(length(values)==length(o.ConvolutionVariables),'convolution values have wrong size');
        end

        function[indices,tau,shift]=ConvolutionVariables(o)
            tau=abs(nonzeros(o.ConvolutionPattern));
            shift=nonzeros(o.ConvolutionPattern)<0;
            [~,indices]=find(o.ConvolutionPattern);









            shift(ismember(indices,o.VariableInfo.ActualIndex(2:2:end)))=0;
        end

    end
end


function assert_zeroes_outside_range(matrix,i,j)
    [m,n]=find(matrix);
    assert(all(ismember(m,i))&&all(ismember(n,j)),'matrix values are outside the range');
end



