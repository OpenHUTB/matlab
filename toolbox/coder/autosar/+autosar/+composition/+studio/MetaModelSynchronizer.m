classdef MetaModelSynchronizer<handle




    methods(Static)


        function syncM3IComp(m3iSrcComp,m3iDstComp,varargin)
            assert(m3iSrcComp.isvalid(),'invalid m3iSrcComp');
            assert(m3iDstComp.isvalid(),'invalid m3iDstComp');

            p=inputParser;
            p.addParameter('SyncCompName',false,@(x)(islogical(x)));
            p.parse(varargin{:});


            if p.Results.SyncCompName

                srcCompQName=autosar.api.Utils.getQualifiedName(m3iSrcComp);
                compPkg=autosar.utils.splitQualifiedName(srcCompQName);
                m3iDstCompPkg=autosar.mm.Model.getOrAddARPackage(m3iDstComp.rootModel,...
                compPkg);


                m3iDstComp.Name=m3iSrcComp.Name;
                m3iDstCompPkg.packagedElement.push_back(m3iDstComp);
            end
            if m3iDstComp.has('Kind')
                m3iDstComp.Kind=m3iSrcComp.Kind;
            end

            if isa(m3iSrcComp,'Simulink.metamodel.arplatform.composition.CompositionComponent')
                autosar.composition.studio.MetaModelSynchronizer.syncM3IComponentPrototypes(...
                m3iSrcComp,m3iDstComp);
            end
        end
    end

    methods(Static,Access=private)


        function syncM3IComponentPrototypes(m3iSrcComp,m3iDstComp)
            compProtoCls='Simulink.metamodel.arplatform.composition.ComponentPrototype';
            for i=1:m3iSrcComp.Components.size()
                m3iSrcCompPrototype=m3iSrcComp.Components.at(i);
                m3iDstCompProto=Simulink.metamodel.arplatform.ModelFinder.findOrCreateNamedItemInSequence(...
                m3iDstComp,m3iDstComp.Components,m3iSrcCompPrototype.Name,compProtoCls);
                if m3iSrcCompPrototype.Type.isvalid()&&...
                    (m3iDstCompProto.rootModel==m3iSrcCompPrototype.rootModel)
                    m3iDstCompProto.Type=m3iSrcCompPrototype.Type;
                end
            end
        end
    end
end


