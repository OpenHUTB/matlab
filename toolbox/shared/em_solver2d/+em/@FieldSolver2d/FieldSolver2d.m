classdef FieldSolver2d<matlab.mixin.SetGet&matlab.mixin.CustomDisplay&matlab.mixin.Copyable



    properties(Constant,Hidden)

        Equation=3
    end

    properties(Hidden)

Name



        codeSub(1,1)


        numSub(1,1)=1


        conductivity(1,1)=5.8e7


        groundPlaneWidth(1,1)


groundPlaneCorner
    end

    properties(Hidden,Dependent)

thickSub


epsilonRSub


lossTangentSub


numTrace


widthTrace


thickTrace


xCoordTrace
yCoordTrace


hasTraceOnTopLayer

    end

    properties(Hidden,Dependent)
numLayer
yCoordSub
idxTraceAtInterface
separationTraceAtInterface
    end

    properties(Access=protected)
protectedThickSub
protectedEpsilonRSub
protectedLossTangentSub
        protectedNumTrace=1
protectedWidthTrace
protectedThickTrace
protectedXCoordTrace
protectedYCoordTrace
        protectedHasTraceOnTopLayer(1,1)=false
    end

    methods
        function f=FieldSolver2d(varargin)
        end
    end

    methods(Hidden)
        fileName=generateIN8(obj)
        generateCFG(obj,frequency,dir)
        generateLPARIN(obj,mesh,dir)
        Mesh=createMesh(obj)
        Pulse=getPulse(obj,gp,minPulse,maxPulse,meshAccuracy,meshPower)
        Node=getNode(obj,pulse)
        savelinpar(obj,l)
        [TxParams,errorId]=solve(obj,dir)
    end

    methods(Static,Access=protected)
        [RLGC,errorId]=Linpar(fileName,BackDoor,varargin)
    end

    methods
        function set.Name(obj,name)
            mustBeMember(name,{'single','differential','custom'})
            obj.Name=name;
        end

        function set.codeSub(obj,propVal)
            validateattributes(propVal,{'int8'},...
            {'>=',-1,'<=',2},'FieldSolver2d','codeSub');
            obj.codeSub=propVal;
        end

        function set.numSub(obj,propVal)
            validateattributes(propVal,{'uint8'},...
            {'>=',1,'<=',4},'FieldSolver2d','numSub');
            obj.numSub=propVal;
        end

        function set.thickSub(obj,propVal)
            validateattributes(propVal,{'double'},...
            {'numel',obj.numSub,'positive'},'FieldSolver2d','thickSub');
            obj.protectedThickSub=propVal;
        end

        function propVal=get.thickSub(obj)
            propVal=obj.protectedThickSub;
        end

        function set.epsilonRSub(obj,propVal)
            validateattributes(propVal,{'double'},...
            {'numel',obj.numSub,'positive'},'FieldSolver2d','epsilonRSub');
            obj.protectedEpsilonRSub=propVal;
        end

        function propVal=get.epsilonRSub(obj)
            propVal=obj.protectedEpsilonRSub;
        end

        function set.lossTangentSub(obj,propVal)
            validateattributes(propVal,{'double'},...
            {'numel',obj.numSub,'nonnegative'},'FieldSolver2d','lossTangentSub');
            obj.protectedLossTangentSub=propVal;
        end

        function propVal=get.lossTangentSub(obj)
            propVal=obj.protectedLossTangentSub;
        end

        function set.numTrace(obj,propVal)
            validateattributes(propVal,{'uint8'},...
            {'numel',obj.numLayer,'>=',0,'<=',102},'FieldSolver2d','numTrace');
            if sum(propVal)<1
                error(message('antenna:antennaerrors:InvalidValueGreaterEqual',...
                'numTrace','1'));
            end
            obj.protectedNumTrace=propVal;
        end

        function propVal=get.numTrace(obj)
            propVal=obj.protectedNumTrace;
        end

        function set.widthTrace(obj,propVal)
            validateattributes(propVal,{'cell'},...
            {'numel',obj.numLayer},'FieldSolver2d','widthTrace');
            for iSub=1:obj.numLayer
                validateattributes(propVal{iSub},{'double'},...
                {'numel',obj.numTrace(iSub),'positive'},...
                'FieldSolver2d','widthTrace');
            end
            obj.protectedWidthTrace=propVal;
        end

        function propVal=get.widthTrace(obj)
            propVal=obj.protectedWidthTrace;
        end

        function set.thickTrace(obj,propVal)
            validateattributes(propVal,{'cell'},...
            {'numel',obj.numLayer},'FieldSolver2d','thickTrace');
            for iSub=1:obj.numLayer
                validateattributes(propVal{iSub},{'double'},...
                {'numel',obj.numTrace(iSub),'nonnegative'},...
                'FieldSolver2d','thickTrace');
            end
            obj.protectedThickTrace=propVal;
        end

        function propVal=get.thickTrace(obj)
            propVal=obj.protectedThickTrace;
        end

        function set.xCoordTrace(obj,propVal)
            validateattributes(propVal,{'cell'},...
            {'numel',obj.numLayer},'FieldSolver2d','xCoordTrace');
            for iSub=1:obj.numLayer
                validateattributes(propVal{iSub},{'double'},...
                {'numel',obj.numTrace(iSub)},...
                'FieldSolver2d','xCoordTrace');
            end
            obj.protectedXCoordTrace=propVal;
        end

        function propVal=get.xCoordTrace(obj)
            propVal=obj.protectedXCoordTrace;
        end

        function set.yCoordTrace(obj,propVal)
            validateattributes(propVal,{'cell'},...
            {'numel',obj.numLayer},'FieldSolver2d','yCoordTrace');
            for iSub=1:obj.numLayer
                validateattributes(propVal{iSub},{'double'},...
                {'numel',obj.numTrace(iSub),'positive'},...
                'FieldSolver2d','yCoordTrace');
            end
            obj.protectedYCoordTrace=propVal;
        end

        function propVal=get.yCoordTrace(obj)
            propVal=obj.protectedYCoordTrace;
        end

        function set.hasTraceOnTopLayer(obj,propVal)
            validateattributes(propVal,{'logical'},{},'FieldSolver2d','hasTraceOnTopLayer');
            if obj.codeSub>0
                obj.protectedHasTraceOnTopLayer=false;
            else
                obj.protectedHasTraceOnTopLayer=propVal;
            end
        end

        function propVal=get.hasTraceOnTopLayer(obj)
            propVal=obj.protectedHasTraceOnTopLayer;
        end

        function set.conductivity(obj,propVal)
            validateattributes(propVal,{'double'},...
            {'numel',1,'positive','finite'},'FieldSolver2d','conductivity');
            obj.conductivity=propVal;
        end

        function set.groundPlaneWidth(obj,propVal)
            validateattributes(propVal,{'double'},...
            {'positive','finite'},'FieldSolver2d','groundPlaneWidth');
            obj.groundPlaneWidth=propVal;
        end

        function set.groundPlaneCorner(obj,propVal)
            validateattributes(propVal,{'double'},...
            {'numel',2,'finite'},'FieldSolver2d','groundPlaneCorner');
            obj.groundPlaneCorner=propVal;
        end

        function propVal=get.numLayer(obj)
            if obj.hasTraceOnTopLayer
                propVal=obj.numSub+1;
            else
                propVal=obj.numSub;
            end
        end

        function propVal=get.yCoordSub(obj)
            propVal=[0,cumsum(obj.thickSub)];
        end

        function propVal=get.idxTraceAtInterface(obj)
            nl=obj.numLayer;
            y=obj.yCoordSub;
            propVal=cell(1,nl);
            for i=1:nl
                idx=find(abs(obj.yCoordTrace{i}-y(i))<eps);
                [~,I]=sort(obj.xCoordTrace{i}(idx));
                propVal{1,i}=idx(I);
            end
        end

        function propVal=get.separationTraceAtInterface(obj)
            nl=obj.numLayer;
            idx=obj.idxTraceAtInterface;
            propVal=cell(1,nl);
            for i=1:nl
                if length(idx{i})>1
                    s=zeros(1,length(idx{i})-1);
                    for j=1:length(idx{i})-1
                        x1=obj.xCoordTrace{i}(idx{i}(j))+obj.widthTrace{i}(idx{i}(j));
                        x2=obj.xCoordTrace{i}(idx{i}(j+1));
                        s(j)=abs(x2-x1);
                    end
                    propVal{i}=s;
                end
            end
        end
    end
end

