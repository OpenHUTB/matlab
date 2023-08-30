classdef Specification<handle&matlab.mixin.Heterogeneous&matlab.mixin.Copyable

    properties
        Name='';
    end


    methods

        function this=Specification(varargin)
            for indx=1:2:numel(varargin)
                this.(varargin{indx})=varargin{indx+1};
            end
        end


        function variableName=getMatlabVariableName(this)
            variableName=matlab.lang.makeValidName(this.Name);
            variableName(1)=lower(variableName(1));
        end


        function printName=getMatlabPrintName(this)
            printName=string(this.Name);
            printName=printName.replace("'","''");
            printName=printName.char;
        end
    end


    methods(Sealed)
        function b=eq(varargin)
            b=eq@handle(varargin{:});
        end


        function out=findobj(varargin)
            out=findobj@handle(varargin{:});
        end
    end

    methods(Abstract)
        convertAxesOrientation(this,old,new)
    end

    methods(Static)
        function[points,pointIndex]=insertIntoClothoid(points,newLocation,speeds)

            if nargin<3
                speeds=[];
            end


            if size(points,1)==2
                points=[points(1,:);newLocation;points(2,:)];
                pointIndex=1;
                return;
            end

            if isempty(speeds)||~(any(speeds<0)&&any(speeds>0))


                [x,y]=driving.scenario.clothoid(points(:,1),points(:,2));
            else
                numPoints=size(points,1);
                brkIndx=find(speeds==0);
                if brkIndx(end)==numPoints
                    numPaths=length(brkIndx);
                else
                    numPaths=length(brkIndx)+1;
                    brkIndx(end+1)=numPoints;
                end
                upIndx=0;
                numUpPoints=numPaths+1024*(size(points,1)-1);
                x=zeros(numUpPoints,1);
                y=zeros(numUpPoints,1);
                for mndx=1:numPaths

                    if mndx==1
                        stIndx=1;
                    else
                        stIndx=brkIndx(mndx-1);
                    end
                    pathIndx=stIndx:brkIndx(mndx);
                    subwaypoints=points(pathIndx,:);
                    [subx,suby]=driving.scenario.clothoid(subwaypoints(:,1),subwaypoints(:,2));
                    cNumUp=length(subx);
                    x(upIndx+1:upIndx+cNumUp)=subx;
                    y(upIndx+1:upIndx+cNumUp)=suby;
                    upIndx=upIndx+cNumUp;
                end
            end

            pointIndex=ceil(driving.internal.scenarioApp.Specification.findClosestIndex([x,y,zeros(size(y))],newLocation)/1024);
            points=[points(1:pointIndex,:);newLocation;points(pointIndex+1:end,:)];
        end

        function index=findClosestIndex(values,point)

            [~,index]=min(sum((values-point).^2,2));

        end

        function[K,isSameAsLastWaypointIndex]=getMatchingPointIndex(position,waypoints,unitsPerPixel,howMany)



            tol=10*unitsPerPixel;
            K=[];
            if nargin<4||size(waypoints,1)<3
                howMany=1;
            end
            isSameAsLastWaypointIndex=false;
            if~isempty(waypoints)


                distance=sqrt(sum((waypoints(:,1:2)-position(1:2)).^2,2));


                allK=find(distance<=tol);


                [~,indx]=sort(distance(allK));
                K=allK(indx);



                K=K(1:min(end,howMany));
                if nargout>1
                    isSameAsLastWaypointIndex=~isempty(allK)&&(allK(end)==size(waypoints,1));
                end
            end
        end

        function isLoop=isWaypointLooping(waypoints,unitsPerPixel)


            isLoop=false;
            if size(waypoints,1)>1
                tol=max(1,round(8*unitsPerPixel));
                isLoop=sum(abs(waypoints(1,1:2)-waypoints(end,1:2))<=tol,2)==2;
            end
        end
    end
end


