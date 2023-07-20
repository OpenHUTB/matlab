classdef BreakpointListSpreadsheetSFRow<SimulinkDebugger.breakpoints.BreakpointListSpreadsheetRow




    properties
srcToBeHighlighted_
    end

    methods
        function this=BreakpointListSpreadsheetSFRow(breakpoint)
            this@SimulinkDebugger.breakpoints.BreakpointListSpreadsheetRow(breakpoint);
            this.srcToBeHighlighted_=breakpoint.isHit_;
        end

        function bp=getBreakPoint(this)


            bpList=Simulink.Debug.BreakpointList.getAllBreakpoints();
            for i=1:numel(bpList)
                bp=bpList{i};
                if bp.id==this.breakpoint_.sfId_
                    return;
                end
            end
        end

        function setPropValue(this,propName,newValue)
            switch propName
            case DAStudio.message('Simulink:Debugger:SSColumn_Enabled')
                if nargin<2
                    newValue=~this.breakpoint_.enable_;
                end




                if ischar(newValue)
                    newValue=strcmp(newValue,'1');
                end
                this.breakpoint_.enable_=newValue;
                sfbp=this.getBreakPoint();
                if newValue
                    sfbp.enable();
                else
                    sfbp.disable();
                end
                if isa(this.breakpoint_,'SimulinkDebugger.breakpoints.EMLBreakPoint')
                    Stateflow.Debug.EML.EMLBreakpoint.createBreakpointForStateId(sfbp.ownerUdd.Id,sfbp.lineNum,sfbp.condition,sfbp.isEnabled);
                end
            case DAStudio.message('Simulink:Debugger:SSColumn_Condition')
                this.breakpoint_.condition_=newValue;
                sfbp=this.getBreakPoint();
                sfbp.condition=newValue;
                if isa(this.breakpoint_,'SimulinkDebugger.breakpoints.EMLBreakPoint')
                    Stateflow.Debug.EML.EMLBreakpoint.createBreakpointForStateId(sfbp.ownerUdd.Id,sfbp.lineNum,sfbp.condition,sfbp.isEnabled);
                end
            otherwise
                return;
            end
        end

        function propValue=getPropValue(this,propName)
            switch propName
            case DAStudio.message('Simulink:Debugger:SSColumn_ID')
                propValue=num2str(this.breakpoint_.id_);
            case DAStudio.message('Simulink:Debugger:SSColumn_Source')
                propValue=this.breakpoint_.fullBlockPathToTopModel_;
            case DAStudio.message('Simulink:Debugger:SSColumn_Condition')
                propValue=num2str(this.breakpoint_.condition_);
            case DAStudio.message('Simulink:Debugger:SSColumn_Hits')
                propValue=num2str(this.breakpoint_.hits_);
            case DAStudio.message('Simulink:Debugger:SSColumn_Enabled')
                propValue=num2str(this.breakpoint_.enable_);
            case DAStudio.message('Simulink:Debugger:SSColumn_Type')
                propValue=this.breakpoint_.type_.getString();
            otherwise
                propValue='';
            end
        end

        function aResolve=resolveComponentSelection(this)


            bp=this.getBreakPoint();
            aResolve{1}=bp.ownerUdd;
        end

        function isHyperlink=propertyHyperlink(this,propName,clicked)
            switch propName
            case DAStudio.message('Simulink:Debugger:SSColumn_Source')
                isHyperlink=true;
                if clicked
                    sfbp=this.getBreakPoint();
                    objH=sfbp.ownerUdd;
                    objH.view();
                    if isa(this.breakpoint_,'SimulinkDebugger.breakpoints.EMLBreakPoint')

                        bpStruct=Stateflow.Debug.EML.getSourceBreakpoint(sfbp);
                        m=slmle.internal.slmlemgr.getInstance;
                        objectId=m.getObjectId(Simulink.ID.getFullName(bpStruct.fileName));
                        editor=m.getMLFBEditor(objectId);
                        editor.goToLine(bpStruct.lineNumber);
                    end
                end
            otherwise
                isHyperlink=false;
            end
        end

        function deleteButtonCBImpl(this,~)
            sfbp=this.getBreakPoint();
            if isa(sfbp,'Stateflow.Debug.EML.EMLBreakpoint')
                if isa(sfbp.ownerUdd.getParent,'Stateflow.Chart')


                    stateId=sfbp.ownerUdd.Id;
                else


                    stateId=sf('find','all','state.chart',sfbp.ownerUdd.Id);
                end
                Stateflow.Debug.EML.EMLBreakpoint.deleteBreakpointForStateIdAt(stateId,sfbp.lineNum);
            else
                Stateflow.Debug.SFBreakpoint.deleteBreakpoint(sfbp);
            end
        end

        function val=isEnabled(this)
            val=this.breakpoint_.enable_;
        end

        function isReadOnly=isReadonlyProperty(~,propName)


            isReadOnly=true;
            if isequal(propName,DAStudio.message('Simulink:Debugger:SSColumn_Enabled'))||...
                isequal(propName,DAStudio.message('Simulink:Debugger:SSColumn_Condition'))
                isReadOnly=false;
            end
        end

        function getPropertyStyleImpl(this,~,propStyle)
            if this.srcToBeHighlighted_
                propStyle.BackgroundColor=[.8,1,.75,.3];
            end
        end

    end
end
