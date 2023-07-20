classdef BlockType






    enumeration
Invalid
GenericBlock
LUT
Math
SubSystem
BlockDiagram
    end

    methods(Static)
        function enum=getEnum(blockPath)

            try


                blockObject=get_param(blockPath,'Object');
                success=true;
            catch
                success=false;
                enum=FunctionApproximation.internal.BlockType.Invalid;
            end

            if success
                if isa(blockObject,'Simulink.Lookup_nD')
                    enum=FunctionApproximation.internal.BlockType.LUT;
                elseif isa(blockObject,'Simulink.Math')||isa(blockObject,'Simulink.Trigonometry')
                    enum=FunctionApproximation.internal.BlockType.Math;
                elseif isa(blockObject,'Simulink.SubSystem')
                    enum=FunctionApproximation.internal.BlockType.SubSystem;
                elseif isa(blockObject,'Simulink.BlockDiagram')
                    enum=FunctionApproximation.internal.BlockType.BlockDiagram;
                else
                    enum=FunctionApproximation.internal.BlockType.GenericBlock;
                end
            end
        end
    end
end
