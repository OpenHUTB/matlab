classdef ZCArtifactHandler<alm.internal.AbstractArtifactHandler


    methods

        function h=ZCArtifactHandler(metaData,container,g)
            h=h@alm.internal.AbstractArtifactHandler(metaData,container,g);
        end

        function nextArt=createArtAndRel(object,parentArt,h,type)

            g=h.Graph();
            nextArt=g.createArtifact(string(object.SID),parentArt);
            nextArt.Label=object.Name;
            nextArt.Type=type;
        end

        function analyze(h)

            import alm.internal.zc.ZCConstants;

            absolutPath=h.StorageHandler.getAbsoluteAddress(h.MainArtifact.Address);
            g=h.Graph;
            [~,modelName,~]=fileparts(absolutPath);


            a_bd=g.createArtifact(...
            string(modelName),...
            h.MainArtifact,...
            true,...
            alm.PhysicalArtifactType.ELEMENT);
            a_bd.Label=modelName;
            a_bd.Type=ZCConstants.SL_BLOCK_DIAGRAM;

            resources=h.Loader.load(a_bd,h.Graph);%#ok<NASGU>

            h.startNestedAnalysis(a_bd);

            a_bd.Type=ZCConstants.ZC_BLOCK_DIAGRAM;

            archSysBlockPaths=string(find_system(modelName,...
            'MatchFilter',@Simulink.match.allVariants,...
            'BlockType','SubSystem'));
            archTypes=containers.Map(...
            {'AUTOSARArchitecture','Architecture','SoftwareArchitecture'},...
            {[],[],[]});

            nArchSys=numel(archSysBlockPaths);

            for i=1:nArchSys
                blockPath=archSysBlockPaths(i);

                if isKey(archTypes,get_param(blockPath,'SimulinkSubDomain'))

                    compactSID=erase(Simulink.ID.getSID(blockPath),modelName+":");
                    a=h.Graph.getArtifactByAddress(...
                    h.Storage.CustomId,h.MainArtifact.Address,[string(a_bd.Address),string(compactSID)]);

                    if~isempty(a)
                        assert(a.Type==ZCConstants.SL_SUBSYSTEM,"Only 'sl_subsytem' elements "+...
                        "are expected to become 'zc_component' elements, but type is '"+...
                        +a.Type+"'");

                        a.Type=ZCConstants.ZC_COMPONENT;
                    end
                end

            end
        end



        function openFile(h)
            absolutPath=h.StorageHandler.getAbsoluteAddress(h.MainArtifact.Address);

            open_system(absolutPath);
        end



        function openElement(h)

            import alm.internal.zc.ZCConstants;

            switch h.MainArtifact.Type
            case ZCConstants.ZC_BLOCK_DIAGRAM
                open_system(h.MainArtifact.Address);
            case ZCConstants.ZC_COMPONENT
                [~,modelname,~]=fileparts(h.SelfContainedArtifact.Address);
                open_system(h.SelfContainedArtifact.Address);

                selectedBlocks=find_system(modelname,...
                'MatchFilter',@Simulink.match.allVariants,...
                'Selected','on');
                cellfun(@(x)set_param(x,'Selected','off'),selectedBlocks);

                set_param(modelname+":"+h.MainArtifact.Address,'Selected','on');
            otherwise

            end
        end
    end
end
