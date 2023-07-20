classdef TargetInstruction<plccore.ladder.LadderInstruction




    properties(Access=protected)
BlockPath
NumInput
NumOutput
InputTypeList
OutputTypeList
EmitterFcn
InstrTypeStruct
InstrInfo
    end

    methods
        function obj=TargetInstruction(name,block_path,num_input,num_output,input_type_list,output_type_list,emitter_fcn,...
            input_scope,output_scope,local_scope,instrTypeStruct,instr_info)
            obj@plccore.ladder.LadderInstruction(name,'Target Instruction',input_scope,output_scope,local_scope);
            obj.Kind='TargetInstruction';
            obj.BlockPath=block_path;
            obj.NumInput=num_input;
            obj.NumOutput=num_output;
            obj.InputTypeList=input_type_list;
            obj.OutputTypeList=output_type_list;
            obj.EmitterFcn=emitter_fcn;
            obj.InstrTypeStruct=instrTypeStruct;
            obj.InstrInfo=instr_info;
        end

        function ret=toString(obj)
            ret=sprintf('%s\n',obj.name);
            if obj.NumInput
                ret=sprintf('%sInput: %d\n',ret,obj.NumInput);
            end
            for i=1:length(obj.InputTypeList)
                ret=sprintf('%s%d: %s\n',ret,i-1,obj.toStringTypes(obj.InputTypeList{i}));
            end
            if obj.NumOutput
                ret=sprintf('%sOutput: %d\n',ret,obj.NumOutput);
            end
            for i=1:length(obj.OutputTypeList)
                ret=sprintf('%s%d: %s\n',ret,i-1,obj.toStringTypes(obj.OutputTypeList{i}));
            end
        end

        function out=getNumInput(obj)
            out=obj.NumInput;
        end

        function out=getInputTypeList(obj)
            out=obj.InputTypeList;
        end


        function out=getNumOutput(obj)
            out=obj.NumOutput;
        end

        function out=getOutputTypeList(obj)
            out=obj.OutputTypeList;
        end

        function out=getInstrTypeStruct(obj)
            out=obj.InstrTypeStruct;
        end

        function ret=blockPath(obj)
            ret=obj.BlockPath;
        end

        function ret=emitterFcn(obj)
            ret=obj.EmitterFcn;
        end

        function ret=instrInfo(obj)
            ret=obj.InstrInfo;
        end
    end

    methods(Access=protected)
        function ret=toStringTypes(obj,type_list)%#ok<INUSL>
            ret='';
            sz=length(type_list);
            for i=1:sz
                ret=sprintf('%s%s',ret,type_list{i}.toString);
                if i~=sz
                    ret=sprintf('%s | ',ret);
                end
            end
        end
    end
end


