


classdef IndexPortDimConstraint<slci.compatibility.Constraint
    properties(Access=private)
        fPortKind='';
        fPortNumber=1;
        fIncompatiblePortListStr='';
        fSupportedDataType='scalar';
    end

    methods(Access=private)

        function out=getPortKind(aObj)
            out=aObj.fPortKind;
        end

        function out=getPortNumber(aObj)
            out=aObj.fPortNumber;
        end

        function out=getIncompatiblePortList(aObj)
            out=aObj.fIncompatiblePortListStr;
        end

        function setPortKind(aObj,aPortKind)
            aObj.fPortKind=aPortKind;
        end

        function setPortNumber(aObj,aPortNumber)
            aObj.fPortNumber=aPortNumber;
        end

        function setIncompatiblePortList(aObj,aPortList)
            aObj.fIncompatiblePortListStr=aPortList;
        end

        function out=isSupportedDim(aObj,pHandle)%#ok
            port_dim=get_param(pHandle,'CompiledPortWidth');
            out=(port_dim>1);
        end

    end

    methods

        function out=getDescription(aObj)%#ok
            out='Index port data type of Selector/Assignment must be of data type int32.';
        end


        function obj=IndexPortDimConstraint(aPortKind,aPortNumber)
            obj.setEnum('IndexPortDim');
            obj.setCompileNeeded(1);
            obj.setFatal(false);

            obj.setPortKind(aPortKind);
            obj.setPortNumber(aPortNumber);
        end

        function out=check(aObj)
            out=[];







            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>

            portHandles=aObj.ParentBlock().getParam('PortHandles');
            portKind=aObj.getPortKind();
            pH=[];
            switch upper(portKind)
            case 'INPORT'
                pH=portHandles.Inport;
            otherwise
                assert(false,'wrong index port kind.');
            end

            if~isempty(pH)
                tPortNumber=aObj.getPortNumber();

                tIncompatiblePortListStr=[];
                for iPort=1:numel(tPortNumber)
                    assert(tPortNumber(iPort)<=numel(pH));
                    port_handle=pH(tPortNumber(iPort));
                    status=isSupportedDim(aObj,port_handle);
                    if(status)
                        if isempty(tIncompatiblePortListStr)
                            tIncompatiblePortListStr=num2str(tPortNumber(iPort));
                        else
                            tIncompatiblePortListStr=...
                            [tIncompatiblePortListStr,', ',num2str(tPortNumber(iPort))];%#ok
                        end
                    end
                end

                aObj.setIncompatiblePortList(tIncompatiblePortListStr);
                if~isempty(tIncompatiblePortListStr)
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'IndexPortDim',...
                    aObj.ParentBlock().getName(),...
                    aObj.getPortKind(),...
                    aObj.getIncompatiblePortList(),...
                    aObj.fSupportedDataType);
                end
            end
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,varargin)%#ok
            status=varargin{1};
            if status
                status='Pass';
            else
                status='Warn';
            end
            SubTitle=DAStudio.message('Slci:compatibility:IndexPortDimConstraintSubTitle');
            Information=DAStudio.message('Slci:compatibility:IndexPortDimConstraintInfo',aObj.fSupportedDataType);
            StatusText=DAStudio.message(['Slci:compatibility:IndexPortDimConstraint',status],aObj.fSupportedDataType);
            RecAction=DAStudio.message('Slci:compatibility:IndexPortDimConstraintRecAction',...
            aObj.getIncompatiblePortList(),...
            aObj.fSupportedDataType);
        end

    end
end
