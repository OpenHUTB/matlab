classdef BreakpointListSpreadsheetModelRow<SimulinkDebugger.breakpoints.BreakpointListSpreadsheetRow




    methods
        function this=BreakpointListSpreadsheetModelRow(breakpoint)
            this@SimulinkDebugger.breakpoints.BreakpointListSpreadsheetRow(breakpoint);
        end

        function setPropValue(this,propName,newValue)
            switch propName
            case this.msgCatalogCache_.enabledName_
                if nargin<2
                    newValue=~this.breakpoint_.enable_;
                end
                instance=SimulinkDebugger.breakpoints.GlobalBreakpointsListAccessor.getInstance();
                instance.enableDisableModelBreakpoint(this.breakpoint_.zbreakpoint_.BPID,newValue);
                this.breakpoint_.enable_=newValue;
            otherwise
                return;
            end
        end

        function propValue=getPropValue(this,propName)
            switch propName
            case this.msgCatalogCache_.columnIDName_
                propValue=num2str(this.breakpoint_.id_);
            case this.msgCatalogCache_.sourceName_
                propValue=this.breakpoint_.src_;
            case this.msgCatalogCache_.conditionName_
                propValue=this.getModelBreakpointString();
            case this.msgCatalogCache_.hitsName_
                propValue=DAStudio.message('Simulink:Debugger:SSRow_NotApplicable');
            case this.msgCatalogCache_.enabledName_
                propValue=num2str(this.breakpoint_.enable_);
            case this.msgCatalogCache_.typeName_
                propValue=DAStudio.message('Simulink:Debugger:SSRow_Model');
            otherwise
                propValue='';
            end
        end

        function aResolve=resolveComponentSelection(~)

            aResolve=null;
            return;
        end

        function isHyperlink=propertyHyperlink(~,~,~)

            isHyperlink=false;
            return;
        end

        function deleteButtonCBImpl(this,~)

            instance=SimulinkDebugger.breakpoints.GlobalBreakpointsListAccessor.getInstance();
            instance.removeModelBreakpoint(this.breakpoint_.zbreakpoint_.BPID);
        end

        function val=isEnabled(this)
            val=this.breakpoint_.enable_;
        end

    end

    methods(Access=private)
        function propValue=getModelBreakpointString(this)
            switch this.breakpoint_.bpType_
            case slbreakpoints.datamodel.ModelBreakpointType.ZeroCrossing
                propValue=DAStudio.message('Simulink:Debugger:SSRow_ZeroCrossings');
            case slbreakpoints.datamodel.ModelBreakpointType.StepSizeLimited
                propValue=DAStudio.message('Simulink:Debugger:SSRow_StepSize');
            case slbreakpoints.datamodel.ModelBreakpointType.SolverError
                propValue=DAStudio.message('Simulink:Debugger:SSRow_SolverError');
            case slbreakpoints.datamodel.ModelBreakpointType.NanValues
                propValue=DAStudio.message('Simulink:Debugger:SSRow_NaNValues');
            end
        end
    end
end
