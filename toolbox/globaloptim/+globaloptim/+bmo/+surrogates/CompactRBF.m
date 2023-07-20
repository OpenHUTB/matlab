

classdef CompactRBF<APIs.SurrogateEvaluator

    properties(Access=public)

X
        numPoints=0
w
lambda
c

dim
nResponse

responseCol
responseNames

kernel
tail






        unscaleResponse=true
        filter=globaloptim.bmo.surrogates.fscale.NoScale;
        fScaled=false;




        perturbX=false

lb
ub
fixedID


        dTol=1e-10

Ylast
YlastScaled
Dlast

        Verbosity=0
        DEBUG=false
    end

    properties(Constant)

        DistanceFcn=@globaloptim.internal.distance.pdist2
    end

    methods(Access=public)

        function[out,grad,Hess]=evaluateImpl(self,Y,idx)


            if isempty(self.w)
                out=[];
                grad=[];
                Hess=[];
                return;
            end

            assert(size(Y,2)==size(self.X,2));

            idx=self.getColIndex(idx);


            [D,YY]=self.computeDistance(Y);

            out=self.eval(YY,D,idx);
            if nargout>1
                grad=self.deval(YY,D,idx);
                if nargout>2
                    Hess=self.d2eval(YY,D,idx);
                end
            end
        end

    end

    methods(Access=protected)

        function grad=gradientImpl(self,Y,idx)

            if isempty(self.w)
                grad=[];
                return;
            end

            idx=self.getColIndex(idx);

            [D,YY]=self.computeDistance(Y);
            grad=self.deval(YY,D,idx);
        end

        function hess=hessianImpl(self,Y,idx)

            if isempty(self.w)
                hess=[];
                return;
            end

            idx=self.getColIndex(idx);

            [D,YY]=self.computeDistance(Y);
            hess=self.d2eval(YY,D,idx);
        end

    end

    methods(Access=private)
        function out=eval(self,Y,D,idx)


            out=self.kernel.eval(D)*self.lambda(:,idx)+...
            self.tail.eval(Y)*self.c(:,idx);
            if self.unscaleResponse
                out=self.filter.unscale(out);
            end
        end

        function out=deval(self,Y,D,idx)



            assert(~self.fScaled||~self.unscaleResponse)


            XX=self.X(1:self.numPoints,:);
            scaleGrad=self.Range';
            scaleGrad(self.fixedID)=1;



            out=zeros(size(Y,1),self.dim,numel(idx));
            index_=1:numel(idx);

            for ii=1:size(Y,1)
                y=Y(ii,:);
                r=D(ii,:)';

                kernelDeriv=self.kernel.deval(r,y,XX);
                tailDeriv=self.tail.deval(y);
                temp=self.lambda(:,idx)'*kernelDeriv+...
                self.c(:,idx)'*tailDeriv;

                out(ii,:,index_)=[temp./scaleGrad]';
            end
        end

        function out=d2eval(self,Y,D,idx)







            assert(~self.fScaled||~self.unscaleResponse)


            XX=self.X(1:self.numPoints,:);
            scaleHess=self.Range*self.Range';
            scaleHess(self.fixedID,self.fixedID)=1;



            out=zeros(size(Y,1),self.dim,self.dim,numel(idx));


            for ii=1:size(Y,1)
                y=Y(ii,:);
                r=D(ii,:)';



                kernelHess=self.kernel.d2eval(r,y,XX);



                for index_=1:numel(idx)
                    temp=zeros(self.dim,self.dim);

                    for jj=1:size(self.lambda,1)

                        temp=temp+squeeze(self.lambda(jj,index_)*kernelHess(jj,:,:));
                    end



                    out(ii,:,:,index_)=[temp./(scaleHess)];

                end
            end
        end

        function[D,Y]=computeDistance(self,Y)

            if isempty(self.Ylast)||...
                ~(all(size(self.Ylast)==size(Y))&&...
                all(abs(Y(:)-self.Ylast(:))<eps(self.Ylast(:))))

                self.Ylast=Y;

                if~isempty(self.lb)&&~isempty(self.ub)

                    self.YlastScaled=self.mapToUnit(Y,self.lb,self.ub,...
                    self.fixedID,self.perturbX);
                else
                    self.YlastScaled=Y;
                end

                XX=self.X(1:self.numPoints,:);
                self.Dlast=self.DistanceFcn(self.YlastScaled,XX);

            end
            D=self.Dlast;
            Y=self.YlastScaled;

        end

        function colIndex=getColIndex(self,idx)
            colIndex=[];
            for ii=idx
                range_=self.responseCol.(self.responseNames{ii});
                colIndex=horzcat(colIndex,range_(1):range_(2));%#ok<AGROW>
            end

        end
    end

    methods(Static)

        function X=mapToUnit(X,lb,ub,fixed,perturb)









            notFixed=~fixed;
            temp=(X-lb')./(ub-lb)';
            if perturb
                pert=1e3*eps*rand(size(X,1),nnz(notFixed));
                X(:,notFixed)=temp(:,notFixed)+pert;
            else
                X(:,notFixed)=temp(:,notFixed);
            end
            if nnz(fixed)>0

                pert=eps*rand(nnz(fixed),1);
                X(:,fixed)=X(:,fixed)./(ub(fixed,:)-pert)';
            end

        end


        function X=mapFromUnit(X,lb,ub,fixed)









            notFixed=~fixed;
            temp=lb'+(ub-lb)'.*X;
            X(:,notFixed)=temp(:,notFixed);
            X(:,fixed)=ub(fixed,:)';
        end

    end

end