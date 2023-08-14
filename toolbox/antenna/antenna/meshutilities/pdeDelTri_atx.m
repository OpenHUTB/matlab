classdef pdeDelTri_atx<handle





    properties(Access=private)
        delTri;
    end

    methods
        function self=pdeDelTri_atx(p)
            self.delTri=DelaunayTri(p);
        end

        function p=getPoints(self)
            p=self.delTri.X';
        end

        function t=getTriangles(self)
            nt=size(self.delTri.Triangulation,1);
            t=[self.delTri.Triangulation';zeros(1,nt)];
        end

        function c=getCircumcenters(self)
            [CC,RCC]=self.delTri.circumcenters();
            c=[CC';RCC'];
        end

        function setConstraints(self,cm)
            self.delTri.Constraints=cm;
        end

        function cm=getConstraints(self)
            cm=self.delTri.Constraints;
        end

        function inOutStatus=getInOutStatus(self)
            inOutStatus=self.delTri.inOutStatus();
        end

        function[p,t,c,npNew]=pdevoron(self,x,y)
            np=size(self.delTri.X,1);
            nx=size(x,2);
            if(nx>0)
                warnState=warning('off','MATLAB:DelaunayTri:DupPtsWarnId');
                self.delTri.X(end+(1:nx),:)=[x;y]';
                warning(warnState);
            end
            p=self.delTri.X';
            nt=size(self.delTri.Triangulation,1);

            t=[self.delTri.Triangulation';zeros(1,nt)];
            [CC,RCC]=self.delTri.circumcenters();
            c=[CC';RCC'];
            npNew=size(p,2)-np;
        end

        function tri=getEnclosingTriangles(self,pts)
            tri=self.delTri.pointLocation(pts);
        end

        function F=buildSizeInterp(self,h,Hmax,Hgrad)
            nx=size(self.delTri.X,1);
            warnState=warning('off','MATLAB:TriScatteredInterp:NonPersConstraintsWarnId');
            F=TriScatteredInterp(self.delTri,h(1:nx)');
            warning(warnState);
            [CC,R]=self.delTri.circumcenters();
            idx=~isfinite(R);
            refvxid=self.delTri.Triangulation(:,1);

            CC(idx)=[];
            R(idx)=[];
            refvxid(idx)=[];

            hboundary=h(refvxid)';


            numelemlayers=ceil(log(1-R*(1-Hgrad)./hboundary)/log(Hgrad));

            hCC=hboundary.*(Hgrad.^(numelemlayers-1));
            hCC=min(hCC,Hmax);

            myepsx=eps(0.5*(max(CC(:,1))-min(CC(:,1))))^(1/3);
            myepsy=eps(0.5*(max(CC(:,2))-min(CC(:,2))))^(1/3);
            xyv=matlab.internal.math.mergesimpts([CC(:,2),CC(:,1),hCC],[myepsy,myepsx,Inf],'average');
            ccx=xyv(:,2);
            ccy=xyv(:,1);
            hCC=xyv(:,3);
            CC=[ccx,ccy];
            ncc=size(CC,1);

            F.X(end+(1:ncc),:)=CC;
            F.V(end+(1:ncc))=hCC;
        end

    end

end

