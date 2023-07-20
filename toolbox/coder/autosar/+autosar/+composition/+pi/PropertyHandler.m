classdef PropertyHandler<handle





    methods(Static)

        function setPropertyValue(srcH,prop,newValue)
            import autosar.composition.pi.PropertyHandler;
            blockPath=getfullname(srcH);
            modelName=bdroot(blockPath);


            m3iParent=autosar.composition.Utils.findM3IObjectForCompositionElement(srcH);
            assert(m3iParent.isvalid(),'could not find m3iObj for: %s',blockPath);


            m3iModel=autosar.api.Utils.m3iModel(modelName);
            trans=M3I.Transaction(m3iModel);

            switch(prop)
            case 'ComponentKind'
                m3iCompProto=m3iParent;
                m3iComp=m3iCompProto.Type;
                m3iComp.Kind=Simulink.metamodel.arplatform.component.AtomicComponentKind.(newValue);
                autosar.composition.studio.CompBlockUtils.refreshBlockIcon(srcH);
            case 'ComponentName'
                if isa(m3iParent,'Simulink.metamodel.arplatform.composition.CompositionComponent')

                    autosar.api.Utils.checkQualifiedName(modelName,newValue,'shortname');

                    m3iComp=m3iParent;


                    oldCompQName=autosar.api.Utils.getQualifiedName(m3iComp);
                    newCompQName=[autosar.api.Utils.getQualifiedName(m3iComp.containerM3I),'/',newValue];
                    if~strcmp(oldCompQName,newCompQName)



                        [compAlreadyExists,m3iExistingComp]=...
                        autosar.composition.Utils.isCompTypeInArchModel(modelName,newValue);
                        if compAlreadyExists
                            DAStudio.error('RTW:autosar:ComponentExistsError',...
                            newValue,autosar.api.Utils.getQualifiedName(m3iExistingComp));
                        end

                        arProps=autosar.api.getAUTOSARProperties(modelName);
                        arProps.set('XmlOptions','ComponentQualifiedName',newCompQName);



                        h=DAStudio.EventDispatcher;
                        h.broadcastEvent('PropertyChangedEvent',srcH);
                    end
                else
                    assert(isa(m3iParent,'Simulink.metamodel.arplatform.composition.ComponentPrototype'));


                end
            otherwise
                assert(false,'unexpected prop name: %s',prop);
            end


            assert(m3iModel.unparented.isEmpty(),'unparented m3i objects after setPropertyValue');
            trans.commit();
        end


        function value=getPropertyValue(blkH,prop)
            value=[];


            m3iParent=autosar.composition.Utils.findM3IObjectForCompositionElement(blkH);
            if~m3iParent.isvalid()

                return
            end

            switch(prop)
            case 'ComponentKind'
                if isa(m3iParent,'Simulink.metamodel.arplatform.composition.ComponentPrototype')&&...
                    autosar.composition.Utils.isComponentBlock(blkH)
                    m3iComp=m3iParent.Type;
                    if m3iComp.isvalid()
                        if m3iComp.has('Kind')
                            value=m3iComp.Kind.toString();
                        else
                            value='AdaptiveApplication';
                        end
                    end
                else
                    value='Composition';
                end
            case 'ComponentName'
                if isa(m3iParent,'Simulink.metamodel.arplatform.composition.ComponentPrototype')
                    m3iComp=m3iParent.Type;
                else
                    assert(isa(m3iParent,'Simulink.metamodel.arplatform.component.Component'));
                    m3iComp=m3iParent;
                end
                if m3iComp.isvalid()
                    value=m3iComp.Name;
                end
            otherwise
                assert(false,'unexpected prop name: %s',prop);
            end
        end
    end
end



