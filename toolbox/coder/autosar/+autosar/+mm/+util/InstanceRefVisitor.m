classdef InstanceRefVisitor<m3i.Visitor





    properties(SetAccess=protected,GetAccess=protected)
        m3iModel;
        m3iComponent;
    end

    methods(Access=public)




        function self=InstanceRefVisitor(m3iComp)
            self=self@m3i.Visitor();
            if isempty(m3iComp)||...
                ~(isa(m3iComp,'Simulink.metamodel.arplatform.component.AtomicComponent')||...
                isa(m3iComp,'Simulink.metamodel.arplatform.component.AdaptiveApplication'))||...
                ~m3iComp.isvalid()
                assert(false,DAStudio.message('RTW:autosar:mmInvalidArgComponent',1));
            end

            self.m3iModel=m3iComp.rootModel;
            self.m3iComponent=m3iComp.asDeviant(self.m3iModel.asImmutable.getRootDeviant());




            self.registerVisitor('iVisit','iVisit');
            self.bind('Simulink.metamodel.arplatform.instance.OperationPortInstanceRef',@walkOperationPortInstanceRef,'iVisit');
            self.bind('Simulink.metamodel.arplatform.instance.DataPortInstanceRef',@walkDataPortInstanceRef,'iVisit');
            self.bind('Simulink.metamodel.arplatform.instance.DataCompInstanceRef',@walkDataCompInstanceRef,'iVisit');
            self.bind('Simulink.metamodel.arplatform.instance.RunnableInstanceRef',@walkRunnableInstanceRef,'iVisit');
            self.bind('Simulink.metamodel.arplatform.instance.ModeDeclarationInstanceRef',@walkModeDeclarationInstanceRef,'iVisit');

            self.bind('Simulink.metamodel.arplatform.behavior.ApplicationComponentBehavior',@walkApplicationComponentBehavior,'iVisit')
            self.bind('Simulink.metamodel.arplatform.behavior.Runnable',@walkRunnable,'iVisit');
            self.bind('Simulink.metamodel.arplatform.behavior.OperationBlockingAccess',@walkOperationBlockingAccess,'iVisit');
            self.bind('Simulink.metamodel.arplatform.behavior.DataAccess',@walkDataAccess,'iVisit');
        end



        function ret=iVisitM3IObject(varargin)
            ret=[];
        end



        function ret=visitM3IObject(varargin)
            ret=[];
        end



        function ret=walkDataPortInstanceRef(self,m3iRef)
            ret=self.acceptDataPortInstanceRef(m3iRef);
        end



        function ret=walkDataCompInstanceRef(self,m3iRef)
            ret=self.acceptDataCompInstanceRef(m3iRef);
        end



        function ret=walkOperationPortInstanceRef(self,m3iRef)
            ret=self.acceptOperationPortInstanceRef(m3iRef);
        end



        function ret=walkRunnableInstanceRef(self,m3iRef)
            ret=self.acceptRunnableInstanceRef(m3iRef);
        end



        function ret=walkModeDeclarationInstanceRef(self,m3iRef)
            ret=self.acceptModeDeclarationInstanceRef(m3iRef);
        end



        function ret=walkApplicationComponentBehavior(self,m3iObj)
            ret=self.acceptApplicationComponentBehavior(m3iObj);
            self.applySeq('iVisit',m3iObj.Runnables);
        end



        function ret=walkRunnable(self,m3iObj)
            ret=self.acceptRunnable(m3iObj);
            self.applySeq('iVisit',m3iObj.dataAccess);
            self.applySeq('iVisit',m3iObj.irvRead);
            self.applySeq('iVisit',m3iObj.irvWrite);
            self.applySeq('iVisit',m3iObj.compParamRead);
            self.applySeq('iVisit',m3iObj.portParamRead);
            self.applySeq('iVisit',m3iObj.operationBlockingCall);
        end



        function ret=walkDataAccess(self,m3iObj)
            ret=self.acceptDataAccess(m3iObj);
        end



        function ret=walkOperationBlockingAccess(self,m3iObj)
            ret=self.acceptOperationBlockingAccess(m3iObj);
        end

    end

    methods(Abstract,Access=protected)
        ret=acceptDataPortInstanceRef(self,m3iRef)
        ret=acceptDataCompInstanceRef(self,m3iRef)
        ret=acceptOperationPortInstanceRef(self,m3iRef)
        ret=acceptRunnableInstanceRef(self,m3iRef)
        ret=acceptModeDeclarationInstanceRef(self,m3iRef)
        ret=acceptApplicationComponentBehavior(self,m3iObj)
        ret=acceptRunnable(self,m3iObj)
        ret=acceptDataAccess(self,m3iObj)
        ret=acceptOperationBlockingAccess(self,m3iObj)
    end

end


