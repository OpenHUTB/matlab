classdef FunctionInfoDataSource<handle




    properties(Constant)
        SoftwareComponentCol=getString(message('SoftwareArchitecture:ArchEditor:SoftwareComponentColumn'));
        FunctionNameCol=getString(message('SoftwareArchitecture:ArchEditor:FunctionNameColumn'));
        ExecutionOrderCol=getString(message('SoftwareArchitecture:ArchEditor:ExecutionOrderColumn'));
        DisabledColor=[0.95,0.95,0.95];
    end

    properties(Access=protected)
        pFunction;
        pParent;
    end

    methods(Abstract,Access=protected)
        getSubclassPropAllowedValues(this,propName);
        getSubclassPropValue(this,propName);
        setSubclassPropValue(this,propName,propValue);
    end

    methods
        function this=FunctionInfoDataSource(parentTab,functionObj)
            this.pFunction=functionObj;
            this.pParent=parentTab;
        end

        function funcHdl=get(this)
            funcHdl=this.pFunction;
        end

        function propType=getPropDataType(this,propName)
            if strcmpi(propName,this.SoftwareComponentCol)
                propType='enum';
            else
                propType='string';
            end
        end

        function propVal=getPropAllowedValues(this,propName)
            rootArch=this.pParent.getRootArchitecture();
            switch propName
            case this.SoftwareComponentCol
                propVal=[];
                swComps=swarch.utils.getAllSoftwareComponents(rootArch);
                swComps=swComps(...
                ~arrayfun(@(c)strcmp(get_param(systemcomposer.utils.getSimulinkPeer(c),'BlockType'),'ModelReference'),swComps));
                for swComp=swComps
                    propVal=[propVal...
                    ,{swarch.internal.spreadsheet.getComponentDisplayName(rootArch,swComp)}];%#ok<AGROW>
                end
            otherwise
                propVal=this.getSubclassPropAllowedValues(propName);
            end
        end

        function propValue=getPropValue(this,propName)
            switch propName
            case this.SoftwareComponentCol
                propValue=swarch.internal.spreadsheet.getComponentDisplayName(...
                this.pParent.getRootArchitecture(),this.pFunction.calledFunctionParent);
            case this.FunctionNameCol
                propValue=this.pFunction.getName();
            otherwise
                propValue=this.getSubclassPropValue(propName);
            end
        end

        function setPropValue(this,propName,propValue)
            import swarch.internal.spreadsheet.FunctionSelectedStyler;
            switch propName
            case this.SoftwareComponentCol
                targetParent=swarch.internal.spreadsheet.getComponentFromDisplayName(...
                this.pParent.getRootArchitecture(),propValue);
                initParentH=systemcomposer.utils.getSimulinkPeer(...
                this.pFunction.calledFunctionParent);




                txn=mf.zero.getModel(this.pFunction).beginTransaction();
                this.pFunction.calledFunction.reparent(targetParent.getArchitecture().getTrait(systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass));
                this.pFunction.calledFunctionParent=targetParent;
                txn.commit();


                FunctionSelectedStyler.removeStyle(initParentH);

                targetParentH=systemcomposer.utils.getSimulinkPeer(targetParent);
                FunctionSelectedStyler.applyStyle(targetParentH);

            case this.FunctionNameCol
                try
                    swarch.utils.setFunctionAndRootInportBlockName(this.pFunction,propValue);
                catch me


                    Simulink.output.error(me);
                end
            otherwise
                this.setSubclassPropValue(propName,propValue);
            end
        end

        function isValid=isValidProperty(~,~)
            isValid=true;
        end

        function readonly=isReadOnly(this)





            blockH=systemcomposer.utils.getSimulinkPeer(this.pFunction.calledFunctionParent);
            readonly=~ishandle(blockH)||strcmp(get_param(blockH,'BlockType'),'ModelReference');
        end

        function isEditable=isEditableProperty(this,propName)

            isEditable=true;


            if strcmp(propName,this.SoftwareComponentCol)&&this.isReadOnly()
                isEditable=false;
            end


            if(this.pFunction.type==systemcomposer.architecture.model.swarch.FunctionType.Server||...
                this.pFunction.type==systemcomposer.architecture.model.swarch.FunctionType.Message)&&...
                strcmp(propName,this.FunctionNameCol)
                isEditable=false;
            end

            if strcmp(propName,this.ExecutionOrderCol)
                isEditable=false;
            end
        end

        function getPropertyStyle(this,propName,style)
            if strcmp(propName,this.SoftwareComponentCol)&&this.isReadOnly()
                style.IconAlignment='left';
                style.Icon=swarch.internal.spreadsheet.getIconPath('ImplementedFunction_16.png');
            end

            if~this.isEditableProperty(propName)
                style.BackgroundColor=this.DisabledColor;
                style.Tooltip=getString(message('SoftwareArchitecture:ArchEditor:ReadOnlyFunctionProperty',propName));
            end
        end

        function selection=resolveComponentSelection(this)



            try
                compH=systemcomposer.utils.getSimulinkPeer(this.pFunction.calledFunctionParent);
                selection=get_param(compH,'Object');
            catch


                selection={};
            end
        end

        function schema=getPropertySchema(this)
            schema=swarch.internal.propertyinspector.FunctionSchema(...
            this.pParent.getSpreadsheet().getStudio(),this.pFunction);
        end
    end
end


