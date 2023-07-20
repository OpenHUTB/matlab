classdef InstanceRefDeleter<autosar.mm.util.InstanceRefVisitor






    properties(SetAccess=private,GetAccess=private)
        BadRefMap=[];
        EventInstanceRefs=[];
    end

    methods(Access=public)




        function self=InstanceRefDeleter(varargin)


            self=self@autosar.mm.util.InstanceRefVisitor(varargin{:});
        end



        function badRefMap=collectBadInstanceRef(self)



            self.m3iModel.beginTransaction();


            hasError=false;
            savedME=[];

            try

                self.BadRefMap=autosar.mm.util.Map(...
                'KeyType','char',...
                'HashFcn',@autosar.mm.util.InstanceRefHelper.getOrSetId);
                self.EventInstanceRefs=autosar.mm.util.Set(...
                'KeyType','char',...
                'HashFcn',@autosar.mm.util.InstanceRefHelper.getOrSetId);





                if~isempty(self.m3iComponent.Behavior)&&self.m3iComponent.Behavior.isvalid()
                    mEvents=self.m3iComponent.Behavior.Events;
                    for ii=1:mEvents.size()
                        mEvent=mEvents.at(ii);
                        if isa(mEvent,'Simulink.metamodel.arplatform.behavior.DataReceiveErrorEvent')||...
                            isa(mEvent,'Simulink.metamodel.arplatform.behavior.DataReceivedEvent')
                            self.EventInstanceRefs.set(mEvent.instanceRef);
                        end
                    end
                end



                self.applySeq('iVisit',self.m3iComponent.instanceMapping.instance);

                if~isempty(self.m3iComponent.Behavior)&&self.m3iComponent.Behavior.isvalid()
                    self.apply('iVisit',self.m3iComponent.Behavior);
                end

            catch Me
                savedME=Me;
                hasError=true;
            end

            if hasError


                self.m3iModel.cancelTransaction();
                rethrow(savedME);
            else


                self.m3iModel.commitTransaction();
                badRefMap=self.BadRefMap;
            end
        end



        function outInfo=deleteBadInstanceRef(self)



            self.m3iModel.beginTransaction();


            hasError=false;
            savedME=[];

            try


                if isempty(self.m3iComponent.instanceMapping.slURL)

                end


                keys=self.BadRefMap.getKeys();
                outInfo=cell(numel(keys),1);
                for ii=1:numel(keys)
                    infoCell=self.BadRefMap(keys{ii});
                    m3iObj=infoCell{1};
                    infoStruct=infoCell{2};
                    if m3iObj.isvalid()
                        self.BadRefMap.remove(keys{ii});
                        if isfield(infoStruct,'dataPortRef')


                            infoStruct.dataPortRef.ErrorStatus=...
                            feval(sprintf('%s.empty',infoStruct.class));
                        end


                        m3iObj.destroy();
                        m3iObj.delete();
                        outInfo{ii}=infoStruct;
                    end
                end


                outInfo(cellfun(@isempty,outInfo))=[];

            catch Me

                savedME=Me;
                hasError=true;
            end

            if hasError


                self.m3iModel.cancelTransaction();
                rethrow(savedME);
            else


                self.m3iModel.commitTransaction();
            end
        end



        function outInfo=delete(self)
            self.collectBadInstanceRef();
            outInfo=self.deleteBadInstanceRef();
        end

    end

    methods(Access=protected)


        function ret=acceptDataPortInstanceRef(self,m3iRef)
            ret=[];
            if~m3iRef.Port.isvalid()||...
                ~m3iRef.DataElements.isvalid()||...
                (isa(m3iRef,'Simulink.metamodel.arplatform.instance.FlowDataPortInstanceRef')&&...
                isempty(self.EventInstanceRefs.get(m3iRef)))
                infoStruct=struct(...
                'name',autosar.mm.Model.getQualifiedName(m3iRef),...
                'class',class(m3iRef),...
                'isPortValid',m3iRef.Port.isvalid(),...
                'isDataValid',m3iRef.DataElements.isvalid());
                self.BadRefMap.set(m3iRef,[{m3iRef},{infoStruct}]);
                return
            end

            if isa(m3iRef,'Simulink.metamodel.arplatform.instance.FlowDataPortInstanceRef')&&...
                ~isempty(m3iRef.ErrorStatus)&&...
                m3iRef.ErrorStatus.isvalid()&&...
                ~m3iRef.ErrorStatus.DataElements.isvalid()

                infoStruct=struct(...
                'name',autosar.mm.Model.getQualifiedName(m3iRef),...
                'class',class(m3iRef),...
                'dataPortRef',m3iRef,...
                'isErrorStatusValid',m3iRef.ErrorStatus.DataElements.isvalid());
                self.BadRefMap.set(m3iRef.ErrorStatus,{m3iRef.ErrorStatus,infoStruct});
                return
            end
        end



        function ret=acceptDataCompInstanceRef(self,m3iRef)
            ret=[];
            if~m3iRef.DataElements.isvalid()
                infoStruct=struct(...
                'name',autosar.mm.Model.getQualifiedName(m3iRef),...
                'class',class(m3iRef),...
                'isDataValid',m3iRef.DataElements.isvalid());
                self.BadRefMap.set(m3iRef,{m3iRef,infoStruct});
                return
            end
        end



        function ret=acceptOperationPortInstanceRef(self,m3iRef)
            ret=[];
            if~m3iRef.Port.isvalid()||~m3iRef.Operations.isvalid()
                infoStruct=struct(...
                'name',autosar.mm.Model.getQualifiedName(m3iRef),...
                'class',class(m3iRef),...
                'isPortValid',m3iRef.Port.isvalid(),...
                'isOperationValid',m3iRef.Operations.isvalid());
                self.BadRefMap.set(m3iRef,{m3iRef,infoStruct});
                return
            end


            args=m3iRef.Arguments;
            for ii=1:args.size()
                argRef=args.at(ii);
                if argRef.isvalid()&&~argRef.Arguments.isvalid()
                    infoStruct=struct(...
                    'name',autosar.mm.Model.getQualifiedName(argRef),...
                    'class',class(argRef),...
                    'isOpArgumentValid',argRef.Arguments.isvalid(),...
                    'operationRef',m3iRef);
                    self.BadRefMap.set(argRef,{argRef,infoStruct});
                end
            end
        end



        function ret=acceptRunnableInstanceRef(self,m3iRef)
            ret=[];
            if~m3iRef.Runnables.isvalid()
                infoStruct=struct(...
                'name',autosar.mm.Model.getQualifiedName(m3iRef),...
                'class',class(m3iRef),...
                'isRunnableValid',m3iRef.Runnables.isvalid());
                self.BadRefMap.set(m3iRef,{m3iRef,infoStruct});
                return
            end
        end



        function ret=acceptModeDeclarationInstanceRef(self,m3iRef)
            ret=[];


            if~m3iRef.Port.isvalid()||...
                ~(m3iRef.groupElement.isvalid()||m3iRef.Mode.isvalid())
                infoStruct=struct(...
                'name',autosar.mm.Model.getQualifiedName(m3iRef),...
                'class',class(m3iRef),...
                'isPortValid',m3iRef.Port.isvalid(),...
                'isGroupValid',m3iRef.groupElement.isvalid(),...
                'isModeValid',m3iRef.Mode.isvalid());
                self.BadRefMap.set(m3iRef,{m3iRef,infoStruct});
                return
            end
        end



        function ret=acceptApplicationComponentBehavior(~,~)
            ret=[];
        end



        function ret=acceptRunnable(~,~)
            ret=[];
        end



        function ret=acceptDataAccess(~,~)
            ret=[];
        end



        function ret=acceptOperationBlockingAccess(self,m3iObj)
            ret=[];
            for ii=1:m3iObj.instanceRef.size()
                item=m3iObj.instanceRef.at(ii);
                if self.BadRefMap.isKey(item)
                    val=self.BadRefMap(item);
                    self.BadRefMap.set(item,[val,{m3iObj},{ii}]);
                end
            end
        end


    end

end


