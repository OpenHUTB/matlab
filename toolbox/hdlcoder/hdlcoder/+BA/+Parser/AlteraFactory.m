
classdef AlteraFactory<BA.Parser.Factory

    methods
        function cpir=makeCP_IR(this,fileName)
            cpir=BA.Parser.AlteraCP_IR(fileName);
            cpir.parse;
        end

    end
end