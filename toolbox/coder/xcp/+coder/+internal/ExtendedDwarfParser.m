classdef ExtendedDwarfParser<handle








    properties(Access=private)
        EmulateWordTargetAsByteTarget=false;
        Parser;
    end

    methods
        function obj=ExtendedDwarfParser(symbolsFileName)
            obj.Parser=coder.internal.DwarfParser(symbolsFileName);
            try
                obj.Parser.describeSymbol('xcpEmulateWordTargetAsByteTarget');
                obj.EmulateWordTargetAsByteTarget=true;
            catch
                obj.EmulateWordTargetAsByteTarget=false;
            end
        end

        function out=describeSymbol(obj,name)
            out=obj.Parser.describeSymbol(name);
            if obj.EmulateWordTargetAsByteTarget
                out.address=out.address*2;
                out.size=out.size*2;
            end
        end

        function out=getAllGlobalSymbols(obj)
            out=obj.Parser.getAllGlobalSymbols;
        end
    end

    methods(Hidden)
        function emulationEnabled=isByteAddressableEmulationEnabled(obj)
            emulationEnabled=obj.EmulateWordTargetAsByteTarget;
        end
    end
end
