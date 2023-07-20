


classdef IndexPortDataTypeConstraint<slci.compatibility.Constraint

    properties(Access=protected)
        fPortKind='';
        fPortNumber=1;
        fIncompatiblePortListStr='';
        fSupportedDataType={};
    end

    methods(Access=protected)

        function out=getPortKind(aObj)
            out=aObj.fPortKind;
        end

        function out=getPortNumber(aObj)
            out=aObj.fPortNumber;
        end

        function out=getIncompatiblePortList(aObj)
            out=aObj.fIncompatiblePortListStr;
        end

        function out=getSupportedDataType(aObj)
            out='';
            numOfSupportedDatatype=numel(aObj.fSupportedDataType);
            for i=1:numOfSupportedDatatype
                out=strcat(out,aObj.fSupportedDataType(i));
                if(i<numOfSupportedDatatype-1)
                    out=strcat(out,{', '});
                elseif(i==numOfSupportedDatatype-1)
                    out=strcat(out,{' or '});
                end
            end
            out=cell2mat(out);
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

        function out=isSupportedDataType(aObj,pHandle)
            port_dt=get_param(pHandle,'CompiledPortDataType');
            out=any(strcmpi(port_dt,aObj.fSupportedDataType));

            if~out&&aObj.ParentBlock().getSupportsEnumsForIndexPortDataType
                out=slci.compatibility.isSupportedEnumClass(port_dt);
            end
        end

        function setSupportedDataType(aObj,aDataType)
            aObj.fSupportedDataType=aDataType;
        end


    end

    methods

        function out=getDescription(aObj)
            out=['Index port data type must be of data type: ',...
            cell2mat(join(aObj.fSupportedDataType))];
        end


        function obj=IndexPortDataTypeConstraint(aPortKind,aPortNumber,varargin)
            obj.setEnum('IndexPortDataType');
            obj.setCompileNeeded(1);
            obj.setFatal(false);

            obj.setPortKind(aPortKind);
            obj.setPortNumber(aPortNumber);

            if nargin==3
                dType=varargin{1};
            else
                if(slcifeature('SlciLevel1Checks')==1)
                    dType={'uint32','int32'};
                else
                    dType={'int32'};
                end
            end

            obj.setSupportedDataType(dType);

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
                    status=~isSupportedDataType(aObj,port_handle);
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
                    'IndexPortDataType',...
                    aObj.ParentBlock().getName(),...
                    aObj.getPortKind(),...
                    aObj.getIncompatiblePortList(),...
                    aObj.getSupportedDataType());
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
            SubTitle=DAStudio.message('Slci:compatibility:IndexPortDataTypeConstraintSubTitle');
            Information=DAStudio.message('Slci:compatibility:IndexPortDataTypeConstraintInfo',aObj.getSupportedDataType());
            StatusText=DAStudio.message(['Slci:compatibility:IndexPortDataTypeConstraint',status],aObj.getSupportedDataType());
            RecAction=DAStudio.message('Slci:compatibility:IndexPortDataTypeConstraintRecAction',...
            aObj.getSupportedDataType());
        end

    end
end
