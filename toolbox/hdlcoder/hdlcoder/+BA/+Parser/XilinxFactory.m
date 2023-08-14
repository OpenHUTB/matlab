



classdef XilinxFactory<BA.Parser.Factory

    methods
        function cpir=makeCP_IR(this,fileName,analyzeUnconstrained)
            cpir=BA.Parser.XilinxCP_IR(fileName);
            cpir.parse(analyzeUnconstrained);
        end

    end
end