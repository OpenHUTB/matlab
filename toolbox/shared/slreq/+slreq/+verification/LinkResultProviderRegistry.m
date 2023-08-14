classdef LinkResultProviderRegistry<handle





    properties(Access=private)
        registry;
    end

    methods(Static)
        function singleObj=getInstance()
            mlock;
            persistent singleton;
            if isempty(singleton)||~isvalid(singleton)
                singleton=slreq.verification.LinkResultProviderRegistry();
            end
            singleObj=singleton;
        end

        function reset()
            instance=slreq.verification.LinkResultProviderRegistry.getInstance();
            if~isempty(instance)
                allKeys=instance.registry.keys();



                instance.registry.remove(allKeys);


                instance.init();
            end
        end
    end

    methods(Access=private)
        function this=LinkResultProviderRegistry()
            this.registry=containers.Map('KeyType','char','ValueType','any');
            this.init();
        end

        function init(this)

            this.register(slreq.verification.TestManagerResultProvider());
            this.register(slreq.verification.SldvResultProvider());
            this.register(slreq.verification.TestManagerMUnitResultProvider());
            this.register(slreq.verification.MATLABTestResultProvider());
            this.register(slreq.verification.TestStepResultProvider());
        end
    end

    methods
        function register(this,resultProvider)
            this.registry(resultProvider.getIdentifier())=resultProvider;
        end

        function unregister(this,resultProvider)
            key=resultProvider.getIdentifier();
            if this.registry.isKey(key)
                this.registry.remove(key);
            end
        end

        function obj=getResultProvider(this,link)
            obj=[];

            identifier='';
            if isa(link,'slreq.data.Link')
                identifier=link.type;
            end
            if this.registry.isKey(identifier)
                obj=this.registry(identifier);
            else
                if isa(link,'slreq.data.Link')

                    linkSource=link.source;
                elseif isa(link,'slreq.data.SourceItem')
                    linkSource=link;
                else
                    return;
                end
                switch linkSource.domain
                case 'linktype_rmi_testmgr'
                    obj=this.registry('Simulink Test Manager');
                case 'linktype_rmi_matlab'
                    [isMunit,isSTMMunit]=rmiml.RmiMUnitData.isMUnitFile(linkSource.artifactUri);
                    if isSTMMunit
                        obj=this.registry('Simulink Test Manager MATLAB Unit');
                    elseif reqmgt('rmiFeature','MunitSupport')&&isMunit
                        obj=this.registry('MATLAB Test');
                    end
                case 'linktype_rmi_simulink'



                    [~,artifact,~]=fileparts(linkSource.artifactUri);
                    if dig.isProductInstalled('Simulink')&&bdIsLoaded(artifact)
                        isSLDVVerifBlock=false;
                        if linkSource.isTextRange
                            sourceId=linkSource.modelObject.textItem.id;
                        else
                            sourceId=linkSource.id;
                        end
                        ssid=[artifact,sourceId];

                        if any(ssid=='.')
                            ssid=strtok(ssid,'.');
                        end
                        try


                            maskType=get_param(ssid,'MaskType');
                            if any(strcmp(slreq.data.Link.verification_mask_types,maskType))
                                isSLDVVerifBlock=true;
                            end

                            blockType=get_param(ssid,'BlockType');
                            if strcmp(blockType,'Assertion')
                                isSLDVVerifBlock=true;
                            end
                        catch ME %#ok<NASGU>
                        end

                        if isSLDVVerifBlock
                            obj=this.registry('Simulink Design Verifier');
                        end

                        if reqmgt('rmiFeature','TestSeqVerif')&&slreq.adapters.SLAdapter.isVerificationStep(artifact,sourceId)
                            obj=this.registry('Simulink Test Sequence Step');
                        end
                    end
                end
                if reqmgt('rmiFeature','ExtVerif')
                    if isempty(obj)&&isa(link,'slreq.data.Link')


                        [isExternal,destinationDomain]=link.isExternalVerificationLink();
                        if isExternal


                            if this.registry.isKey(destinationDomain)
                                obj=this.registry(destinationDomain);
                            else



                                obj=slreq.verification.ExternalResultProvider(destinationDomain);


                                this.register(obj);
                            end
                        end
                    end
                end
            end
        end

        function resultProvider=getResultProviderById(this,identifier)
            resultProvider=[];
            if this.registry.isKey(identifier)
                resultProvider=this.registry(identifier);
            end
        end

        function resultProviders=getAllResultProviders(this)
            resultProviders=this.registry.values();
        end
    end

end


