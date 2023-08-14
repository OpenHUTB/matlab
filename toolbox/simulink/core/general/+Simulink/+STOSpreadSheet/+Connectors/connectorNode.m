classdef connectorNode<handle

    methods(Static,Access=public)

        function handleStyleCheckbox(comp,obj,dlg,value)

            connectorNode=obj{1};

            if(isequal(value,'1'))
                connectorNode.m_Selected='on';
            else
                connectorNode.m_Selected='off';
            end

            if(isequal(connectorNode.m_Selected,'on'))

                switch connectorNode.connectorType
                case DAStudio.message('Simulink:studio:FunctionConnectors')

                    set_param(connectorNode.mModelName,'FunctionConnectors',1);
                    Simulink.functionConnectorMenu(get_param(connectorNode.mModelName,'handle'),true);

                case DAStudio.message('Simulink:studio:StateConnectors')

                    set_param(connectorNode.mModelName,'StateConnectors',1);
                    Simulink.stateConnectorMenu(get_param(connectorNode.mModelName,'handle'),true);

                case DAStudio.message('Simulink:studio:ParameterConnectors')

                    set_param(connectorNode.mModelName,'ParameterConnectors',1);
                    Simulink.parameterConnectorMenu(get_param(connectorNode.mModelName,'handle'),true);

                case DAStudio.message('Simulink:studio:DataStoreConnectors')

                    set_param(connectorNode.mModelName,'DataStoreConnectors',1);
                    Simulink.dataStoreConnectorMenu(get_param(connectorNode.mModelName,'handle'),true);

                case DAStudio.message('Simulink:studio:ScheduleConnectors')

                    set_param(connectorNode.mModelName,'ScheduleConnectors',1);

                otherwise
                    error('Unknown connector type');
                end


            else

                switch connectorNode.connectorType
                case DAStudio.message('Simulink:studio:FunctionConnectors')

                    set_param(connectorNode.mModelName,'FunctionConnectors',0);
                    Simulink.functionConnectorMenu(get_param(connectorNode.mModelName,'handle'),false);


                case DAStudio.message('Simulink:studio:StateConnectors')

                    set_param(connectorNode.mModelName,'StateConnectors',0);
                    Simulink.stateConnectorMenu(get_param(connectorNode.mModelName,'handle'),false);

                case DAStudio.message('Simulink:studio:ParameterConnectors')

                    set_param(connectorNode.mModelName,'ParameterConnectors',0);
                    Simulink.parameterConnectorMenu(get_param(connectorNode.mModelName,'handle'),false);


                case DAStudio.message('Simulink:studio:DataStoreConnectors')

                    set_param(connectorNode.mModelName,'DataStoreConnectors',0);
                    Simulink.dataStoreConnectorMenu(get_param(connectorNode.mModelName,'handle'),false);

                case DAStudio.message('Simulink:studio:ScheduleConnectors')

                    set_param(connectorNode.mModelName,'ScheduleConnectors',0);

                otherwise
                    error('Unknown connector type');
                end
            end

        end

    end
    properties
        Color;
        mModelName;
        sourceObj;
        connectorType;
        m_Selected;
    end
    methods
        function this=connectorNode(sourceObj,mModelName,connectorInfo)
            this.mModelName=mModelName;
            this.sourceObj=sourceObj;
            this.Color=[0.5,0.5,1];
            this.connectorType=connectorInfo.name;
            this.Color=connectorInfo.rgb;


            this.m_Selected='off';

            switch this.connectorType
            case DAStudio.message('Simulink:studio:FunctionConnectors')

                this.m_Selected=get_param(this.mModelName,'FunctionConnectors');

            case DAStudio.message('Simulink:studio:StateConnectors')

                this.m_Selected=get_param(this.mModelName,'StateConnectors');

            case DAStudio.message('Simulink:studio:ParameterConnectors')

                this.m_Selected=get_param(this.mModelName,'ParameterConnectors');

            case DAStudio.message('Simulink:studio:DataStoreConnectors')

                this.m_Selected=get_param(this.mModelName,'DataStoreConnectors');

            case DAStudio.message('Simulink:studio:ScheduleConnectors')

                this.m_Selected=get_param(this.mModelName,'ScheduleConnectors');

            otherwise
                error('Unknown connector type');
            end
        end

        function this=update(this)

            this.m_Selected='off';

            switch this.connectorType
            case DAStudio.message('Simulink:studio:FunctionConnectors')

                this.m_Selected=get_param(this.mModelName,'FunctionConnectors');

            case DAStudio.message('Simulink:studio:StateConnectors')

                this.m_Selected=get_param(this.mModelName,'StateConnectors');

            case DAStudio.message('Simulink:studio:ParameterConnectors')

                this.m_Selected=get_param(this.mModelName,'ParameterConnectors');

            case DAStudio.message('Simulink:studio:DataStoreConnectors')

                this.m_Selected=get_param(this.mModelName,'DataStoreConnectors');

            case DAStudio.message('Simulink:studio:ScheduleConnectors')

                this.m_Selected=get_param(this.mModelName,'ScheduleConnectors');

            otherwise
                error('Unknown connector type');
            end
        end


        function getPropertyStyle(this,aPropName,propertyStyle)

            if(isequal(aPropName,'Color'))
                propertyStyle.WidgetInfo=struct('Type','progressbar',...
                'Values',1,'Colors',[this.Color,1],"Height",10);
            elseif(isequal(aPropName,''))
                propertyStyle.WidgetInfo=struct('Type','checkbox',...
                'Value',this.m_Selected,...
                'Callback',...
                @(comp,obj,dlg,value)...
                Simulink.STOSpreadSheet.Connectors.connectorNode.handleStyleCheckbox(comp,obj,dlg,value));
            end


        end

        function b=isHierarchical(~)
            b=false;
        end

        function children=getChildren(this)
            children=[];
        end


        function children=getHierarchicalChildren(this)
            children=[];
        end

        function readOnly=isReadonlyProperty(this,propName)
            if(isequal(propName,''))
                readOnly=false;
            else
                readOnly=true;
            end
        end



        function isValid=isValidProperty(this,propName)
            isValid=true;
        end


        function objInfo=getObjectInfo(obj)
            objInfo='';
        end

        function propValue=getPropValue(obj,propName)
            switch propName
            case DAStudio.message('Simulink:studio:GeneralConnectors')
                propValue=obj.connectorType;
            otherwise
                propValue=" ";
            end
        end
    end
end