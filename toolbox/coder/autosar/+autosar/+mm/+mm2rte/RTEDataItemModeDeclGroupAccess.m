classdef RTEDataItemModeDeclGroupAccess<handle




    properties(Access='private')
        PortName;
        ElementName;
        TypeInfo;
        M3iAccess;
    end

    methods(Access='public')
        function this=RTEDataItemModeDeclGroupAccess(portName,...
            ElementName,typeInfo,m3iAccess)
            this.PortName=portName;
            this.ElementName=ElementName;
            this.TypeInfo=typeInfo;
            this.M3iAccess=m3iAccess;
        end

        function accessFcnName=getAccessFcnName(this)


            if isa(this.M3iAccess,...
                'Simulink.metamodel.arplatform.behavior.ModeSwitch')

                accessFcnName=sprintf('Rte_Switch_%s_%s',...
                this.PortName,...
                this.ElementName);

            elseif isa(this.M3iAccess,...
                'Simulink.metamodel.arplatform.behavior.ModeAccess')

                accessFcnName=sprintf('Rte_Mode_%s_%s',...
                this.PortName,...
                this.ElementName);

            else
                assert(false,'Unexpected m3iAccess %s.',this.M3iAccess);
            end
        end

        function rhsString=getAccessFcnRHSArgs(this)

            if isa(this.M3iAccess,...
                'Simulink.metamodel.arplatform.behavior.ModeSwitch')

                rhsString=sprintf('%s u',this.TypeInfo.ImpTypeName);

            elseif isa(this.M3iAccess,...
                'Simulink.metamodel.arplatform.behavior.ModeAccess')

                rhsString=this.TypeInfo.RteInstanceArg;

            else

                assert(false,'Unexpected m3iAccess %s.',this.M3iAccess);

            end
        end

        function lhsString=getAccessFcnLHSArg(this)

            if isa(this.M3iAccess,'Simulink.metamodel.arplatform.behavior.ModeSwitch')

                lhsString='Std_ReturnType';

            elseif isa(this.M3iAccess,'Simulink.metamodel.arplatform.behavior.ModeAccess')

                lhsString=this.TypeInfo.ImpTypeName;

            else

                assert(false,'Unexpected m3iAccess %s.',this.M3iAccess);

            end

        end
    end
end


