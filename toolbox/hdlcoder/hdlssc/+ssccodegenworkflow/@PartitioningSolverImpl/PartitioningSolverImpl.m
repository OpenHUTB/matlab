classdef(Sealed=true,Hidden=true)PartitioningSolverImpl<handle











    properties(GetAccess=public,SetAccess=private,Hidden=true)

        LocationToDraw=''
        hIn=[];
        hOut=[];
        hValidOut=[];
        DataName=''



        NumSolverIter=5;
        SampleTime=0;
        NumInputs=0;


        EqnData=struct;
        EqnName=struct;


        latencyStrategy='MIN';

        systemLatency=1;


    end

    methods
        function obj=PartitioningSolverImpl(eqnData_in,name,locationToDraw_in,...
            hIn_in,hOut_in,hValidOut_in,numSolverIter_in,precision)

            if nargin<3
                locationToDraw_in='';
                hIn_in=[];
                hOut_in=[];
                hValidOut_in=[];
                numSolverIter_in=5;
                precision='single';
            end


            obj.LocationToDraw=locationToDraw_in;
            obj.hIn=hIn_in;
            obj.hOut=hOut_in;
            obj.hValidOut=hValidOut_in;
            obj.DataName=name;
            if strcmp(precision,'mixeddoublesingle')
                obj.EqnData.GlobalData.dataType='double';
                obj.EqnData.GlobalData.storageDataType='single';
            else
                obj.EqnData.GlobalData.dataType=precision;
                obj.EqnData.GlobalData.storageDataType=precision;
            end

            obj.NumSolverIter=numSolverIter_in;

            obj=obj.setupEqnData(eqnData_in);

        end



        function obj=setupEqnData(obj,eqnData_in)

            obj.SampleTime=eqnData_in.SampleTime;

            fModechart=matlab.internal.feature("SSC2HDLModechart");
            if(fModechart)
                if~isempty(eqnData_in.IC.X)
                    obj.EqnData.IC.X=eqnData_in.IC.X;
                else
                    obj.EqnData.IC.X=0;
                end
                obj.EqnName.IC.X=strcat(obj.DataName,'.IC.X');
                obj.EqnData.GlobalData.numStates=numel(obj.EqnData.IC.X);
            else
                if~isempty(eqnData_in.IC.X)
                    obj.EqnData.IC=eqnData_in.IC.X;
                else
                    obj.EqnData.IC=0;
                end
                obj.EqnName.IC=strcat(obj.DataName,'.IC');
                obj.EqnData.GlobalData.numStates=numel(obj.EqnData.IC);

            end

            obj.EqnData.DiffClumpInfo=eqnData_in.DiffClumpInfo;


            modeVec=zeros(numel(obj.EqnData.DiffClumpInfo.MatrixModes),numel(obj.EqnData.DiffClumpInfo.MatrixInfo));
            for configNum=1:numel(obj.EqnData.DiffClumpInfo.MatrixInfo)
                modeVec(:,configNum)=obj.EqnData.DiffClumpInfo.MatrixInfo(configNum).ModeVec;
            end
            obj.EqnData.DiffClumpInfo.ModeVec=modeVec;


            if(fModechart)
                qVec=zeros(numel(obj.EqnData.DiffClumpInfo.MatrixQs),numel(obj.EqnData.DiffClumpInfo.MatrixInfo));

                for configNum=1:numel(obj.EqnData.DiffClumpInfo.MatrixInfo)
                    qVec(:,configNum)=obj.EqnData.DiffClumpInfo.MatrixInfo(configNum).QVec;
                end

                obj.EqnData.DiffClumpInfo.QVec=qVec;
            end

            if~isempty(eqnData_in.ClumpInfo(1).ReferencedStates)
                obj.EqnData.ClumpInfo=eqnData_in.ClumpInfo;
            else
                obj.EqnData.ClumpInfo=[];
            end

            obj.EqnData.GlobalData.TotalIters=1;

            featIntModes=matlab.internal.feature("SSC2HDLIntegerModes");
            if(featIntModes)
                obj.EqnData.GlobalData.IntModes=eqnData_in.IntModes;
            end




            for i=1:numel(obj.EqnData.ClumpInfo)

                obj.EqnData.ClumpInfo(i).ModeFcn=obj.EqnData.ClumpInfo(i).ModeFcn;

                if(featIntModes)







                    obj.EqnData.ClumpInfo(i).ModeFcn=regexprep(obj.EqnData.ClumpInfo(i).ModeFcn,'int32(min(max(round(conditional','int32(round(conditional');
                    obj.EqnData.ClumpInfo(i).ModeFcn=regexprep(obj.EqnData.ClumpInfo(i).ModeFcn,', \(-2147483648.0)), \(2147483647.0))','');
                    obj.EqnData.ClumpInfo(i).ModeFcn=regexprep(obj.EqnData.ClumpInfo(i).ModeFcn,', \(0.0)), \(4294967295.0))','');
                end

                if isempty(obj.EqnData.ClumpInfo(i).ReferencedInputs)
                    obj.EqnData.ClumpInfo(i).ReferencedInputs=(1:obj.NumInputs)';

                end
                if isempty(obj.EqnData.ClumpInfo(i).ReferencedModes)
                    obj.EqnData.ClumpInfo(i).ReferencedModes=1;
                end

                if(featIntModes)
                    intModes=obj.EqnData.ClumpInfo(i).ReferencedModes(obj.EqnData.ClumpInfo(i).IntModes);
                    obj.EqnData.GlobalData.IntModes=[obj.EqnData.GlobalData.IntModes;intModes];
                end

                modeVec=zeros(numel(obj.EqnData.ClumpInfo(i).MatrixModes),numel(obj.EqnData.ClumpInfo(i).MatrixInfo));

                for configNum=1:numel(obj.EqnData.ClumpInfo(i).MatrixInfo)
                    modeVec(:,configNum)=obj.EqnData.ClumpInfo(i).MatrixInfo(configNum).ModeVec;
                end

                obj.EqnData.ClumpInfo(i).ModeVec=modeVec;


                if(fModechart)
                    qVec=zeros(numel(obj.EqnData.ClumpInfo(i).MatrixQs),numel(obj.EqnData.ClumpInfo(i).MatrixInfo));

                    for configNum=1:numel(obj.EqnData.ClumpInfo(i).MatrixInfo)
                        qVec(:,configNum)=obj.EqnData.ClumpInfo(i).MatrixInfo(configNum).QVec;
                    end

                    obj.EqnData.ClumpInfo(i).QVec=qVec;
                end

                if~isempty(obj.EqnData.ClumpInfo(i).ModeFcn)
                    obj.EqnData.GlobalData.TotalIters=obj.EqnData.GlobalData.TotalIters+obj.NumSolverIter-1;
                end

            end

            obj.EqnData.GlobalModeFcn=eqnData_in.GlobalModeFcn;

            if(fModechart)
                obj.EqnData.QFcn=eqnData_in.QFcn;
                obj.EqnData.CacheFcn=eqnData_in.CacheFcn;
            end

            if(featIntModes)







                obj.EqnData.GlobalModeFcn=regexprep(obj.EqnData.GlobalModeFcn,'int32(min(max(round(conditional','int32(round(conditional');
                obj.EqnData.GlobalModeFcn=regexprep(obj.EqnData.GlobalModeFcn,', \(-2147483648.0)), \(2147483647.0))','');
                obj.EqnData.GlobalModeFcn=regexprep(obj.EqnData.GlobalModeFcn,', \(0.0)), \(4294967295.0))','');
            end

            obj.EqnData.ModeIndices=eqnData_in.ModeIndices;

            obj.EqnData.Y=eqnData_in.Y;


            obj.EqnData.IM=utilInitalizeModeVector(obj.EqnData);
            obj.EqnName.IM=strcat(obj.DataName,'.IM');

            if(fModechart)
                obj.EqnName.IC.Q=strcat(obj.DataName,'.IC.Q');
                obj.EqnData.IC.Q=eqnData_in.IC.Q;
                obj.EqnData.GlobalData.numQs=numel(eqnData_in.IC.Q);

                obj.EqnName.IC.CI=strcat(obj.DataName,'.IC.CI');
                obj.EqnData.IC.CI=eqnData_in.IC.C;
                obj.EqnData.GlobalData.numCIs=numel(eqnData_in.IC.C);

                if numel(eqnData_in.IC.C)==0
                    obj.EqnData.IC.CI=0;
                end
            else
                obj.EqnData.GlobalData.numQs=0;
                obj.EqnData.GlobalData.numCIs=0;
            end

            obj.EqnData.GlobalData.totalModes=numel(obj.EqnData.IM);
            obj.EqnData.GlobalData.sampleTime=obj.SampleTime/obj.EqnData.GlobalData.TotalIters;
        end

    end
    methods(Access=public,Hidden=true)

        obj=discretizeEqns(obj)


        drawSolver(obj)

        saveData(obj)
        report=extractEquationsReport(obj)
        report=discretizeReport(obj)


        function obj=setLocationToDraw(obj,locIn)
            obj.LocationToDraw=locIn;
        end
        function obj=sethInhOut(obj,hIn_in,hOut_in,hValidOut_in)
            obj.hIn=hIn_in;
            obj.hOut=hOut_in;
            obj.hValidOut=hValidOut_in;
        end
        function obj=setDataType(obj,dataType_in)
            if strcmp(dataType_in,'mixeddoublesingle')
                obj.EqnData.GlobalData.dataType='double';
                obj.EqnData.GlobalData.storageDataType='single';
            else
                obj.EqnData.GlobalData.dataType=dataType_in;
                obj.EqnData.GlobalData.storageDataType=dataType_in;
            end

        end
        function obj=setSampleTime(obj,sampleTime_in)
            obj.SampleTime=sampleTime_in;
            obj.EqnData.GlobalData.sampleTime=obj.SampleTime/obj.EqnData.GlobalData.TotalIters;

        end
        function totalIters=setNumSolverIter(obj,numSolverIter_in)
            obj.NumSolverIter=numSolverIter_in;

            obj.EqnData.GlobalData.TotalIters=1;
            for i=1:numel(obj.EqnData.ClumpInfo)

                if~isempty(obj.EqnData.ClumpInfo(i).ModeFcn)
                    obj.EqnData.GlobalData.TotalIters=obj.EqnData.GlobalData.TotalIters+obj.NumSolverIter-1;
                end
            end


            obj.EqnData.GlobalData.sampleTime=obj.SampleTime/obj.EqnData.GlobalData.TotalIters;
            obj.EqnData.GlobalData.NumSolverIter=obj.NumSolverIter;
            totalIters=obj.EqnData.GlobalData.TotalIters;
        end
        function obj=setNumInputs(obj,numInputs)
            obj.EqnData.GlobalData.numInputs=numInputs;
        end
        function[maxConfigs,totalBytes]=getMaxConfigs(obj)


            maxConfigs=0;
            totalBytes=0;
            if~isempty(obj.EqnData.DiffClumpInfo)
                maxConfigs=size(obj.EqnData.DiffClumpInfo.MdInv,2);


                totalBytes=8*numel(obj.EqnData.DiffClumpInfo.MdInv);
            end
            for i=1:numel(obj.EqnData.ClumpInfo)
                maxConfigs=max([maxConfigs,size(obj.EqnData.ClumpInfo(i).Ad,3)]);
                totalBytes=totalBytes+8*numel(obj.EqnData.ClumpInfo(i).Ad);
                totalBytes=totalBytes+8*numel(obj.EqnData.ClumpInfo(i).MdInv);
            end

        end
    end
end


