classdef AccessorFactory<handle




    properties(Constant)
        ACCESSOR_PACKAGE='matlab.plottools.service.accessor';
    end

    properties(Access='private')
        AccessorMap;
    end

    methods(Static,Access='public')
        function obj=getInstance()
            persistent factoryInstance;
            mlock;
            if isempty(factoryInstance)
                factoryInstance=matlab.plottools.service.AccessorFactory;
            end
            obj=factoryInstance;
        end
    end

    methods(Access='private')
        function obj=AccessorFactory()
        end

        function createAccessorMapping(obj)
            accessorMetaInfo=meta.package.fromName(obj.ACCESSOR_PACKAGE);
            accessorClasses=accessorMetaInfo.ClassList;

            keyset=cell(1,length(accessorClasses));
            valueset=cell(1,length(accessorClasses));


            index=1;



            for i=1:numel(accessorClasses)
                metaInfo=accessorClasses(i);

                if~metaInfo.Abstract
                    pkgName=split(metaInfo.Name,'.');


                    name=pkgName{end};
                    accessor=matlab.plottools.service.accessor.(name);





                    ids=accessor.getIdentifier();



                    if iscell(ids)
                        for key=1:numel(ids)
                            keyset{index}=ids{key};
                            valueset{index}=@()matlab.plottools.service.accessor.(name);

                            index=index+1;
                        end
                    else
                        keyset{index}=ids;
                        valueset{index}=@()matlab.plottools.service.accessor.(name);

                        index=index+1;
                    end
                end
            end

            obj.AccessorMap=containers.Map(keyset',...
            valueset');
        end

        function accessor=getAccessor(this,key)
            accessor=[];

            keyList=string(keys(this.AccessorMap));

            if any(key==keyList)
                mapEntry=this.AccessorMap(key);


                accessor=mapEntry();
            end
        end
    end

    methods(Access='public')
        function rebuildMap(obj)
            delete(obj.AccessorMap);

            obj.createAccessorMapping();
        end

        function accessor=getAccessorForObject(this,key,refObj)
            accessor=this.getAccessor(key);
            if~isempty(accessor)
                accessor.ReferenceObject=accessor.applyReferenceObject(refObj);
            end
        end
    end
end

