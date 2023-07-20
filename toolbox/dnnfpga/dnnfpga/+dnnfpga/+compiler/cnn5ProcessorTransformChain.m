classdef cnn5ProcessorTransformChain<dnnfpga.compiler.cnn4ProcessorTransformChain



    properties(Access=protected)
        Verbose=1;
    end

    methods(Access=public,Hidden=true)
        function obj=cnn5ProcessorTransformChain(verbose)
            if nargin<1
                verbose=1;
            end

            obj@dnnfpga.compiler.cnn4ProcessorTransformChain();
            obj.Verbose=verbose;
        end
    end





    methods(Access=public)
        function output=doit(obj,hIR,processor,varargin)


            obj.insertSoftHardInterfaceComponents(hIR.sgraph);


            [dataType,status]=dnnfpga.compiler.processorKernelType(processor);

            if(status)
                obj.insertQuantizeComponents(hIR.sgraph)
                obj.copyInputOutputExponents(hIR.sgraph)
                BytesPerData=1;
                InputFrameNumberLimit=2;
            else
                BytesPerData=4;
            end



            hIR.sgraph.addDataFormat();


            hIR.createDDRSupport(processor,'BytesPerData',BytesPerData,varargin{:});

            output=hIR;
        end

        function insertSoftHardInterfaceComponents(~,sgraph,updateSGraph)
            import dnnfpga.dagCompile.*;

            if nargin<3
                updateSGraph=true;
            end

            nn=sgraph.nets;
            countSoftToHard=uint8(0);
            countHardToSoft=uint8(0);
            for i=1:numel(nn)
                net=nn(i);

                name='SWToFPGA';
                if countSoftToHard~=0
                    name=strcat(name,sprintf("_%u",countSoftToHard));
                end
                inserted=sgraph.insertForNet(net,LayerKind.Soft,LayerKind.Hard,LayerKind.SoftToHard,name);
                if inserted
                    countSoftToHard=countSoftToHard+uint8(1);
                end

                name='FPGAToSW';
                if countHardToSoft~=0
                    name=strcat(name,sprintf("_%u",countHardToSoft));
                end
                inserted=sgraph.insertForNet(net,LayerKind.Hard,LayerKind.Soft,LayerKind.HardToSoft,name);
                if inserted
                    countHardToSoft=countHardToSoft+uint8(1);
                end

                if updateSGraph
                    sgraph.updateSGraph();
                end
            end
        end

        function insertQuantizeComponents(~,sgraph,updateSGraph)
            import dnnfpga.dagCompile.*;

            if nargin<3
                updateSGraph=true;
            end

            nn=sgraph.nets;
            countQuantIn=uint8(0);
            countQuantOut=uint8(0);
            for i=1:numel(nn)
                net=nn(i);

                name='QuantIn';
                if countQuantIn~=0
                    name=strcat(name,sprintf("_%u",countQuantIn));
                end
                [inserted,c]=sgraph.insertForNet(net,LayerKind.Soft,LayerKind.SoftToHard,LayerKind.QuantIn,name);
                if inserted
                    countQuantIn=countQuantIn+uint8(1);
                    if~c.hasKind(LayerKind.Soft)
                        c.layerKinds=cat(1,c.layerKinds,LayerKind.Soft);
                    end
                end

                name='QuantOut';
                if countQuantOut~=0
                    name=strcat(name,sprintf("_%u",countQuantOut));
                end
                [inserted,c]=sgraph.insertForNet(net,LayerKind.HardToSoft,LayerKind.Soft,LayerKind.QuantOut,name);
                if inserted
                    countQuantOut=countQuantOut+uint8(1);
                    if~c.hasKind(LayerKind.Soft)
                        c.layerKinds=cat(1,c.layerKinds,LayerKind.Soft);
                    end
                end
                if updateSGraph
                    sgraph.updateSGraph();
                end
            end
        end

        function copyInputOutputExponents(~,sgraph)
            import dnnfpga.dagCompile.*;
            sortedComponents=sgraph.sortedComponents;
            for i=1:numel(sortedComponents)
                if(strcmp(sortedComponents(i).name,'QuantIn'))
                    sortedComponents(i).inputExp=sortedComponents(i-1).inputExp;
                elseif(strcmp(sortedComponents(i).name,'QuantOut'))
                    sortedComponents(i).outputExp=sortedComponents(i-2).outputExp;
                end
            end
        end

    end
end



