classdef BreakpointListSpreadsheetSignalRow<SimulinkDebugger.breakpoints.BreakpointListSpreadsheetRow




    properties
srcToBeHighlighted_
    end

    methods(Access=public)
        function this=BreakpointListSpreadsheetSignalRow(breakpoint,srcToBeHighlighted)
            this@SimulinkDebugger.breakpoints.BreakpointListSpreadsheetRow(breakpoint);
            this.srcToBeHighlighted_=srcToBeHighlighted;
        end

        function setPropValue(this,propName,newValue)
            switch propName
            case this.msgCatalogCache_.enabledName_

                if ischar(newValue)
                    if isequal(newValue,'0')
                        newValue=false;
                    else
                        newValue=true;
                    end
                end
                condStatus.index=this.breakpoint_.index_;
                condStatus.status=newValue;
                set_param(this.breakpoint_.src_,'ConditionalPauseStatus',condStatus);
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
                propValue=[get_param(this.breakpoint_.src_,'Parent'),':',...
                num2str(get_param(this.breakpoint_.src_,'PortNumber'))];
            case this.msgCatalogCache_.conditionName_
                propValue=[SimulinkDebugger.breakpoints.BreakpointListSpreadsheetRow.relationalOperatorString(...
                this.breakpoint_.condition_),' ',num2str(this.breakpoint_.value_)];
            case this.msgCatalogCache_.hitsName_
                propValue=num2str(this.breakpoint_.hits_);
            case this.msgCatalogCache_.enabledName_
                propValue=num2str(this.breakpoint_.enable_);
            case this.msgCatalogCache_.typeName_
                propValue=DAStudio.message('Simulink:Debugger:SSRow_Signal');
            otherwise
                propValue='';
            end
        end

        function getPropertyStyleImpl(this,propName,propStyle)
            if isequal(propName,this.msgCatalogCache_.conditionName_)


                blk=get_param(this.breakpoint_.src_,'Parent');
                model=get_param(blk,'Parent');
                modelH=get_param(model,'Handle');
                propStyle.WidgetInfo=struct('Type','propertyaction',...
                'Icon','toolbox/shared/dastudio/resources/actions_16.png',...
                'Tooltip',DAStudio.message('Simulink:Debugger:ChangeCondition'),...
                'Display','hover',...
                'Callback',...
                @(obj,prop,value)SimulinkDebugger.breakpoints.ShowAddConditionalPauseDialog(...
                modelH,this.breakpoint_.src_,this.breakpoint_.index_));
            end


            bplist=get_param(this.breakpoint_.src_,'ConditionalPauseList');
            bpIdx=1;
            lastHitDataIdx=5;
            bplistSize=size(bplist.data);
            for idx=1:bplistSize(1)
                if~isempty(bplist.data)&&...
                    isequal(this.breakpoint_.index_,bplist.data{idx,bpIdx})&&...
                    bplist.data{idx,lastHitDataIdx}...
                    &&this.breakpoint_.enable_
                    propStyle.BackgroundColor=[.8,1,.75,.3];
                end
            end




            if isequal(this.breakpoint_.src_,this.srcToBeHighlighted_)
                propStyle.BackgroundColor=[0.59,0.05,0.45,.3];
            end
        end

        function aResolve=resolveComponentSelection(this)


            obj=get_param(this.breakpoint_.src_,'Object');
            if(isa(obj,'Simulink.Port'))

                parent=get_param(this.breakpoint_.src_,'Parent');
                sourceSegment=get_param(this.breakpoint_.src_,'Line');

                fullPath=this.generateFullSegmentPath(sourceSegment);
                aResolve=cell(1,length(fullPath)+2);
                aResolve{1}=obj;
                for idx=1:length(fullPath)
                    aResolve{1+idx}=get_param(fullPath(idx),'Object');
                end


                aResolve{end}=get_param(parent,'Object');

            end
        end

        function isHyperlink=propertyHyperlink(this,propName,clicked)
            switch propName
            case this.msgCatalogCache_.sourceName_
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

        function deleteButtonCBImpl(this,~)

            condStatus.index=this.breakpoint_.index_;
            deletedVal=3;
            condStatus.status=deletedVal;
            set_param(this.breakpoint_.src_,'ConditionalPauseStatus',condStatus)
        end

        function val=isEnabled(this)
            val=this.breakpoint_.enable_;
        end

    end

    methods(Static)

        function fullPath=generateFullSegmentPath(currSegment)


            fullPath=[];


            if(isempty(currSegment)||currSegment==-1)
                return;
            end


            children=get_param(currSegment,'LineChildren');
            for idx=1:length(children)
                fullPath=[fullPath,SimulinkDebugger.breakpoints.BreakpointListSpreadsheetSignalRow.generateFullSegmentPath(children(idx))];%#ok<AGROW> 
            end
            fullPath=[fullPath,currSegment];
        end

    end

end


