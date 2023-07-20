classdef BreakpointListSpreadsheetBlockRow<SimulinkDebugger.breakpoints.BreakpointListSpreadsheetRow




    methods
        function this=BreakpointListSpreadsheetBlockRow(breakpoint)
            this@SimulinkDebugger.breakpoints.BreakpointListSpreadsheetRow(breakpoint);
        end

        function setPropValue(this,propName,newValue)
            switch propName
            case DAStudio.message('Simulink:Debugger:SSColumn_Enabled')
                if nargin<2
                    newValue=~this.breakpoint_.enable_;
                end
                instance=SimulinkDebugger.breakpoints.GlobalBreakpointsListAccessor.getInstance();
                instance.enableDisableBlockBreakpoint(this.breakpoint_.zbreakpoint_.BPID,newValue);
                this.breakpoint_.enable_=newValue;
            otherwise
                return;
            end
        end

        function propValue=getPropValue(this,propName)
            switch propName
            case DAStudio.message('Simulink:Debugger:SSColumn_ID')
                propValue=num2str(this.breakpoint_.id_);
            case DAStudio.message('Simulink:Debugger:SSColumn_Source')
                propValue=this.breakpoint_.blockPath_;
            case DAStudio.message('Simulink:Debugger:SSColumn_Condition')
                propValue=DAStudio.message('Simulink:Debugger:SSRow_NotApplicable');
            case DAStudio.message('Simulink:Debugger:SSColumn_Hits')
                propValue=num2str(this.breakpoint_.hits_);
            case DAStudio.message('Simulink:Debugger:SSColumn_Enabled')
                propValue=num2str(this.breakpoint_.enable_);
            case DAStudio.message('Simulink:Debugger:SSColumn_Type')
                propValue=DAStudio.message('Simulink:Debugger:SSRow_Block');
            otherwise
                propValue='';
            end
        end

        function aResolve=resolveComponentSelection(this)


            obj=get_param(this.breakpoint_.src_,'Object');
            aResolve{1}=obj;
        end

        function isHyperlink=propertyHyperlink(this,propName,clicked)
            switch propName
            case DAStudio.message('Simulink:Debugger:SSColumn_Source')
                isHyperlink=true;
                if clicked
                    bp=this.breakpoint_.fullBlockPathToTopModel_;

                    bp=bp.refreshFromSSIDcache(false);
                    bp.openParent('OpenType','new-tab','Force',true);
                end
            otherwise
                isHyperlink=false;
            end
        end

        function deleteButtonCBImpl(this,src)

            src.globalBpList_.removeBlockBreakpoint(this.breakpoint_.zbreakpoint_.BPID)
        end

        function val=isEnabled(this)
            val=this.breakpoint_.enable_;
        end

    end
end
