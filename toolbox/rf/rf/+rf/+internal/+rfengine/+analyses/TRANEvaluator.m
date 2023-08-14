classdef TRANEvaluator<handle




    properties
Circuit
Evaluator

Jtrans
Ftrans
    end

    methods
        function self=TRANEvaluator(ckt,analysis)
            self.Circuit=ckt;
            self.Evaluator=analysis.Evaluator;
        end

        function noMethod(self,~,~,~,~)
            self.Jtrans=[self.Evaluator.Ji,self.Evaluator.Jv(:,2:end);self.Circuit.Jkiv];
            self.Ftrans=[self.Evaluator.Fiv-self.Evaluator.Uiv;self.Evaluator.Fk];
        end

        function backwardEuler(self,h,~,~,pQiv)
            sf=1/h;
            self.Jtrans=[sf*self.Evaluator.Jqi+self.Evaluator.Ji...
            ,sf*self.Evaluator.Jqv(:,2:end)+self.Evaluator.Jv(:,2:end);...
            self.Circuit.Jkiv];
            sQiv=sf*(self.Evaluator.Qiv-pQiv(:,end));
            self.Ftrans=[sQiv+self.Evaluator.Fiv-self.Evaluator.Uiv;...
            self.Evaluator.Fk];
        end

        function bdf2(self,h,pT,~,pQiv)
            h1=pT(end)-pT(end-1);
            a0=(2*h+h1)/(h*(h+h1));
            a1=-(h+h1)/(h*h1);
            a2=h/(h1*(h+h1));
            self.Jtrans=[a0*self.Evaluator.Jqi+self.Evaluator.Ji...
            ,a0*self.Evaluator.Jqv(:,2:end)+self.Evaluator.Jv(:,2:end);...
            self.Circuit.Jkiv];
            sQiv=a0*self.Evaluator.Qiv+a1*pQiv(:,end)+a2*pQiv(:,end-1);
            self.Ftrans=[sQiv+self.Evaluator.Fiv-self.Evaluator.Uiv;...
            self.Evaluator.Fk];
        end

        function trapezoidal(self,h,~,pFiv,pQiv)
            sf=2/h;
            self.Jtrans=[sf*self.Evaluator.Jqi+self.Evaluator.Ji...
            ,sf*self.Evaluator.Jqv(:,2:end)+self.Evaluator.Jv(:,2:end);...
            self.Circuit.Jkiv];
            sQiv=sf*(self.Evaluator.Qiv-pQiv(:,end));
            self.Ftrans=[sQiv+(self.Evaluator.Fiv+pFiv(:,end))-self.Evaluator.Uiv;...
            self.Evaluator.Fk];
        end

        function ndf2(self,h,pT,~,pQiv)
            h1=pT(end)-pT(end-1);
            h2=pT(end-1)-pT(end-2);

            a0=0.5/(h+h1+h2)+1/(h+h1)+1/h;
            a1=-(h+h1)/(h*h1)-(h+h1)/(2*h1*(h1+h2));
            a2=h/(h1*(h+h1))+h/(2*h1*h2);
            a3=-h*(h+h1)/(2*h2*(h1+h2)*(h+h1+h2));






            self.Jtrans=[a0*self.Evaluator.Jqi+self.Evaluator.Ji...
            ,a0*self.Evaluator.Jqv(:,2:end)+self.Evaluator.Jv(:,2:end);...
            self.Circuit.Jkiv];
            sQiv=a0*self.Evaluator.Qiv+...
            a1*pQiv(:,end)+a2*pQiv(:,end-1)+a3*pQiv(:,end-2);
            self.Ftrans=[sQiv+self.Evaluator.Fiv-self.Evaluator.Uiv;...
            self.Evaluator.Fk];
        end


        function timeDomainEvaluate(self,x,time,h,method,prevT,prevFiv,prevQiv,beta)
            timeDomainEvaluate(self.Evaluator,x,time,true,beta)
            feval(method,self,h,prevT,prevFiv,prevQiv);
        end
    end
end
