



classdef Macros
    methods(Static)
        function registerMacro(layer,netFunc,override)
            import dnnfpga.macros.*

            if nargin<3
                override=false;
            end
            if~ischar(layer)
                layer=class(layer);
            end
            exists=false;
            try
                ignore=Macros.getMacro(layer);
                exists=true;
            catch
            end
            if~override&&exists
                msg=message('dnnfpga:dnnfpgacompiler:MacroAttemptOverride',...
                layer);
                warning(msg);
                exists=false;
            end
            if~exists||override
                Macros.setMacro(layer,netFunc);
            end
        end
        function n=getMacro(layer)
            import dnnfpga.macros.*
            n=Macros.getOrSetMacro(false,layer);
        end
        function n=setMacro(layer,netFunc)
            import dnnfpga.macros.*
            n=Macros.getOrSetMacro(false,layer,netFunc);
        end
        function n=getOrSetMacro(clearMap,layer,netFunc)
            persistent macroMap;
            if isempty(macroMap)||clearMap
                macroMap=containers.Map('KeyType','char','ValueType','Any');
            end
            n={};
            if~clearMap
                if~ischar(layer)
                    layer=class(layer);
                end
                if nargin<3
                    if macroMap.isKey(layer)
                        n=macroMap(layer);
                    else
                        msg=message('dnnfpga:dnnfpgacompiler:MacroDoesNotExist',...
                        layer);
                        error(msg);
                    end
                else
                    macroMap(layer)=netFunc;
                end
            end
        end
        function v=isMacro(layer)
            import dnnfpga.macros.*
            v=true;
            try
                netFunc=Macros.getMacro(layer);
            catch
                v=false;
            end
        end
        function net=createNet(layer,dataTransNum)
            import dnnfpga.macros.*
            netFunc=Macros.getMacro(layer);
            net=netFunc(layer,dataTransNum);
        end
        function clear()
            import dnnfpga.macros.*
            Macros.getOrSetMacro(true);
        end

        function registerDefaultMacros()
            dnnfpga.macros.Macros.registerMacro('dnnfpga.macros.ACCUMLayer',@dnnfpga.macros.createACCUMLayerNet);
            dnnfpga.macros.Macros.registerMacro('nnet.cnn.layer.LSTMLayer',@dnnfpga.macros.createLSTMLayerNet);
        end
    end
end


