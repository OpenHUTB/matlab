classdef BreakpointListSpreadsheetRow<handle&matlab.mixin.Heterogeneous




    properties
breakpoint_
msgCatalogCache_
    end

    methods
        function this=BreakpointListSpreadsheetRow(breakpoint)
            this.breakpoint_=breakpoint;
            this.msgCatalogCache_=SimulinkDebugger.CachedMessageAccessor.getInstance();
        end

        function label=getDisplayLabel(this)

            label=num2str(this.breakpoint_.id_);
        end

        function propValue=locGetDisplayToRealProperty(this,propName)


            switch propName
            case this.msgCatalogCache_.columnIDName_
                propValue='ID';
            case this.msgCatalogCache_.sourceName_
                propValue='Source';
            case this.msgCatalogCache_.conditionName_
                propValue='Condition';
            case this.msgCatalogCache_.hitsName_
                propValue='Hits';
            case this.msgCatalogCache_.enabledName_
                propValue='Enabled';
            case this.msgCatalogCache_.typeName_
                propValue='Source Type';
            otherwise
                propValue='';
            end
        end

        function dtype=getPropDataType(this,propName)


            switch propName
            case this.msgCatalogCache_.enabledName_
                dtype='bool';
            otherwise
                dtype='string';
            end
        end

        function propValueCell=getDisplayToRealProperty(this,propName)


            propValueCell=cell(1,numel(propName));
            for idx=1:numel(propName)
                propValueCell{idx}=this.locGetDisplayToRealProperty(propName{idx});
            end
        end

        function isValid=isValidProperty(this,propName)
            switch propName
            case this.msgCatalogCache_.columnIDName_
                isValid=true;
            case this.msgCatalogCache_.sourceName_
                isValid=true;
            case this.msgCatalogCache_.conditionName_
                isValid=true;
            case this.msgCatalogCache_.hitsName_
                isValid=true;
            case this.msgCatalogCache_.enabledName_
                isValid=true;
            case this.msgCatalogCache_.typeName_
                isValid=true;
            otherwise
                isValid=false;
            end
        end

        function isReadOnly=isReadonlyProperty(this,propName)
            isReadOnly=true;
            if isequal(propName,this.msgCatalogCache_.enabledName_)
                isReadOnly=false;
            end
        end

        function deleteAndRefresh(this)
            this.deleteButtonCBImpl();
            instance=SimulinkDebugger.breakpoints.GlobalBreakpointsListAccessor.getInstance();
            instance.callRefresh();
        end

        function getPropertyStyle(this,propName,propStyle)
            if isequal(propName,this.msgCatalogCache_.sourceName_)

                propStyle.WidgetInfo=struct('Type','propertyaction',...
                'Icon',fullfile(matlabroot,'toolbox',...
                'shared','dastudio','resources','removeOneRowBPList_16.png'),...
                'Tooltip',DAStudio.message('Simulink:Debugger:DeleteButtonToolTip'),...
                'Display','hover',...
                'Callback',@(obj,prop,value)this.deleteAndRefresh());
            end

            this.getPropertyStyleImpl(propName,propStyle);
        end

        function getPropertyStyleImpl(~,~,~)



        end
    end

    methods(Abstract)
        setPropValue(this,propName,newRow)
        propValue=getPropValue(this,propName)
        aResolve=resolveComponentSelection(this)
        isHyperlink=propertyHyperlink(this,propName,clicked)
        deleteButtonCBImpl(this,src)
    end

    methods(Static)
        function str=relationalOperatorString(idx)
            msgCatalogCache=SimulinkDebugger.CachedMessageAccessor.getInstance();
            switch(idx)
            case 0
                str=msgCatalogCache.greater_;
            case 1
                str=msgCatalogCache.greaterEqual_;
            case 2
                str=msgCatalogCache.equal_;
            case 3
                str=msgCatalogCache.notEqual_;
            case 4
                str=msgCatalogCache.lessEqual_;
            case 5
                str=msgCatalogCache.less_;
            otherwise
                assert(false,'invalid relational operator supplied for a model breakpoint');
            end
        end
    end
end


