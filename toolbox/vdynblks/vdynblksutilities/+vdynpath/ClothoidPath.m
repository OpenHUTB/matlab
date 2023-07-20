classdef ClothoidPath<handle




%#codegen
































    properties

PathPoints



SegStarts
    end

    properties

Waypoints
    end

    properties(Access=private)
        samplingDistance=0.05;
        appendDistance=100;
    end

    methods
        function obj=ClothoidPath(waypoints)





            if size(waypoints,2)~=2&&size(waypoints,2)~=3&&~isempty(waypoints)
                error('Waypoints must be double arrays of size N-by-2 or N-by-3!')
            end
            coder.varsize('waypoints');
            obj.Waypoints=waypoints;
        end

        function set.Waypoints(obj,waypoints)







            obj.UpdatePathPoints(waypoints);

            obj.Waypoints=waypoints;

        end

        function autoAppendWaypoints(obj)






            lastTwoPoints=obj.Waypoints(end-1:end,:);
            A=lastTwoPoints(1,:);
            B=lastTwoPoints(2,:);

            if size(obj.Waypoints,2)==2

                distanceAB=sqrt((A(1)-B(1)).^2+(A(2)-B(2)).^2);
                C=1/distanceAB.*[obj.appendDistance*(B(1)-A(1))+distanceAB*B(1),obj.appendDistance*(B(2)-A(2))+distanceAB*B(2)];
            else

                C=[B(1)+obj.appendDistance*cos(B(3)),B(2)+obj.appendDistance*sin(B(3)),B(3)];
            end

            obj.Waypoints=[obj.Waypoints;C];
        end

        function obj=UpdatePathPoints(obj,waypoints)







            if size(waypoints,2)==3
                course=waypoints(:,3);
            else
                course=matlabshared.tracking.internal.scenario.clothoidG2fitCourse(waypoints);
            end


            n=size(waypoints,1);
            initialPosition=complex(waypoints(:,1),waypoints(:,2));
            [initialCurvature,finalCurvature,arcLength]=matlabshared.tracking.internal.scenario.clothoidG1fit2(initialPosition(1:n-1),course(1:n-1),initialPosition(2:n),course(2:n));
            cumulativeLength=[0;cumsum(arcLength)];
            dS=obj.samplingDistance;
            s=[(0:(ceil(cumulativeLength(end)*(1/dS))-1))*dS,cumulativeLength(end)]';
            [x,y,theta,kappa,dkappa]=resampleClothoid();
            obj.PathPoints=[x,y,theta,kappa,dkappa,s];
            obj.SegStarts=[real(initialPosition),imag(initialPosition),vdynutils.wrapToPi(course),[initialCurvature;finalCurvature(end)],[(finalCurvature-initialCurvature)./arcLength;(finalCurvature(end)-initialCurvature(end))/arcLength(end)],cumulativeLength];

            function[x,y,theta,kappa,dkappa]=resampleClothoid()






                segmentIdx=discretize(s,cumulativeLength);


                dk=(finalCurvature(segmentIdx)-initialCurvature(segmentIdx))./arcLength(segmentIdx);




                L=s-cumulativeLength(segmentIdx);


                xy=matlabshared.tracking.internal.scenario.fresnelg2(L,dk,initialCurvature(segmentIdx),course(segmentIdx));
                dxy=matlabshared.tracking.internal.scenario.dfresnelg2(L,dk,initialCurvature(segmentIdx),course(segmentIdx));


                x=real(xy+initialPosition(segmentIdx));
                y=imag(xy+initialPosition(segmentIdx));


                theta=atan2(imag(dxy),real(dxy));


                kappa=initialCurvature(segmentIdx)+L.*dk;


                dkappa=gradient(kappa)./gradient(s);
            end
        end

        function closestPoint=closestPoint(obj,xyPoints)




            closestPoint=zeros(size(xyPoints,1),6);
            for i=1:size(xyPoints,1)
                xyPoint=xyPoints(i,1:2);


                [~,index]=min(sum([obj.PathPoints(:,1)-xyPoint(1),obj.PathPoints(:,2)-xyPoint(2)].^2,2));


                closestPoint(i,1:6)=obj.projectedPoint(index,xyPoint);
            end
        end

        function closestPoint=closestPointInHrzn(obj,xyPoints,arcLength,arcLengthHorizon)










            if arcLength(end)+arcLengthHorizon>=obj.PathPoints(end,6)
                autoAppendWaypoints(obj);
            end

            closestPoint=zeros(size(xyPoints,1),6);
            for i=1:size(xyPoints,1)
                xyPoint=xyPoints(i,1:2);
                s=arcLength(i);


                arcLengthBeyond=obj.PathPoints(:,6)-s;
                arcLengthBeyond(arcLengthBeyond<0)=inf;
                [~,minIndex]=min(arcLengthBeyond);



                arcLengthBeyondHrz=obj.PathPoints(:,6)-s-arcLengthHorizon;
                arcLengthBeyondHrz(arcLengthBeyondHrz<0)=inf;
                [~,maxIndexPlusOne]=min(arcLengthBeyondHrz);
                maxIndex=maxIndexPlusOne-1;




                PathPointsInSearchRange=obj.PathPoints(minIndex:maxIndex,:);

                [~,indexInSearchRange]=min(sum([PathPointsInSearchRange(:,1)-xyPoint(1),PathPointsInSearchRange(:,2)-xyPoint(2)].^2,2));

                index=minIndex+indexInSearchRange-1;


                closestPoint(i,1:6)=obj.projectedPoint(index,xyPoint);
            end
        end

        function pathPoint=projectedPoint(obj,index,xyPoint)











            if index==size(obj.PathPoints,1)

                v0x=xyPoint(1)-obj.PathPoints(end,1);
                v0y=xyPoint(2)-obj.PathPoints(end,2);
                v1x=obj.PathPoints(end-1,1)-obj.PathPoints(end,1);
                v1y=obj.PathPoints(end-1,2)-obj.PathPoints(end,2);
                dotV=v0x*v1x+v0y*v1y;
                if dotV<=0

                    pathPoint=obj.PathPoints(end,:);
                    return;
                else

                    v0x=xyPoint(1)-obj.PathPoints(end-1,1);
                    v0y=xyPoint(2)-obj.PathPoints(end-1,2);
                    v1x=obj.PathPoints(end,1)-obj.PathPoints(end-1,1);
                    v1y=obj.PathPoints(end,2)-obj.PathPoints(end-1,2);
                    dotV=v0x*v1x+v0y*v1y;
                    startIdx=size(obj.PathPoints,1)-1;
                end
            elseif index==1

                v0x=xyPoint(1)-obj.PathPoints(1,1);
                v0y=xyPoint(2)-obj.PathPoints(1,2);
                v1x=obj.PathPoints(2,1)-obj.PathPoints(1,1);
                v1y=obj.PathPoints(2,2)-obj.PathPoints(1,2);
                dotV=v0x*v1x+v0y*v1y;
                if dotV<=0

                    pathPoint=obj.PathPoints(1,:);
                    return;
                else

                    startIdx=1;
                end
            else

                nearestXY=obj.PathPoints(index,1:2);
                if(xyPoint-nearestXY)*(nearestXY-obj.PathPoints(index-1,1:2))'<0

                    startIdx=index-1;
                    endIdx=index;
                else

                    startIdx=index;
                    endIdx=index+1;
                end

                v0x=xyPoint(1)-obj.PathPoints(startIdx,1);
                v0y=xyPoint(2)-obj.PathPoints(startIdx,2);
                v1x=obj.PathPoints(endIdx,1)-obj.PathPoints(startIdx,1);
                v1y=obj.PathPoints(endIdx,2)-obj.PathPoints(startIdx,2);
                dotV=v0x.*v1x+v0y.*v1y;
            end


            v1Norm=sqrt(v1x.*v1x+v1y.*v1y);
            deltaS=dotV/v1Norm;
            pathPoint=obj.interpolate(obj.PathPoints(startIdx,6)+deltaS);
        end

        function[pathPoints,index]=interpolate(obj,arcLength)








            index=floor(arcLength*(1./obj.samplingDistance))+1;


            pathPoints=repmat(obj.PathPoints(end,:),numel(arcLength),1);


            initIdx=index<=0;
            pathPoints(initIdx,:)=repmat(obj.PathPoints(1,:),nnz(initIdx),1);


            validMask=~initIdx&arcLength<obj.PathPoints(end);
            validIdx=index(validMask);
            if~isempty(validIdx)
                interpolatedPts=obj.getClosestPathPointS(obj.PathPoints,validIdx,validIdx+1,arcLength(validMask));
                pathPoints(validMask,:)=interpolatedPts;
            end
        end

        function length=getLength(obj)


            length=obj.PathPoints(end,6);
        end

        function axisH=plot(obj)





            axisH=newplot;
            plot(axisH,obj.Waypoints(:,1),obj.Waypoints(:,2),'go','MarkerFaceColor','g',...
            'MarkerSize',8,'Tag','Waypoints','Displayname','Waypoints');
            hold(axisH,'on')
            plot(axisH,obj.PathPoints(:,1),obj.PathPoints(:,2),'g','Tag','Reference Path',...
            'LineWidth',2,'Displayname','PathPoints');
            axis equal
        end

        function axisH=plotClosestPoints(obj,xyPoints,varargin)













            if size(xyPoints,2)~=2
                error('xyPoints must be double arrays of size N by 2!')
            end

            p=inputParser;
            addRequired(p,'xyPoints',@(x)isnumeric(x)&&size(x,2)==2)
            addParameter(p,'projection','off',@(x)any(validatestring(x,{'on','off'})));
            parse(p,xyPoints,varargin{:});

            closestPoints=obj.closestPoint(xyPoints);
            closestPointsXY=closestPoints(:,1:2);

            axisH=obj.plot();
            plot(axisH,xyPoints(:,1),xyPoints(:,2),'bo','MarkerFaceColor','b','MarkerSize',6,...
            'Displayname','xyPoints')
            plot(axisH,closestPointsXY(:,1),closestPointsXY(:,2),'bo','MarkerSize',6,...
            'Displayname','ClosestPoints')
            legendH=legend('Location','best');
            if strcmp(p.Results.projection,'on')
                x=[xyPoints(:,1)';closestPointsXY(:,1)'];
                y=[xyPoints(:,2)';closestPointsXY(:,2)'];
                line(axisH,x,y,'Color','b','LineWidth',1);


                legend(legendH.String{1:4},'Location','best')
            end
        end

        function axisH=plotClosestPointsInHrzn(obj,xyPoints,varargin)













            if size(xyPoints,2)~=2
                error('xyPoints must be double arrays of size N by 2!')
            end

            p=inputParser;
            validScalarNonNegNum=@(x)isnumeric(x)&&isscalar(x)&&(x>0);
            validScalarPosNum=@(x)isnumeric(x)&&isscalar(x)&&(x>0);
            addRequired(p,'xyPoints',@(x)isnumeric(x)&&size(x,2)==2)
            addParameter(p,'projection','off',@(x)any(validatestring(x,{'on','off'})));
            addParameter(p,'horizon','off',@(x)any(validatestring(x,{'on','off'})));
            addParameter(p,'hrznStart',0,validScalarNonNegNum);
            addParameter(p,'hrznLength',10,validScalarPosNum);
            parse(p,xyPoints,varargin{:});

            closestPoints=obj.closestPointInHrz(xyPoints,p.Results.hrzStart,p.Results.hrznLength);
            closestPointsXY=closestPoints(:,1:2);

            axisH=obj.plot();
            plot(axisH,xyPoints(:,1),xyPoints(:,2),'bo','MarkerFaceColor','b','MarkerSize',6,...
            'Displayname','xyPoints')
            plot(axisH,closestPointsXY(:,1),closestPointsXY(:,2),'bo','MarkerSize',6,...
            'Displayname','ClosestPoints')
            legendH=legend('Location','best');
            if strcmp(p.Results.projection,'on')
                x=[xyPoints(:,1)';closestPointsXY(:,1)'];
                y=[xyPoints(:,2)';closestPointsXY(:,2)'];
                line(axisH,x,y,'Color','b','LineWidth',1);


                legend(legendH.String{1:4},'Location','best')
            end
        end

        function obj=SetSamplingDistance(obj,ds)

            obj.samplingDistance=ds;
        end

        function ds=GetSamplingDistance(obj)

            ds=obj.samplingDistance;
        end
    end

    methods(Static)
        function pathPoint=getClosestPathPointS(pathPoints,startIdx,endIdx,s)





            coder.inline('never');

            startPoint=pathPoints(startIdx,:);
            endPoint=pathPoints(endIdx,:);



            weight=abs(s-startPoint(:,6))./(endPoint(:,6)-startPoint(:,6));

            x=(1-weight).*startPoint(:,1)+weight.*endPoint(:,1);
            y=(1-weight).*startPoint(:,2)+weight.*endPoint(:,2);

            kappa=(1-weight).*startPoint(:,4)+weight.*endPoint(:,4);
            dkappa=(1-weight).*startPoint(:,5)+weight.*endPoint(:,5);


            theta=vdynpath.ClothoidPath.slerpInterp(startPoint(:,3),startPoint(:,6),endPoint(:,3),endPoint(:,6),s);


            pathPoint=[x,y,theta,kappa,dkappa,s];
        end

        function[theta]=slerpInterp(a0,t0,a1,t1,t)


            if(abs(t1-t0)<=eps)
                theta=a0;
            else
                a0n=vdynutils.wrapToPi(a0);
                a1n=vdynutils.wrapToPi(a1);
                d=vdynutils.angdiff(a0n,a1n);
                r=(t-t0)./(t1-t0);
                a=a0n+d.*r;
                theta=vdynutils.wrapToPi(a);
            end
        end
    end
end

