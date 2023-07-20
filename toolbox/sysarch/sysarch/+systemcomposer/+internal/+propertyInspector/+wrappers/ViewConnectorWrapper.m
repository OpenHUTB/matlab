classdef ViewConnectorWrapper<systemcomposer.internal.propertyInspector.wrappers.StereotypableElementWrapper





    properties
        selectedConnDest char='';
        selectedConn;
        mdl;
        occurenceElement;
        bdH;
        schemaType;
        destPortEditable;
        destPortRenderMode;
        nameTooltip;
        isAUTOSARCompositionSubDomain;
    end

    methods
        function obj=ViewConnectorWrapper(varargin)


            obj=obj@systemcomposer.internal.propertyInspector.wrappers.StereotypableElementWrapper(varargin{:});
            if(obj.isAUTOSARCompositionSubDomain)
                obj.schemaType='AUTOSARConnector';
            else
                if isa(obj.element,'systemcomposer.architecture.model.design.NAryConnector')
                    obj.schemaType='NAryConnector';
                else
                    obj.schemaType='Connector';
                end
            end
        end
        function type=getObjectType(obj)
            if isa(obj.element,'systemcomposer.architecture.model.design.NAryConnector')
                type='NAryConnector';
            else
                type='Connector';
            end
        end

        function setPropElement(obj)
            if~isempty(obj.options)
                obj.selectedConnDest=obj.options.dstPort;
            end
            obj.bdH=get_param(obj.archName,'Handle');
            obj.app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(obj.bdH);
            obj.mdl=obj.app.getArchViewsAppMgr.getModel();
            obj.occurenceElement=obj.mdl.findElement(obj.uuid);
            obj.element=systemcomposer.architecture.model.views.ViewCatalog.getDesignConnectorsForViewConnector(obj.occurenceElement);
            obj.selectedConn=obj.getSelectedConnector();
            if(length(obj.element)>1)
                obj.destPortEditable=true;
                obj.destPortRenderMode='combobox';
            else
                obj.destPortEditable=false;
                obj.destPortRenderMode='editbox';
            end
            if Simulink.internal.isArchitectureModel(obj.bdH,'AUTOSARArchitecture')
                obj.isAUTOSARCompositionSubDomain=true;
            end
        end

        function conn=getSelectedConnector(obj)
            if~isempty(obj.selectedConnDest)

                allDest=arrayfun(@(x)x.p_ConnectorEnds(2).p_Port.getName,obj.element,'UniformOutput',false);
                assert(ismember(obj.selectedConnDest,allDest));
                idxSelectedDest=cellfun(@(dest)isequal(obj.selectedConnDest,dest),allDest);
                conn=obj.element(idxSelectedDest);
            else

                conn=obj.element(1);
            end
            assert(length(conn)==1);
        end

        function name=getName(obj)
            name=obj.selectedConn.getName();
            obj.nameTooltip=[obj.selectedConn(1).p_ConnectorEnds(1).p_Port.getQualifiedName,'->',obj.selectedConn(1).p_ConnectorEnds(2).p_Port.getQualifiedName];
        end

        function setStereotypeElement(obj)
            obj.stereotypeElement=obj.selectedConn;
        end

        function err=setName(obj,changeSet,~)
            err='';
            newValue=changeSet.newValue;
            obj.selectedConn.setName(newValue);
        end
        function sourceName=getSourcePortName(obj)
            if(length(obj.element)>1)
                allSrcName=arrayfun(@(conn)conn(1).p_ConnectorEnds(1).p_Port.getName,obj.element,'UniformOutput',false);
                assert(all(cellfun(@(name)isequal(name,allSrcName{1}),allSrcName)));
            end
            sourceName=obj.element(1).p_ConnectorEnds(1).p_Port.getName;
        end
        function[value,entries]=getDestinationPorts(obj)
            if(length(obj.element)>1)
                entries=arrayfun(@(conn)conn(1).p_ConnectorEnds(2).p_Port.getName,obj.element,'UniformOutput',false);
                if isempty(obj.selectedConnDest)

                    value=obj.element(1).p_ConnectorEnds(2).p_Port.getName;
                else
                    value=obj.selectedConn(1).p_ConnectorEnds(2).p_Port.getName;
                end
            else
                value=obj.element(1).p_ConnectorEnds(2).p_Port.getName;
                entries='';
            end
        end

        function value=getDestPortRenderMode(obj)
            value=obj.destPortRenderMode;
        end

        function value=getDestPortEditable(obj)
            value=obj.destPortEditable;
        end

        function value=getNameTooltip(obj)
            value=obj.nameTooltip;
        end
        function status=isNameEditable(~)

            status=true;
        end
    end
end

