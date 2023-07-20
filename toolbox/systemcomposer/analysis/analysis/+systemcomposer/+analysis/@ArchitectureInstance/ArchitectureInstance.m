classdef ArchitectureInstance<systemcomposer.analysis.NodeInstance


    properties(SetAccess=private,Dependent)
Specification
        IsStrict;
        NormalizeUnits;
    end

    properties(Dependent)
        AnalysisFunction;
        AnalysisDirection;
        AnalysisArguments;
        ImmediateUpdate;
    end

    methods(Access='protected')
        function qualifiedName=getQualifiedName(this)
            qualifiedName=this.Name;
        end
    end

    methods(Hidden,Static)

        function instance=instantiate(modelHandle,architecture,properties,name,varargin)
            import systemcomposer.analysis.ArchitectureInstance;

            narginchk(4,nargin);

            if architecture.p_Model.containsReferenceArchitectureCycle
                error('systemcomposer:API:CantInstantiateCycle',...
                message('SystemArchitecture:Analysis:CantInstantiateCycle',architecture.getName).getString);
            end

            fnHandle=[];
            iterOrd=systemcomposer.IteratorDirection.PreOrder;
            arguments='';
            isStrict=false;
            normalizeUnits=false;
            a=1;
            while a<=length(varargin)

                argName=varargin{a};
                argValue=varargin{a+1};

                switch argName
                case 'Function'
                    fnHandle=argValue;
                case 'NormalizeUnits'
                    normalizeUnits=argValue;
                case 'Strict'
                    isStrict=argValue;
                case 'Arguments'
                    arguments=argValue;
                case 'Direction'
                    if ischar(argValue)
                        if strcmpi(argValue,"preorder")
                            iterOrd=systemcomposer.IteratorDirection.PreOrder;
                        elseif strcmpi(argValue,"postorder")
                            iterOrd=systemcomposer.IteratorDirection.PostOrder;
                        elseif strcmpi(argValue,"topdown")
                            iterOrd=systemcomposer.IteratorDirection.TopDown;
                        elseif strcmpi(argValue,"bottomup")
                            iterOrd=systemcomposer.IteratorDirection.BottomUp;
                        else
                            error('systemcomposer:API:IterateOptionInvalid',...
                            message('SystemArchitecture:API:IterateOptionInvalid').getString);
                        end
                    else
                        iterOrd=systemcomposer.IteratorDirection(argValue);
                    end
                otherwise
                    error('systemcomposer:analysis:invalidViewerParameter',message('SystemArchitecture:Analysis:InvalidInstanceViewerArgument',argName).getString);
                end
                a=a+2;
            end


            impl=systemcomposer.internal.analysis.AnalysisService.addInstanceModel(modelHandle,architecture,name);
            mfModel=mf.zero.getModel(impl);
            txn=mfModel.beginTransaction;
            impl.isStrict=isStrict;
            impl.normalizeUnits=normalizeUnits;

            if~isempty(fnHandle)
                impl.analysisFunctionName=func2str(fnHandle);
            end
            impl.direction=uint8(iterOrd);
            impl.arguments=arguments;

            impl.addPropertySets(properties);


            impl.populate();


            systemcomposer.internal.analysis.ModelValueSet.newModelValueSet(impl);
            txn.commit;


            instance=systemcomposer.analysis.ArchitectureInstance(impl);
        end
    end
    methods(Hidden)
        function inst=getInstance(this)


            inst=this.InstElementImpl.root;
        end


    end
    methods
        function save(this,fileName)
            s=mf.zero.io.XmlSerializer;
            str=s.serializeToString(this.getModel);
            save(fileName,'str');
        end

        function refresh(this,reset)
            import systemcomposer.*;
            if isempty(this.Specification)
                error('systemcomposer:analysis:cantUpdateWithoutArchitecture',...
                message('SystemArchitecture:Analysis:CantUpdateWithoutArchitecture').getString);
            else
                if nargin<2
                    reset=false;
                end
                it=internal.analysis.createInstanceModelIterator('order',systemcomposer.IteratorDirection.PostOrder);
                it.begin(this.getImpl);

                txn=this.getModel.beginTransaction;
                while~isempty(it.getElement())
                    spec=it.getElement().Specification;
                    mfElement=it.getElement().getInstance;
                    if~isempty(spec)
                        if reset||~mfElement.current
                            mfElement.update(reset);
                        end
                    else
                        mfElement.destroy();
                    end
                    it.next();
                end

                txn.commit;
            end
        end

        function promoteHierarchy(this,item,isStrict,normalizeUnits)
            import systemcomposer.*;
            it=internal.analysis.createInstanceModelIterator('order',systemcomposer.IteratorDirection.PreOrder);
            it.begin(item);

            while~isempty(it.getElement())
                mfWrapper=it.getElement();
                spec=mfWrapper.Specification;
                if~isempty(spec)
                    if~isStrict&&isa(mfWrapper,'systemcomposer.analysis.NodeInstance')


                        if isa(spec,'systemcomposer.arch.Architecture')
                            arch=spec;
                        else
                            arch=spec.Architecture;
                        end
                        if isempty(arch.Parent)


                            for usage=this.getImpl.p_PropertySets.toArray
                                profileName=usage.propertySet.prototype.profile.getName();
                                arch.applyProfile(profileName);
                            end
                        end
                    end
                    mfElement=mfWrapper.getInstance;
                    mfElement.promote(isStrict,normalizeUnits);
                end

                it.next();
            end
        end

        function update(this,itemUUID,propertyNameOrUpdate)
            import systemcomposer.*;
            if isempty(this.Specification)
                error('systemcomposer:analysis:cantPromoteWithoutArchitecture',...
                message('SystemArchitecture:Analysis:CantPromoteWithoutArchitecture').getString);
            else
                isStrict=this.getImpl.isStrict;
                normalizeUnits=this.getImpl.normalizeUnits;
                txn=this.getModel.beginTransaction;

                if(nargin<2||isempty(itemUUID))

                    this.promoteHierarchy(this.getImpl,isStrict,normalizeUnits);
                else


                    instance=this.getModel.findElement(itemUUID);

                    if~isempty(instance)
                        if(~isStrict)
                            impArch=instance.specification.getTopLevelArchitecture();
                            modelArch=systemcomposer.internal.getWrapperForImpl(impArch);
                            for usage=this.getImpl.p_PropertySets.toArray
                                profileName=usage.propertySet.prototype.profile.getName();
                                modelArch.applyProfile(profileName);
                            end
                        end
                        if(nargin<3||islogical(propertyNameOrUpdate))
                            if(nargin>2&&propertyNameOrUpdate)
                                this.promoteHierarchy(instance,isStrict,normalizeUnits);
                            else

                                instance.promote(isStrict,normalizeUnits);
                            end
                        else

                            instance.promote(isStrict,normalizeUnits,propertyNameOrUpdate);
                        end
                    end
                end

                txn.commit;
            end
        end

        iterate(this,iterType,iterFunc,varargin);
        instance=lookup(this,varargin);
    end

    methods

        function specification=get.Specification(this)
            specification=systemcomposer.arch.Architecture.empty;
            try
                if~isempty(this.InstElementImpl.specification)
                    specification=systemcomposer.internal.getWrapperForImpl(this.InstElementImpl.specification);
                end
            catch

            end
        end

        function handle=get.AnalysisFunction(this)
            name=this.InstElementImpl.analysisFunctionName;
            handle=[];
            if ischar(name)&&~strcmp(name,'')

                fcn=[name,'.m'];
                p=which(fcn);
                if~isempty(p)
                    handle=eval(['(@',name,')']);
                end
            end
        end

        function set.AnalysisFunction(this,name)
            if ischar(name)
                this.InstElementImpl.analysisFunctionName=name;
            elseif isa(name,'function_handle')
                this.InstElementImpl.analysisFunctionName=func2str(name);
            end
        end

        function direction=get.AnalysisDirection(this)
            direction=systemcomposer.IteratorDirection(this.InstElementImpl.direction);
        end

        function set.AnalysisDirection(this,direction)
            this.InstElementImpl.direction=uint8(direction);
        end

        function args=get.AnalysisArguments(this)
            args=this.InstElementImpl.arguments;
        end

        function set.AnalysisArguments(this,arguments)
            this.InstElementImpl.arguments=arguments;
        end

        function setting=get.ImmediateUpdate(this)
            setting=this.InstElementImpl.immediateUpdate;
        end

        function set.ImmediateUpdate(this,setting)
            this.InstElementImpl.immediateUpdate=setting;
        end

        function setting=get.IsStrict(this)
            setting=this.InstElementImpl.isStrict;
        end

        function setting=get.NormalizeUnits(this)
            setting=this.InstElementImpl.normalizeUnits;
        end
    end

end

