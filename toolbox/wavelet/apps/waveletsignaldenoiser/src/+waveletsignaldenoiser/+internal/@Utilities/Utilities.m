

classdef Utilities<handle


    methods(Static,Hidden)

        function filtNumbers=getFilterNumbers(waveletName)
            filtNumbers=cellstr(wavemngr("tabnums",waveletName));
            filtNumbers(strcmpi(filtNumbers,"**"))=[];
            filtNumbers=filtNumbers(:);
        end

        function waveletNames=getWaveletNames()
            waveletNames=["sym";"db";"fk";"bior";"coif"];
        end

        function waveletNames=getDenoisingMethods(isBlockJSNotRequired)
            waveletNames=["Bayes";"BlockJS";"FDR";"Minimax";"SURE";"Universal Threshold"];
            if isBlockJSNotRequired

                waveletNames=setdiff(waveletNames,"BlockJS",'stable');
            end
        end

        function rules=getThresholdRules(denoisingMethod)
            switch denoisingMethod
            case "Bayes"
                rules=["Median";"Mean";"Soft";"Hard"];
            case "BlockJS"
                rules="James-Stein";
            case "FDR"
                rules="Hard";
            case{"Minimax","SURE","Universal Threshold"}
                rules=["Soft";"Hard"];
            end
        end

        function flag=checkForVariableNameInWorkspace(signalName)

            S=evalin('base',"whos('"+signalName+"')");

            flag=~isempty(S);
        end
    end
end
