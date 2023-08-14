















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

            if iscell(dae.EquationData.domain)
                domain=dae.EquationData.domain;
            else
                domain={dae.EquationData.domain};
            end
            equations.Time=logical(strcmp(domain,'TIME'));
            equations.FreqReal=logical(strcmp(domain,'FREQUENCY_REAL'));
            equations.FreqImag=logical(strcmp(domain,'FREQUENCY_IMAG'));
            equations.Complex=logical(strcmp(domain,'COMPLEX'));
            equations.Freq=equations.FreqReal|equations.FreqImag;
            equations.Delay=logical(strcmp(domain,'DELAY'));












            inputs=dae.inputs;
            inputs.T=0.0;


            inputs.T=realmax;

            DTF=dae.DTF(dae.inputs);







            tau=DTF(equations.Complex);

            DXF=full(sparse(dae.JRows,dae.JCols,dae.DXF(dae.inputs),...
            dae.NumStates,dae.NumStates));
            DUF=dae.DUF(dae.inputs);

            complex=DXF(equations.Complex,:);





            real_index=cell(1,size(complex,1));
            imag_index=real_index;
            imag_sign=real_index;


            for i=1:size(complex,1)
                c=complex(i,:);
                scale=min(abs(c(c~=0)));

                c=round(c/scale);
                tau(i)=tau(i)/scale;


                [~,index,values]=find(abs(c));







                [~,sorted]=sort(values);
                real_imag=index(sorted);





                real_index{i}=real_imag(1:2:end);
                imag_index{i}=real_imag(2:2:end);
                imag_sign{i}=...
                sign(c(real_index{i})).*sign(c(imag_index{i}));


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










            F=dae.F(dae.inputs);
            delay_eqations=find(equations.Delay);
            delays=struct(...
            'Yindex',[],'Xindex',[],'Xscale',[],'Tau',[],'ModAndCarr',[]);

            for i=1:length(delay_eqations)
                eq=delay_eqations(i);
                vars=find(DXF(eq,:)~=0);
                inputs=find(DUF(eq,:)~=0);



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

                end

                delays.Yindex(i)=actual(Yindex);
                delays.Xindex(i)=actual(Xindex);
                delays.Xis_variable(i)=Xis_variable;
                delays.Xscale(i)=Xscale/Yscale;



                delays.Tau(i)=abs(F(delay_eqations(i))/Yscale);
                delays.ModAndCarr(i)=((F(delay_eqations(i))/Yscale)>=0);
            end




            o.EquationInfo=equations;
            o.VariableInfo=variables;
            o.DelayInfo=delays;


            o.NumStates=sum(o.VariableInfo.Time);

            o.NumFreqStates=...
            length(unique(o.VariableInfo.ActualIndex,'legacy'));
            o.NumInputs=dae.NumInputs;
            o.NumTimeEquations=sum(equations.Time);
            o.NumDelayEquations=sum(equations.Delay);
            o.NumFreqEquations=...
            o.NumStates-o.NumTimeEquations-o.NumDelayEquations;







            input=o.Dae.inputs;
            m=double(o.Dae.DXF_P(input));

            o.ConvolutionPattern=m(equations.FreqReal,variables.Time);
            tau=(1-2*equations.ConvolutionShift(equations.FreqReal)).*...
            equations.ConvolutionTau(equations.FreqReal);
            for i=1:o.NumFreqEquations
                p=o.ConvolutionPattern(i,:);


                o.ConvolutionPattern(i,p>0)=tau(i);
            end









        end

        function d=MaxDelay(o)
            if o.NumDelayEquations==0
                d=0;
            else
                d=max(o.DelayInfo.Tau);
            end
        end


        function m=TimeDomainMatrix(o,id,varargin)
            m=rf.internal.rfengine.rfsolver.MakeMatrix(o.Dae,...
            id,varargin{:});

            if o.NumFreqStates==0&&o.NumDelayEquations==0
                return;
            end
            i=find(o.EquationInfo.Time);
            j=find(o.VariableInfo.Time);
            switch id
            case 'M'

                m=m(i,j);
            case 'DXF'
                m=m(i,j);
            case 'DUF'

                m=m(i,:);
            case 'DXY'

                m=m(:,j);
            case 'DUY'
            otherwise
                error('unknown matrix type')
            end
        end



        function m=FreqDomainConstMatrix(o,id,frequency,isDC)
            switch id
            case 'DXF'
                dFdI=true;
                real_eq=true;
                input=o.Dae.inputs;

                input.T=abs(frequency);
                m=sparse(o.Dae.JRows,o.Dae.JCols,o.Dae.DXF(input),...
                o.Dae.NumStates,o.Dae.NumStates);


                if isDC
                    m=DXFOriginalMatrix(o,0.0,dFdI,real_eq,m);
                else




                    a=DXFOriginalMatrix(o,frequency,dFdI,real_eq,m);
                    b=DXFOriginalMatrix(o,frequency,~dFdI,real_eq,m);
                    c=DXFOriginalMatrix(o,frequency,dFdI,~real_eq,m);
                    d=DXFOriginalMatrix(o,frequency,~dFdI,~real_eq,m);

                    m=[a,b;c,d];
                end
            otherwise
                error('unknown matrix type')
            end
        end



        function mout=DXFOriginalMatrix(o,freq,dFdI,keep_real_equations,m)

            if keep_real_equations
                m=m(o.EquationInfo.FreqReal,:);
            else
                m=m(o.EquationInfo.FreqImag,:);
            end




            if dFdI
                mout=m(:,o.VariableInfo.Time);
            else


                msign=o.VariableInfo.ImagSign.*m(:,o.VariableInfo.Imag);
                [i,j,v]=find(msign);
                j=o.VariableInfo.ActualIndex(j);
                mout=sparse(i,j,v,size(m,1),o.NumStates);
            end








            if freq<0
                if(dFdI&&~keep_real_equations)||...
                    (~dFdI&&keep_real_equations)
                    mout=-mout;
                end
            end
        end




        function m=FreqDomainDelayDXF(o,frequency,isDC,step)
            if all(o.EquationInfo.Delay==0)

                if isDC
                    m=sparse(0,nnz(o.VariableInfo.Time));
                else
                    m=sparse(0,2*nnz(o.VariableInfo.Time));
                end
                return
            end
            m=sparse(o.Dae.JRows,o.Dae.JCols,o.Dae.DXF(o.Dae.inputs),...
            o.Dae.NumStates,o.Dae.NumStates);

            m=m(o.EquationInfo.Delay,o.VariableInfo.Time);
            if isDC





                for i=1:o.NumDelayEquations
                    a=max(1-o.DelayInfo.Tau(i)/step,0);
                    m(i,o.DelayInfo.Yindex(i))=1;%#ok<SPRIX>
                    m(i,o.DelayInfo.Xindex(i))=-a;%#ok<SPRIX>
                end
            else







                dI=m;
                dQ=m;
                for i=1:o.NumDelayEquations
                    wT=2*pi*frequency*o.DelayInfo.Tau(i)*...
                    o.DelayInfo.ModAndCarr(i);
                    a=max(1-o.DelayInfo.Tau(i)/step,0);
                    in=o.DelayInfo.Xindex(i);
                    out=o.DelayInfo.Yindex(i);


                    sign=o.DelayInfo.Xscale(i);

                    dI(i,out)=1;%#ok<SPRIX>
                    dI(i,in)=-a*sign*cos(wT);%#ok<SPRIX>
                    dQ(i,out)=0;%#ok<SPRIX>
                    dQ(i,in)=-a*sign*sin(wT);%#ok<SPRIX>
                end
                m=[dI,dQ;...
                -dQ,dI];
            end
        end




        function DXF=MultipleFreqDomainDFX(o,freqs,isSteadyState)

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
            numTimePoints=size(x,2);
            input=o.Dae.inputs;

            eq_index=o.EquationInfo.Time;
            var_index=o.VariableInfo.Time;

            F=zeros(o.NumTimeEquations,numTimePoints);
            for i=1:numTimePoints
                input.X(var_index)=x(:,i);
                input.U=u(:,i);

                input.M=o.Dae.MODE(input);
                tmp=-o.Dae.F(input);
                F(:,i)=tmp(eq_index);
            end
        end



        function F=MultipleDelayF(o,freqs,step)

            X_interp=o.History.interpolate;

            b=min(o.DelayInfo.Tau'/step,1);
            nFreqs=length(freqs);



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

                p=o.ConvolutionPattern;
                p(p~=0)=V(:,1);
                rhs=sum(p,2);
                F(:,1)=real(rhs);
                for i=2:num_freqs
                    p(p~=0)=V(:,i);
                    rhs=sum(p,2);
                    F(:,i)=real(rhs);
                    q=i+num_freqs-1;
                    F(:,q)=imag(rhs);
                end
            end
        end


        function[DXF,idxJ,meanDXF]=MultipleTimeDomainDXF(o,x,u,scale)
            dae=o.Dae;
            numTimePoints=size(x,2);
            input=dae.inputs;

            input.M=dae.MODE(input);


            eq_index=o.EquationInfo.Time;
            var_index=find(o.VariableInfo.Time);



            selector=o.EquationInfo.Time(o.Dae.JRows)&...
            o.VariableInfo.Time(o.Dae.JCols);
            DXF_P=dae.DXF_P(input);
            idxJ=find(DXF_P(eq_index,var_index));
            nz=numel(idxJ);
            vJ=zeros(nz,numTimePoints);

            if nargout<3

                for i=1:numTimePoints
                    input.X(var_index)=x(:,i);
                    input.U=u(:,i);
                    values=dae.DXF(input);
                    vJ(:,i)=values(selector);
                end
            else
                [row,col]=find(DXF_P(eq_index,var_index));
                mean_values=zeros(size(row));

                for i=1:numTimePoints
                    input.X(var_index)=x(:,i);
                    input.U=u(:,i);
                    values=dae.DXF(input);
                    values=values(selector);
                    mean_values=mean_values+values;
                    vJ(:,i)=values;
                end
                meanDXF=sparse(row,col,mean_values*scale/numTimePoints,...
                o.NumTimeEquations,o.NumStates);
            end
            iJ=reshape(ones(nz,1).*(1:numTimePoints),[],1);
            jJ=reshape(idxJ.*ones(1,numTimePoints),[],1);
            DXF=sparse(...
            iJ,jJ,scale*vJ,numTimePoints,o.NumTimeEquations*o.NumStates);
        end


        function[DXF,meanDXF,sumAbsDXF,F]=...
            MultipleTimeDomainDXFandF_negative(o,x,u,scale)
            numTimePoints=size(x,2);
            input=o.Dae.inputs;

            input.M=o.Dae.MODE(input);


            eq_index=o.EquationInfo.Time;
            var_index=o.VariableInfo.Time;



            selector=o.EquationInfo.Time(o.Dae.JRows)&...
            o.VariableInfo.Time(o.Dae.JCols);
            DXF_P=o.Dae.DXF_P(input);
            [row,col]=find(DXF_P(eq_index,var_index));
            m=numel(row);
            r=1:m;

            sumValues=zeros(size(row));
            sumAbsValues=sumValues;
            F=zeros(o.NumTimeEquations,numTimePoints);
            vJ=zeros(numTimePoints*m,1);
            for i=1:numTimePoints
                input.X(var_index)=x(:,i);
                input.U=u(:,i);
                [Jvalues,Fvalues]=o.Dae.DXFandF(input);
                Jvalues=Jvalues(selector);
                sumValues=sumValues+Jvalues;
                sumAbsValues=sumAbsValues+abs(Jvalues);
                vJ(r+(i-1)*m)=Jvalues;
                F(:,i)=Fvalues(eq_index);
            end
            iJ=reshape(row+o.NumTimeEquations*(0:numTimePoints-1),[],1);
            jJ=reshape(col+o.NumStates*(0:numTimePoints-1),[],1);
            DXF=sparse(iJ,jJ,vJ,...
            numTimePoints*o.NumTimeEquations,numTimePoints*o.NumStates);
            meanDXF=sparse(row,col,sumValues*scale/numTimePoints,...
            o.NumTimeEquations,o.NumStates);
            sumAbsDXF=sparse(row,col,sumAbsValues,...
            o.NumTimeEquations,o.NumStates);
        end

        function[DUF,idxJ,meanDUF]=MultipleTimeDomainDUF(o,x,u,scale)
            dae=o.Dae;
            numTimePoints=size(x,2);
            input=dae.inputs;


            eq_index=o.EquationInfo.Time;


            DUF_P=dae.DUF_P(input);
            [row,~]=find(DUF_P);

            selector=o.EquationInfo.Time(row);
            [row,col]=find(DUF_P(eq_index,:));
            idxJ=find(DUF_P(eq_index,:));
            nz=numel(idxJ);
            vJ=zeros(nz,numTimePoints);
            mean_values=zeros(numel(row),1);

            for i=1:numTimePoints
                input.X(o.VariableInfo.Time)=x(:,i);
                input.U=u(:,i);

                input.M=dae.MODE(input);
                values=dae.DUF(input);
                values=values(selector);
                mean_values=mean_values+values;
                vJ(:,i)=values;
            end
            meanDUF=sparse(row,col,mean_values*scale/numTimePoints,...
            o.NumTimeEquations,o.NumInputs);
            iJ=reshape(ones(nz,1).*(1:numTimePoints),[],1);
            jJ=reshape(idxJ.*ones(1,numTimePoints),[],1);
            DUF=sparse(iJ,jJ,scale*vJ,numTimePoints,...
            o.NumTimeEquations*o.NumInputs);
        end

        function flag=IsLinear(o)
            dae=o.Dae;
            linearDXF=dae.DXF_V_X(dae.inputs);
            linearDUF=dae.DUF_V_X(dae.inputs);
            if iscell(dae.EquationData.domain)
                domain=dae.EquationData.domain;
            else
                domain={dae.EquationData.domain};
            end
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

            dFdI=true;
            real_eq=true;
            input=o.Dae.inputs;
            input.T=abs(freq);
            DXF=sparse(o.Dae.JRows,o.Dae.JCols,o.Dae.DXF(input),...
            o.Dae.NumStates,o.Dae.NumStates);

            if freq==0
                DXF=o.DXFOriginalMatrix(freq,dFdI,real_eq,DXF);
                values=DXF(p~=0);
            else



                a=o.DXFOriginalMatrix(freq,dFdI,real_eq,DXF);
                b=o.DXFOriginalMatrix(freq,~dFdI,real_eq,DXF);
                m1=a-1j*b;
                values=m1(p~=0);






            end
            values=full(values(:));


        end


        function[indices,tau,shift]=ConvolutionVariables(o)
            tau=abs(nonzeros(o.ConvolutionPattern));

            shift=nonzeros(o.ConvolutionPattern)<0;

            [~,indices]=find(o.ConvolutionPattern);









            shift(ismember(indices,o.VariableInfo.ActualIndex(2:2:end)))=0;
        end
    end
end
