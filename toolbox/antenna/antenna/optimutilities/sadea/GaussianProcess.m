classdef GaussianProcess



    properties(Access=private)
        inputScaling;
        outputScaling;

        samples;
        values;

        corrMatrixRank;
        permutationVector;


        regressionFcn;

        hyperparameters0;
        lowerBounds;
        upperBounds;


        dist;
        distIdxPsi;

        optimNrParameters;


        alpha;
        gamma;

        hyperparameters;

        C;

        sigma2;


        tau2;
        Sigma;


        Ft;
        R;

    end

    methods(Access=public)
        function obj=GaussianProcess(initialHpPopulation,lowerBounds,upperBounds)
            obj.hyperparameters0=initialHpPopulation;
            obj.lowerBounds=lowerBounds;
            obj.upperBounds=upperBounds;
            obj.optimNrParameters=size(obj.hyperparameters0,2);
        end








        function[y,sigma2]=predict(this,points)
            [nx,mx]=size(points);


            points=(points-this.inputScaling(ones(nx,1),:))./this.inputScaling(2.*ones(nx,1),:);


            [sy,sigma2]=this.scaledPredict(points);


            y=this.outputScaling(ones(nx,1),:)+this.outputScaling(2.*ones(nx,1),:).*sy;
        end

    end

    methods(Access=private)






        function obj=setData(obj,samples,values)
            [n,m]=size(samples);



            inputAvg=mean(samples);
            inputStd=std(samples);

            outputAvg=mean(values);
            outputStd=std(values);

            samples=(samples-repmat(inputAvg,n,1))./repmat(inputStd,n,1);
            values=(values-repmat(outputAvg,n,1))./repmat(outputStd,n,1);

            obj=obj.setDataProperties(samples,values);

            obj.inputScaling=[inputAvg;inputStd];
            obj.outputScaling=[outputAvg;outputStd];
        end

        function obj=setDataProperties(obj,samples,values)
            obj.samples=samples;
            obj.values=values;
            obj.permutationVector=1:size(obj.samples,1);
        end










        function obj=fit(obj,samples,values)
            obj=obj.setData(samples,values);
            [numSamples,~]=size(obj.samples);



            obj.Sigma=(numSamples+10)*eps;
            o=(1:numSamples)';
            obj.Sigma=sparse(o,o,obj.Sigma);
            obj.regressionFcn=zeros(0,size(obj.samples,2));

            F=obj.regressionMatrix(obj.samples);

            nSamples=1:numSamples;
            idx=nSamples(ones(numSamples,1),:);
            a=tril(idx,-1);
            b=triu(idx,1)';
            a=a(a~=0);
            b=b(b~=0);
            obj.distIdxPsi=[a,b];

            obj.dist=obj.samples(a,:)-obj.samples(b,:);

            clear a b idx


            [obj,optimHp]=obj.tuneParameters(F);
            hp=mat2cell(optimHp,1,obj.optimNrParameters);

            obj=obj.updateModel(F,hp);
        end













        function regMat=regressionMatrix(~,samples)
            [n,dim]=size(samples);
            degrees=zeros(0,dim);
            m=ones(n,0);
            for i=1:dim
                base=repmat(samples(:,i),1,1).^0;
                m=m.*base(:,degrees(:,i).'+1);
            end
            regMat=m;
        end












        function[y,sigma2]=scaledPredict(this,points)
            [nx,~]=size(points);
            dim_out=length(this.sigma2);


            F=this.regressionMatrix(points);
            poly=F*this.alpha;


            corr=this.extrinsicCorrelationMatrix(points);
            gp=corr*this.gamma;


            y=poly+gp;


            corrt=this.C(1:this.corrMatrixRank,1:this.corrMatrixRank)\corr';

            u=this.Ft.'*corrt-F.';
            v=this.R\u;
            tmp=(1+sum(v.^2,1)-sum(corrt.^2,1))';

            sigma2=repmat(this.getProcessVariance(),nx,1).*repmat(tmp,1,dim_out);
        end












        function[obj,optimHp,perf]=tuneParameters(obj,F)
            func=@(optimParam)likelihood(obj,F,optimParam);

            opts.DerivativeCheck='off';
            opts.Diagnostics='off';
            opts.Algorithm='active-set';
            opts.MaxFunEvals=1000000;
            opts.MaxIter=500;
            opts.GradObj='on';
            opts.Display='off';

            [pop,opvalue]=...
            aconstrsh(func,obj.hyperparameters0,[],[],[],[],...
            obj.lowerBounds,obj.upperBounds,[],opts);

            optimHp=pop(1,:);
            perf=opvalue(1,:);
        end











        function this=updateModel(this,F,hp)

            this=this.updateStochasticProcess(hp);


            [this,err]=this.updateRegression(F);
        end












        function[this,err]=updateRegression(this,F)
            err=[];








            Ft=this.C\F(this.permutationVector,:);


            [Q,R]=qr(Ft,0);



            Yt=this.C\this.values(this.permutationVector,:);



            alpha=R\(Q'*Yt);

            residual=Yt-Ft*alpha;


            this.sigma2=sum(residual.^2)./size(this.values,1);


            this.alpha=alpha;


            this.gamma=this.C(1:this.corrMatrixRank,1:this.corrMatrixRank)'\residual;

            this.Ft=Ft;
            this.R=R;
        end












        function[this,dpsi]=updateStochasticProcess(this,hp)

            n=size(this.values,1);


            this.hyperparameters=hp;

            this.tau2=1;


            [psi,dpsi]=this.extrinsicCorrelationMatrix();



            psi=psi+this.getSigma();



            this.C=chol(psi);
            this.permutationVector=1:n;
            this.corrMatrixRank=size(this.C,1);

            this.C=this.C';
        end





















        function[psi,dpsi]=extrinsicCorrelationMatrix(obj,points1,points2)
            if exist('points1','var')







                if~exist('points2','var')
                    points2=obj.samples(obj.permutationVector(1:obj.corrMatrixRank),:);
                end

                n1=size(points1,1);
                n2=size(points2,1);

                nPoints1=1:n1;
                nPoints2=1:n2;

                dist=points1(nPoints1(ones(n2,1),:)',:)-points2(nPoints2(ones(n1,1),:),:);

                psi=GaussianProcess.gaussianCorrelation(obj.hyperparameters{1},dist);
                psi=reshape(psi,n1,n2);
            else








                n=size(obj.values,1);
                o=(1:n)';

                [psi,~,dhp]=GaussianProcess.gaussianCorrelation(obj.hyperparameters{1},obj.dist);

                dpsi=cell(1,size(dhp,2));
                for i=1:length(dpsi)
                    idx=find(dhp(:,i)~=0);
                    dpsi{i}=sparse([obj.distIdxPsi(idx,1);o],[obj.distIdxPsi(idx,2);o],[dhp(idx,i);zeros(n,1)]);
                end


                idx=find(psi>0);
                psi=sparse([obj.distIdxPsi(idx,1);o],[obj.distIdxPsi(idx,2);o],[psi(idx);ones(n,1)]);
            end
        end





















        function[out,dout]=likelihood(this,F,hp)
            param=mat2cell(hp,1,this.optimNrParameters);


            [this,dpsi]=this.updateStochasticProcess(param);


            this=this.updateRegression(F);


            if nargout>1
                [out,dout]=this.marginalLikelihood(dpsi);
            else
                out=this.marginalLikelihood();
            end
        end




        function sigma2=getProcessVariance(this)
            sigma2=this.sigma2;
        end




        function Sigma=getSigma(this)
            Sigma=this.Sigma;
        end


















        function[out,dout]=marginalLikelihood(this,dpsi)

            n=size(this.values,1);




            Yt=this.C\this.values(this.permutationVector,:);
            residual=Yt-this.Ft*this.alpha;


            lnDetPsi=2.*sum(log(diag(this.C)));

            out=0.5.*(n.*log(sum(this.sigma2))+lnDetPsi);


            if nargout>1
                dout=zeros(length(dpsi),1);




                for i=1:length(dpsi)

                    dpsiCurr=dpsi{i}+dpsi{i}';

                    resinvpsi=(this.C(1:this.corrMatrixRank,1:this.corrMatrixRank)'\residual(:,1));

                    dout(i,:)=resinvpsi'*dpsiCurr(this.permutationVector(1:this.corrMatrixRank),this.permutationVector(1:this.corrMatrixRank))*resinvpsi;
                    dout(i,:)=dout(i,:)./(2*mean(this.sigma2));

                    tmp=this.C(1:this.corrMatrixRank,1:this.corrMatrixRank)'\(this.C(1:this.corrMatrixRank,1:this.corrMatrixRank)\dpsiCurr(this.permutationVector(1:this.corrMatrixRank),this.permutationVector(1:this.corrMatrixRank)));
                    dout(i,:)=dout(i,:)-0.5*trace(tmp);
                end
                dout=-dout;
            else
                dout=[];
            end

        end
    end

    methods(Static)
        function model=create(samples,values)
            [~,numSamples]=size(samples);

            initHpPopulation=repmat(0.5,1,numSamples);
            lb=repmat(-2,1,numSamples);
            ub=repmat(2,1,numSamples);


            model=GaussianProcess(initHpPopulation,lb,ub);
            model=model.fit(samples,values);
        end
    end

    methods(Static,Access=private)
        function[corr,dx,dtheta]=gaussianCorrelation(theta,d)
            [n,m]=size(d);
            theta=10.^theta(:).';

            inner=-abs(d).^2.*theta(ones(n,1),:);
            corr=exp(sum(inner,2));


            if nargout>1

                dx=-2.*theta(ones(n,1),:).*d.*corr(:,ones(1,m));
                dtheta=log(10).*inner.*corr(:,ones(1,m));
            end
        end
    end
end

