



classdef DataHolder<handle

    properties(Access=private)
InputData
OutputData
InputPtr
OutputPtr
    end

    properties(Dependent)
InputCount
OutputCount
    end

    methods
        function obj=DataHolder(inputData,outputData)
            obj.InputData=[];
            obj.OutputData=[];
            obj.InputPtr=uint32(1);
            if nargin>=1
                if numel(inputData)~=0
                    obj.InputData=inputData;
                end
            end
            if nargin>=2
                if numel(outputData)~=0
                    obj.OutputData=outputData;
                end
            end
        end
        function count=get.InputCount(obj)
            count=uint32(0);
            if numel(obj.InputData)~=0
                count=uint32(1);
            end
            sz=size(obj.InputData);
            if numel(sz)==4
                count=uint32(sz(4));
            end
        end
        function count=get.OutputCount(obj)
            count=uint32(0);
            if numel(obj.OutputData)~=0
                count=uint32(1);
            end
            sz=size(obj.OutputData);
            if numel(sz)==4
                count=uint32(sz(4));
            end
        end

        function addInputData(obj,inputData)
            obj.InputPtr=uint32(1);
            obj.InputData=cat(4,obj.InputData,inputData);
        end
        function inputData=getInputData(obj,index)
            if obj.InputCount==0
                error("No Input Data available.");
            end
            if nargin<2
                index=obj.InputPtr;
                if obj.InputPtr==obj.InputCount
                    obj.InputPtr=uint32(1);
                else
                    obj.InputPtr=obj.InputPtr+uint32(1);
                end
            end
            if index>obj.InputCount
                error("Only %u Input Data are available.",obj.InputCount);
            end
            if obj.InputCount==1
                inputData=obj.InputData;
            else
                inputData=obj.InputData(:,:,:,index);
            end
        end

        function addOutputData(obj,outputData)
            obj.OutputPtr=uint32(1);
            obj.OutputData=cat(4,obj.OutputData,outputData);
        end
        function outputData=getOutputData(obj,index)
            if obj.OutputCount==0
                error("No Output Data available.");
            end
            if nargin<2
                index=obj.OutputPtr;
                if obj.OutputPtr==obj.OutputCount
                    obj.OutputPtr=uint32(1);
                else
                    obj.OutputPtr=obj.OutputPtr+uint32(1);
                end
            end
            if index>obj.OutputCount
                error("Only %u Output Data are available.",obj.OutputCount);
            end
            if obj.OutputCount==1
                outputData=obj.OutputData;
            else
                outputData=obj.OutputData(:,:,:,index);
            end
        end
    end
end

