



classdef TestBenchData<handle
    properties

        EntryPointCalled;

        EntryPointTypes;

        ConstantInputs;

        NumberOfOutputs;



ActualEntryPointToCall



LogFcnName


        InputLogIndices;
        OutputLogIndices;

        OutputParamCount;
    end
    properties(SetAccess=private,GetAccess=private)

        EntryPointFile;

        InterceptorFile;

        IntercepteeFile;
    end
    methods(Access=public)
        function this=TestBenchData(aEntryPointFile)
            this.EntryPointFile=aEntryPointFile;
            this.EntryPointCalled=false;
            this.EntryPointTypes={};
            this.InterceptorFile='';
            this.IntercepteeFile='';
            this.NumberOfOutputs=int32(0);
            this.ActualEntryPointToCall='';
            this.LogFcnName='';
            this.InputLogIndices=logical([]);
            this.OutputLogIndices=logical([]);
            this.OutputParamCount=-1;
        end
        function file=getEntryPointFile(this)
            file=this.EntryPointFile;
        end
        function setCalled(this,aEntryPointCalled)
            this.EntryPointCalled=aEntryPointCalled;
        end
        function called=getCalled(this)
            called=this.EntryPointCalled;
        end
        function setTypes(this,aEntryPointTypes)
            this.EntryPointTypes=aEntryPointTypes;
        end
        function setType(this,aIndex,aType)
            this.EntryPointTypes{aIndex}=aType;
        end
        function types=getTypes(this)
            types=this.EntryPointTypes;
        end
        function type=getType(this,aIndex)
            if aIndex<=numel(this.EntryPointTypes)
                type=this.EntryPointTypes{aIndex};
            else
                type=[];
            end
        end
        function has=hasType(this,aIndex)
            if aIndex<=numel(this.EntryPointTypes)
                has=true;
            else
                has=false;
            end
        end
        function file=getInterceptorFile(this)
            file=this.InterceptorFile;
        end
        function setInterceptorFile(this,aInterceptorFile)
            this.InterceptorFile=aInterceptorFile;
        end
        function name=getIntercepteeFunctionName(this)
            [~,name,~]=fileparts(this.IntercepteeFile);
        end

        function file=getIntercepteeFile(this)
            file=this.IntercepteeFile;
        end
        function setIntercepteeFile(this,aIntercepteeFile)
            this.IntercepteeFile=aIntercepteeFile;
        end
    end
end
