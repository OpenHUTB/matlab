classdef PoseGenerator<matlab.System

%#codegen





    properties(Nontunable)

        ShowRefPath(1,1)logical=true;
        RollingSegment(1,1)logical=false;
        SegLen=1000;
        LoopTrajectory(1,1)logical=false;
    end


    properties(Constant)


        numOfHrzPoints=20;
    end


    properties(Access=private)






        arcLengthGlobal=0;



        arcLengthHorizon=100;



        arcLengthLrgSegStart=0;






        PathLength;








        ReferencePathPoints;










        ReferencePath;



        RefPathPlotSwitch=1;





        Theta;





        ThetaUnwrapped;





        ThetaRef;





        ThetaRefUnwrapped;

    end




    methods

        function obj=PoseGenerator(varargin)
            coder.allowpcode('plain');

            setProperties(obj,nargin,varargin{:});




            coder.varsize('referencePathPoints');
            referencePathPoints=[0,0;60,0];
            obj.ReferencePathPoints=referencePathPoints;
            obj.ReferencePath=vdynpath.ClothoidPath(referencePathPoints);



            obj.Theta=0;
            obj.ThetaRef=0;
            obj.ThetaUnwrapped=0;
            obj.ThetaRefUnwrapped=0;
        end

        function thetaUnwrapped=thetaUnwrap(obj,theta)







            uprBndCrs=(obj.Theta>0.5*pi)*(theta<-0.5*pi);
            lwrBndCrs=(obj.Theta<-0.5*pi)*(theta>0.5*pi);

            numOf2Pi=floor((obj.ThetaUnwrapped+pi-1e-6)/(2*pi))...
            +(uprBndCrs-lwrBndCrs);





            thetaUnwrapped=theta+numOf2Pi*2*pi;
        end

        function thetaUnwrapped=thetaRefUnwrap(obj,thetaRef)






            numOf2PiPreviously=floor((obj.ThetaRefUnwrapped+pi)/(2*pi));
            uprBndCrs=(obj.ThetaRefUnwrapped-numOf2PiPreviously*2*pi>0.5*pi)*(thetaRef<-0.5*pi);
            lwrBndCrs=(obj.ThetaRefUnwrapped-numOf2PiPreviously*2*pi<-0.5*pi)*(thetaRef>0.5*pi);

            numOf2Pi=numOf2PiPreviously+(uprBndCrs-lwrBndCrs);





            thetaUnwrapped=thetaRef+numOf2Pi*2*pi;
        end

        function[s,e,kRef,phi,phiRef,refPose,hrzPathPoint]=testStep(obj,refPath,vehiclePose)
            [s,e,kRef,phi,phiRef,refPose,hrzPathPoint]=stepImpl(obj,refPath,vehiclePose);
        end

    end




    methods(Access=protected)

        function setupImpl(obj)



            obj.PathLength=obj.ReferencePath.getLength();
        end

        function[arcLengthGlobal,pathLength,latError,kappaRef,dKappaRef,phi,phiRef,refPose,hrzPathPoint]...
            =stepImpl(obj,refPath,vehiclePose)










            closestRefPathPts=findClosestRef(obj,refPath,vehiclePose);


            if obj.ShowRefPath&&obj.RefPathPlotSwitch==1

                plot(obj.ReferencePath);
                axis equal
                title('Generated Reference Path')
                xlabel('X(m)')
                ylabel('Y(m)')
                obj.RefPathPlotSwitch=0;
            end

            refX=closestRefPathPts(1);
            refY=closestRefPathPts(2);
            refTheta=closestRefPathPts(3);


            refThetaWrapped=vdynutils.wrapToPi(refTheta);
            dx=vehiclePose(1)-refX;
            dy=vehiclePose(2)-refY;
            refCosTheta=cos(refThetaWrapped);
            refSinTheta=sin(refThetaWrapped);
            refNormal=refCosTheta.*dy-refSinTheta.*dx;
            l=vecnorm([dx,dy]')'.*sign(refNormal);
            pathLength=obj.PathLength;
            arcLengthCurrSeg=closestRefPathPts(6);
            arcLengthGlobal=arcLengthCurrSeg+obj.arcLengthLrgSegStart;
            kappaRef=closestRefPathPts(4);
            dKappaRef=closestRefPathPts(5);
            phiRef=thetaRefUnwrap(obj,refTheta);
            latError=l;
            refPose=[refX,refY,phiRef]';

            Xdot=vehiclePose(3);
            Ydot=vehiclePose(4);
            theta=atan2(Ydot,Xdot);
            obj.ThetaUnwrapped=thetaUnwrap(obj,theta);
            obj.Theta=theta;
            obj.ThetaRef=refTheta;
            obj.ThetaRefUnwrapped=phiRef;
            obj.arcLengthGlobal=arcLengthGlobal;


            phi=obj.ThetaUnwrapped;


            ds=obj.arcLengthHorizon/obj.numOfHrzPoints;
            hrzArray=arcLengthCurrSeg+linspace(0,(obj.numOfHrzPoints-1)*ds,obj.numOfHrzPoints)';
            hrzPathPoint=interpolate(obj.ReferencePath,hrzArray);
            hrzPathPoint(:,6)=hrzPathPoint(:,6)+obj.arcLengthLrgSegStart;
        end

        function closestRefPathPts=findClosestRef(obj,refPath,vehiclePose)










            if~isequal(refPath,obj.ReferencePathPoints)
                obj.ReferencePathPoints=refPath;
                obj.ReferencePath.UpdatePathPoints(obj.ReferencePathPoints);
                obj.PathLength=obj.ReferencePath.getLength();

                if obj.RollingSegment==1
                    takeFirstSegment(obj);
                else
                    obj.ReferencePath.Waypoints=refPath;
                end



                if obj.LoopTrajectory
                    closestRefPathPts=closestPoint(obj.ReferencePath,vehiclePose(1:2)');
                else



                    closestRefPathPts=closestPointInHrzn(obj.ReferencePath,vehiclePose(1:2)',0,obj.arcLengthHorizon);
                end

                arcLengthCurrSeg=closestRefPathPts(6);
                obj.arcLengthLrgSegStart=obj.arcLengthGlobal-arcLengthCurrSeg;
            end


            if obj.RollingSegment==1








                if obj.arcLengthGlobal>obj.arcLengthLrgSegStart+0.9*obj.SegLen











                    closestRefPoint=closestPoint(obj.ReferencePath,vehiclePose(1:2)');
                    arLengthGlobalOfCurrPose=obj.arcLengthLrgSegStart+closestRefPoint(6);

                    obj.ReferencePath.UpdatePathPoints(obj.ReferencePathPoints);
                    closestRefPoint=closestPoint(obj.ReferencePath,vehiclePose(1:2)');
                    arcLengthOfCurrPoseWRTReferencePathPoints=closestRefPoint(6);

                    arcLengthSegStarts=obj.ReferencePath.SegStarts(:,6);
                    arcLengthSegStarts(arcLengthSegStarts>=arcLengthOfCurrPoseWRTReferencePathPoints)=-inf;
                    [~,indMin]=max(arcLengthSegStarts);
                    arcLengthOfSegStartWRTReferencePathPoints=arcLengthSegStarts(indMin);

                    obj.arcLengthLrgSegStart=arLengthGlobalOfCurrPose-arcLengthOfCurrPoseWRTReferencePathPoints+arcLengthOfSegStartWRTReferencePathPoints;





                    arcLengthSegStarts=obj.ReferencePath.SegStarts(:,6);



                    haveNoPointsAheadOfSegment=isempty(find(arcLengthSegStarts>=(obj.arcLengthLrgSegStart+obj.SegLen),1));




                    if haveNoPointsAheadOfSegment

                        indCurrToEnd=indMin:numel(arcLengthSegStarts);
                        distanceCurrToEnd=obj.PathLength-arcLengthOfSegStartWRTReferencePathPoints;
                        distanceBeginningToLengthLimit=obj.SegLen-distanceCurrToEnd;

                        arcLengthSegStarts(arcLengthSegStarts>=distanceBeginningToLengthLimit)=-inf;
                        [~,indMax]=max(arcLengthSegStarts);
                        indBeginningToLengthLimit=1:indMax;

                        indicesSelected=[indCurrToEnd,indBeginningToLengthLimit];
                        obj.ReferencePath.Waypoints=obj.ReferencePathPoints(indicesSelected,:);
                    else
                        arcLengthSegStarts(arcLengthSegStarts>=(obj.arcLengthLrgSegStart+obj.SegLen))=-inf;
                        [~,indMax]=max(arcLengthSegStarts);

                        obj.ReferencePath.Waypoints=obj.ReferencePathPoints(indMin:indMax,:);
                    end
                end
            end


            if obj.LoopTrajectory
                closestRefPathPts=closestPoint(obj.ReferencePath,vehiclePose(1:2)');
            else
                closestRefPathPts=closestPointInHrzn(obj.ReferencePath,vehiclePose(1:2)',obj.arcLengthGlobal-obj.arcLengthLrgSegStart,obj.arcLengthHorizon);
            end

        end

        function takeFirstSegment(obj)





            indMin=1;

            obj.ReferencePath.UpdatePathPoints(obj.ReferencePathPoints);
            arcLengthSegStarts=obj.ReferencePath.SegStarts(:,6);
            arcLengthSegStarts(arcLengthSegStarts>=obj.SegLen)=-inf;
            [~,indMax]=max(arcLengthSegStarts);
            obj.ReferencePath.Waypoints=obj.ReferencePathPoints(indMin:indMax,:);

        end

    end




    methods(Access=protected)

        function[arcLength,pathLength,latError,kappaRef,dKappaRef,phi,phiRef,refPose,hrzPathPoint]...
            =getOutputSizeImpl(~)

            arcLength=[1,1];
            pathLength=[1,1];
            latError=[1,1];
            kappaRef=[1,1];
            dKappaRef=[1,1];
            phi=[1,1];
            phiRef=[1,1];
            refPose=[3,1];
            hrzPathPoint=[20,6];
        end

        function[arcLength,pathLength,latError,kappaRef,dKappaRef,phi,phiRef,refPose,hrzPathPoint]...
            =getOutputDataTypeImpl(~)

            arcLength="double";
            pathLength="double";
            latError="double";
            kappaRef="double";
            dKappaRef="double";
            phi="double";
            phiRef="double";
            refPose="double";
            hrzPathPoint="double";
        end

        function[arcLength,pathLength,latError,kappaRef,dKappaRef,phi,phiRef,refPose,hrzPathPoint]...
            =isOutputComplexImpl(~)

            arcLength=false;
            pathLength=false;
            latError=false;
            kappaRef=false;
            dKappaRef=false;
            phi=false;
            phiRef=false;
            refPose=false;
            hrzPathPoint=false;
        end

        function[arcLength,pathLength,latError,kappaRef,dKappaRef,phi,phiRef,refPose,hrzPathPoint]...
            =isOutputFixedSizeImpl(~)

            arcLength=true;
            pathLength=true;
            latError=true;
            kappaRef=true;
            dKappaRef=true;
            phi=true;
            phiRef=true;
            refPose=true;
            hrzPathPoint=true;
        end
        function flag=supportsMultipleInstanceImpl(~)
            flag=true;
        end
    end

end
