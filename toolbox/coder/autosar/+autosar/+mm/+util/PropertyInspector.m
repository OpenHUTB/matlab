classdef(Hidden)PropertyInspector



    methods(Access=private,Static)




        function m3iObj=getInternalBehaviorObject(modelName,type,shortName)
            m3iObj=[];
            compObj=autosar.api.Utils.m3iMappedComponent(modelName);
            m3iBehavior=compObj.Behavior;
            if strcmp(type,'ArTypedPerInstanceMemory')
                className='Simulink.metamodel.arplatform.interface.VariableData';
                m3iObj=Simulink.metamodel.arplatform.ModelFinder.findNamedItemInSequence(...
                m3iBehavior,m3iBehavior.ArTypedPIM,shortName,className);
            elseif strcmp(type,'PerInstanceMemory')
                className='Simulink.metamodel.arplatform.interface.VariableData';
                m3iObj=Simulink.metamodel.arplatform.ModelFinder.findNamedItemInSequence(...
                m3iBehavior,m3iBehavior.PIM,shortName,className);
            elseif strcmp(type,'StaticMemory')
                className='Simulink.metamodel.arplatform.interface.VariableData';
                m3iObj=Simulink.metamodel.arplatform.ModelFinder.findNamedItemInSequence(...
                m3iBehavior,m3iBehavior.StaticMemory,shortName,className);
            elseif strcmp(type,'SharedParameter')
                className='Simulink.metamodel.arplatform.interface.ParameterData';
                m3iObj=Simulink.metamodel.arplatform.ModelFinder.findNamedItemInSequence(...
                m3iBehavior,m3iBehavior.Parameters,shortName,className);
            elseif strcmp(type,'PerInstanceParameter')
                className='Simulink.metamodel.arplatform.interface.ParameterData';
                m3iObj=Simulink.metamodel.arplatform.ModelFinder.findNamedItemInSequence(...
                m3iBehavior,m3iBehavior.Parameters,shortName,className);
            elseif strcmp(type,'ConstantMemory')
                className='Simulink.metamodel.arplatform.interface.ParameterData';
                m3iObj=Simulink.metamodel.arplatform.ModelFinder.findNamedItemInSequence(...
                m3iBehavior,m3iBehavior.Parameters,shortName,className);
            elseif strcmp(type,'Runnable')
                className='Simulink.metamodel.arplatform.behavior.Runnable';
                m3iObj=Simulink.metamodel.arplatform.ModelFinder.findNamedItemInSequence(...
                m3iBehavior,m3iBehavior.Runnables,shortName,className);
            else
                assert(false,sprintf('%s is not supported by function autosar.mm.util.PropertyInspector.getInternalBehaviorObject().',type));
            end
        end
    end

    methods(Access=public,Static)




        function props=getInternalBehaviorObjectProperties(modelName,type,shortName)
            props={};
            m3iObj=autosar.mm.util.PropertyInspector.getInternalBehaviorObject(modelName,type,shortName);
            if~isempty(m3iObj)
                props=autosar.ui.metamodel.AttributeUtils.getProperties(m3iObj);
                props=setdiff(props,'Name','stable');
            end
        end






        function setPropValue(modelName,type,shortName,propName,propValue)
            m3iObject=autosar.mm.util.PropertyInspector.getInternalBehaviorObject(modelName,type,shortName);
            isValid=autosar.ui.metamodel.AttributeUtils.isValidNameValue(m3iObject,propName,propValue);
            if isValid
                autosar.ui.metamodel.AttributeUtils.setPropValue(m3iObject,propName,propValue);
            end
        end







        function propValue=getPropValue(modelName,type,shortName,propName)
            m3iObject=autosar.mm.util.PropertyInspector.getInternalBehaviorObject(modelName,type,shortName);
            propValue=autosar.ui.metamodel.AttributeUtils.getPropValue(m3iObject,propName);
        end







        function propValues=getPropAllowedValues(modelName,type,shortName,propName)
            m3iObject=autosar.mm.util.PropertyInspector.getInternalBehaviorObject(modelName,type,shortName);
            propValues=autosar.ui.metamodel.AttributeUtils.getPropAllowedValues(m3iObject,propName);
        end







        function propValue=getPropDataType(modelName,type,shortName,propName)
            m3iObject=autosar.mm.util.PropertyInspector.getInternalBehaviorObject(modelName,type,shortName);
            propValue=autosar.ui.metamodel.AttributeUtils.getPropDataType(m3iObject,propName);
        end





        function findOrCreateInternalBehaviorObject(modelName,type,shortName)
            m3iModel=autosar.api.Utils.m3iModel(modelName);
            m3iModel.beginTransaction();
            compObj=autosar.api.Utils.m3iMappedComponent(modelName);
            m3iBehavior=compObj.Behavior;
            if strcmp(type,'ArTypedPerInstanceMemory')
                className='Simulink.metamodel.arplatform.interface.VariableData';
                m3iVarData=Simulink.metamodel.arplatform.ModelFinder.findOrCreateNamedItemInSequence(...
                m3iBehavior,m3iBehavior.ArTypedPIM,shortName,className);%#ok<NASGU>
            elseif strcmp(type,'PerInstanceMemory')
                className='Simulink.metamodel.arplatform.interface.VariableData';
                m3iVarData=Simulink.metamodel.arplatform.ModelFinder.findOrCreateNamedItemInSequence(...
                m3iBehavior,m3iBehavior.PIM,shortName,className);%#ok<NASGU>
            elseif strcmp(type,'StaticMemory')
                className='Simulink.metamodel.arplatform.interface.VariableData';
                m3iVarData=Simulink.metamodel.arplatform.ModelFinder.findOrCreateNamedItemInSequence(...
                m3iBehavior,m3iBehavior.StaticMemory,shortName,className);%#ok<NASGU>
            elseif strcmp(type,'SharedParameter')
                className='Simulink.metamodel.arplatform.interface.ParameterData';
                m3iPrmData=Simulink.metamodel.arplatform.ModelFinder.findOrCreateNamedItemInSequence(...
                m3iBehavior,m3iBehavior.Parameters,shortName,className);
                m3iPrmData.Kind=Simulink.metamodel.arplatform.behavior.ParameterKind.Shared;
            elseif strcmp(type,'PerInstanceParameter')
                className='Simulink.metamodel.arplatform.interface.ParameterData';
                m3iPrmData=Simulink.metamodel.arplatform.ModelFinder.findOrCreateNamedItemInSequence(...
                m3iBehavior,m3iBehavior.Parameters,shortName,className);
                m3iPrmData.Kind=Simulink.metamodel.arplatform.behavior.ParameterKind.Pim;
            elseif strcmp(type,'ConstantMemory')
                className='Simulink.metamodel.arplatform.interface.ParameterData';
                m3iPrmData=Simulink.metamodel.arplatform.ModelFinder.findOrCreateNamedItemInSequence(...
                m3iBehavior,m3iBehavior.Parameters,shortName,className);
                m3iPrmData.Kind=Simulink.metamodel.arplatform.behavior.ParameterKind.Const;
            elseif strcmp(type,'Runnable')
                className='Simulink.metamodel.arplatform.behavior.Runnable';
                m3iRunnable=Simulink.metamodel.arplatform.ModelFinder.findOrCreateNamedItemInSequence(...
                m3iBehavior,m3iBehavior.Runnables,shortName,className);%#ok<NASGU>
            else
                assert(false,sprintf('%s is not supported by function autosar.mm.Util.PropertyInspector.createInternalBehaviorObject().',type));
            end
            m3iModel.commitTransaction();
        end






        function swAddrMethodName=getSwAddrMethodForRunnable(model,runnableName)
            swAddrMethodName=autosar.mm.util.PropertyInspector.getPropValue(...
            model,'Runnable',runnableName,'SwAddrMethod');
            if strcmp(swAddrMethodName,DAStudio.message('RTW:autosar:uiUnselectOptions'))


                swAddrMethodName='';
            end
        end
    end
end


