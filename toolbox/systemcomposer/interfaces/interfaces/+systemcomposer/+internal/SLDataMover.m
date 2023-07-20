classdef SLDataMover<handle





    properties(Access=private)
srcCatalog
dstCatalog
        providedCollisionResolution;
    end

    methods(Static)
        function success=MovePortInterfaces(srcCatalog,dstCatalog,interfaceCollisionResolution)


            if nargin<3
                interfaceCollisionResolution=systemcomposer.architecture.model.interface.CollisionResolution.UNSPECIFIED;
            end

            success=false;
            obj=systemcomposer.internal.SLDataMover(srcCatalog,dstCatalog,interfaceCollisionResolution);

            assert(~obj.isDstModelContext);
            if(obj.isSrcModelContext)
                [didComplete,nameCollisions,collisionOption]=obj.moveFromModelToSLDD();


                if didComplete
                    srcCatalog.moveContentsTo(obj.dstCatalog,true,collisionOption,nameCollisions);
                end

                success=didComplete;
            end
        end
    end

    methods
        function obj=SLDataMover(src,dst,collisionRes)
            obj.srcCatalog=src;
            obj.dstCatalog=dst;
            obj.providedCollisionResolution=collisionRes;
        end

        function tf=isSrcModelContext(obj)
            tf=obj.srcCatalog.getStorageContext==systemcomposer.architecture.model.interface.Context.MODEL;
        end

        function tf=isDstModelContext(obj)
            tf=obj.dstCatalog.getStorageContext==systemcomposer.architecture.model.interface.Context.MODEL;
        end

        function[didComplete,nameCollisions,collisionOption]=moveFromModelToSLDD(obj)
            didComplete=false;

            srcWS=get_param(obj.srcCatalog.getStorageSource,'ModelWorkspace');
            dstSLDD=Simulink.data.dictionary.open([obj.dstCatalog.getStorageSource,'.sldd']);
            dstDD=getSection(dstSLDD,'Design Data');

            dstVarNames={dstDD.find.Name};

            allSrcVars=srcWS.whos;
            allSrcVarNames={allSrcVars.name};


            collisionOption=systemcomposer.architecture.model.interface.CollisionResolution.KEEP_DST;
            nameCollisions=intersect(allSrcVarNames,dstVarNames);
            if~isempty(nameCollisions)

                if(obj.providedCollisionResolution==systemcomposer.architecture.model.interface.CollisionResolution.UNSPECIFIED)


                    collisionOption=systemcomposer.internal.queryInterfaceCollisionResolution(obj.srcCatalog,obj.dstCatalog);
                    if collisionOption==systemcomposer.architecture.model.interface.CollisionResolution.UNSPECIFIED

                        return;
                    end
                else

                    collisionOption=obj.providedCollisionResolution;
                end
            end

            for srcVar=allSrcVars'
                if strcmpi(srcVar.class,'Simulink.Bus')||strcmpi(srcVar.class,'Simulink.ValueType')||strcmpi(srcVar.class,'Simulink.ConnectionBus')||strcmpi(srcVar.class,'Simulink.ServiceBus')


                    if~(dstDD.exist(srcVar.name)&&collisionOption==systemcomposer.architecture.model.interface.CollisionResolution.KEEP_DST)


                        varToCopy=srcWS.getVariable(srcVar.name);
                        dstDD.assignin(srcVar.name,varToCopy);
                    end
                    srcWS.clear(srcVar.name);
                end
            end

            didComplete=true;
        end
    end
end

