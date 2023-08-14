classdef OutputCompBuilder<dltargets.internal.compbuilder.CodegenCompBuilder




    properties(Constant,Access=private)

        compKey='gpucoder.output_layer_comp';


        compKind='outputlayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.OutputCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.OutputCompBuilder.compKind;
        end

        function comp=convert(layer,converter,comp)
            assert(dltargets.internal.checkIfOutputLayer(layer));

            outputFileName=converter.getParameterFileNames(layer.Name);
            if~isempty(outputFileName)

                comp.setClassNamesFile(outputFileName);
            end
        end

        function saveFiles(layer,fileSaver)

            if isprop(layer,'Classes')&&~isempty(layer.Classes)

                classLabelsFileName=strcat(fileSaver.getFilePrefix,'labels');
                outputFileName=dltargets.internal.utils.LayerToCompUtils.getCompFileName(classLabelsFileName,...
                fileSaver.getParameterDirectory,fileSaver.getCodegenTarget);

                t=cell2table(cellstr(layer.Classes));
                writetable(t,outputFileName,'WriteVariableNames',0);

                fileSaver.setParameterFileNamesMap(layer.Name,outputFileName);

            elseif isprop(layer,'ResponseNames')&&~isempty(layer.ResponseNames)

                responseNamesFileName=strcat(fileSaver.getFilePrefix,'responseNames');
                outputFileName=dltargets.internal.utils.LayerToCompUtils.getCompFileName(responseNamesFileName,...
                fileSaver.getParameterDirectory,fileSaver.getCodegenTarget);

                t=cell2table(layer.ResponseNames);
                writetable(t,outputFileName,'WriteVariableNames',0);

                fileSaver.setParameterFileNamesMap(layer.Name,outputFileName);

            end
        end

        function aStruct=toStruct(layer)

            aStruct=struct('Class',class(layer),'Name',layer.Name);
            if isprop(layer,'Classes')&&~isempty(layer.Classes)
                aStruct.Classes=layer.Classes;
            elseif isprop(layer,'ResponseNames')&&~isempty(layer.ResponseNames)
                aStruct.ResponseNames=layer.ResponseNames;
            end

            if isa(layer,'nnet.cnn.layer.YOLOv2OutputLayer')
                aStruct.AnchorBoxes=layer.AnchorBoxes;
            end
        end
    end
end
