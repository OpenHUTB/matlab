classdef ModelUtils




    methods(Static)
        function[isMappedToHDL,hdlMapping]=isMapped(model)


            hdlMapping=hdlcoder.mapping.internal.ModelUtils.getActiveMapping(model);
            isMappedToHDL=~isempty(hdlMapping);
        end

        function hasHDLMapping=hasMapping(model)




            hdlMappings=hdlcoder.mapping.internal.ModelUtils.getAllMappings(model);
            hasHDLMapping=~isempty(hdlMappings);
        end

        function hdlMapping=getActiveMapping(model)



            mappingManager=get_param(model,'MappingManager');
            hdlMapping=mappingManager.getActiveMappingFor('HDLTarget');
        end

        function hdlMappings=getAllMappings(model)


            mappingManager=get_param(model,'MappingManager');
            hdlMappings=mappingManager.getMappingsFor('HDLTarget');
        end

        function hdlMapping=activateMapping(model)

            if~hdlcoder.mapping.internal.ModelUtils.isMapped(model)
                hdlMapping=hdlcoder.mapping.internal.ModelUtils.getAllMappings(model);
                assert(length(hdlMapping)==1,'Expected there to only be a single HDL model mapping.');

                mappingManager=get_param(model,'MappingManager');
                mappingManager.activateMapping(hdlMapping.Name);
            end
        end

        function deactivateMapping(model)

            if hdlcoder.mapping.internal.ModelUtils.isMapped(model)
                mappingManager=get_param(model,'MappingManager');
                mappingManager.deactivateMapping('HDLTarget');
            end
        end

        function hdlMapping=createOrActivateMapping(model)





            if hdlcoder.mapping.internal.ModelUtils.isMapped(model)

                hdlMapping=hdlcoder.mapping.internal.ModelUtils.getActiveMapping(model);
            elseif hdlcoder.mapping.internal.ModelUtils.hasMapping(model)

                hdlMapping=hdlcoder.mapping.internal.ModelUtils.activateMapping(model);
            else

                hdlMapping=hdlcoder.mapping.internal.ModelUtils.createEmptyMapping(model);

                mf0Model=mf.zero.Model;
                hdlMapping.IPCORE_MF0MODEL=mf0Model;

                modelName=get_param(model,'Name');
                ipcore=hdlcoder.mapping.internal.MF0Utils.createDefaultIPCore(mf0Model,modelName);
                hdlMapping.map(ipcore);
            end

            if isempty(hdlMapping.IPCORE_MF0MODEL)
                mf0Model=hdlcoder.mapping.internal.ModelUtils.readIPCorePartToMF0Model(model);
                hdlMapping.IPCORE_MF0MODEL=mf0Model;
                hdlMapping.loadFromDataModel;
            end

        end

        function mf0Model=readIPCorePartToMF0Model(model)

            mf0Model=mf.zero.Model.empty;

            loadOptions=Simulink.internal.BDLoadOptions(model);
            partName='/ipcore/ipcore.xml';
            if isempty(loadOptions.readerHandle)||~loadOptions.readerHandle.hasPart(partName)
                return;
            end

            xmlFileName=Simulink.slx.getUnpackedFileNameForPart(model,partName);
            if~exist(xmlFileName,'file')
                loadOptions.readerHandle.readPartToFile(partName,xmlFileName);
            end


            parser=mf.zero.io.XmlParser;
            parser.parseFile(xmlFileName);
            mf0Model=parser.Model;
        end

        function mf0Model=getMappedMF0Model(model)


            mf0Model=mf.zero.Model.empty;

            [isMappedToHDL,hdlMapping]=hdlcoder.mapping.internal.ModelUtils.isMapped(model);
            if isMappedToHDL
                mf0Model=hdlMapping.IPCORE_MF0MODEL;
            end
        end

        function ipcore=getMappedIPCore(model)

            ipcore=hdl.ip.component.IPCore.empty;

            [isMappedToHDL,hdlMapping]=hdlcoder.mapping.internal.ModelUtils.isMapped(model);
            if isMappedToHDL
                ipcore=hdlMapping.getIPCore;
            end
        end

        function mapping=getMappingForPort(hdlModelMapping,portPath)
            ioMappingArray=[hdlModelMapping.Inports,hdlModelMapping.Outports];
            mapping=ioMappingArray.findobj('Block',portPath);
        end























    end

    methods(Static,Access=private)
        function hdlMapping=createEmptyMapping(model)


            [isMappedToHDL,hdlMapping]=hdlcoder.mapping.internal.ModelUtils.isMapped(model);
            if~isMappedToHDL
                mmgr=get_param(model,'MappingManager');
                Simulink.HDLTarget.HDLModelMapping;
                mappingName=['HDLTarget_',model];
                mappingName=matlab.lang.makeValidName(mappingName);
                mmgr.createMapping(mappingName,'HDLTarget');
                mmgr.activateMapping(mappingName);
                hdlMapping=mmgr.getActiveMappingFor('HDLTarget');
            end
        end
    end
end


