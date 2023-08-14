


classdef(Sealed)GuiUtils
    methods(Access=private)
        function this=GuiUtils()
        end
    end

    methods(Static,Hidden)
        function[inputReader,idpTable]=getInputDataReader(parentReader)
            inputReader=com.mathworks.toolbox.coder.plugin.inputtypes.IDPUtils.getInputsReader(parentReader);
            idpTable=com.mathworks.toolbox.coder.plugin.inputtypes.PartialTypePropertyTable.deserializeTypePropertyTable(parentReader);
        end

        function inputRootReader=getInputRootReader(configuration,file)
            assert(isa(configuration,'com.mathworks.project.impl.model.Configuration')&&isa(file,'java.io.File'));
            javaStorage=com.mathworks.toolbox.coder.plugin.inputtypes.IdpStorage.getInstance(configuration);
            inputRootReader=javaStorage.getInputsXml(file);
        end

        function globalsReader=getGlobalsReader(configuration)
            assert(isa(configuration,'com.mathworks.project.impl.model.Configuration'));
            globalsReader=com.mathworks.toolbox.coder.plugin.inputtypes.IdpStorage.getProjectGlobalsReader(configuration);
        end

        function setGlobalsXml(configuration,xml)
            validateattributes(configuration,{'com.mathworks.project.impl.model.Configuration'},{});
            validateattributes(xml,{'com.mathworks.project.api.XmlReader'},{});
            javaStorage=com.mathworks.toolbox.coder.plugin.inputtypes.IdpStorage.getInstance(configuration);
            javaStorage.setGlobalsXml(xml);
        end

        function setInputsXml(configuration,file,xml)
            validateattributes(configuration,{'com.mathworks.project.impl.model.Configuration'},{});
            validateattributes(file,{'java.io.File'},{});
            validateattributes(xml,{'char','java.lang.String'},{});
            javaStorage=com.mathworks.toolbox.coder.plugin.inputtypes.IdpStorage.getInstance(configuration);
            javaStorage.setInputsXml(file,xml);
        end

        function iced=isBlockLocked(blockArg)
            chartObj=coder.internal.mlfb.idForBlock(blockArg).getChart();
            iced=(isprop(chartObj,'Iced')&&chartObj.Iced)||...
            (isprop(chartObj,'Locked')&&chartObj.Locked);
        end

        function code=getFunctionBlockCode(blockArg)
            chartObj=coder.internal.mlfb.idForBlock(blockArg).getChart();

            if~isempty(chartObj)
                code=chartObj.Script;
            else
                code='';
            end
        end

        function setBlockScript(blockArg,code)
            chartObj=coder.internal.mlfb.idForBlock(blockArg).getChart();
            if chartObj.Iced
                return;
            end

            if isa(code,'java.lang.String')
                code=char(code);
            end

            if~strcmp(chartObj.Script,code)
                chartObj.Script=code;
            end
        end
    end
end

