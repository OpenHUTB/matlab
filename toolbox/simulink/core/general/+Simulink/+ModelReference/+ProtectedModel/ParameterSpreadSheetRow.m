



classdef ParameterSpreadSheetRow<handle
    properties

m_DlgSource
        m_ParamName;
        m_Tunable;
        m_Source;

    end
    properties(Access=private,Constant=true)
        paramNameColumn=DAStudio.message('Simulink:protectedModel:ProtectedModelParameterNameColumn');
        sourceColumn=DAStudio.message('Simulink:protectedModel:ProtectedModelParameterSourceColumn');
        tunableColumn=DAStudio.message('Simulink:protectedModel:ProtectedModelParameterTunableColumn');
    end
    methods
        function obj=ParameterSpreadSheetRow(DlgSource,ParamName,Tunable,Source)

            obj.m_DlgSource=DlgSource;
            obj.m_ParamName=ParamName;
            obj.m_Tunable=Tunable;
            obj.m_Source=Source;
        end

        function label=getDisplayLabel(obj)
            label=obj.m_ParamName;
        end

        function iconFile=getDisplayIcon(~)
            iconFile='';
        end

        function propValue=getPropValue(obj,propName)
            switch propName
            case obj.paramNameColumn
                propValue=obj.m_ParamName;
            case obj.tunableColumn
                if(~obj.m_Tunable||obj.m_Tunable=='0')
                    propValue='0';
                else
                    propValue='1';
                end
            case obj.sourceColumn
                propValue=obj.m_Source;
            otherwise
                propValue='';
            end
        end

        function setPropValue(this,aPropName,aPropValue)

            switch(aPropName)
            case{this.tunableColumn}
                this.m_Tunable=aPropValue;
            otherwise

            end

        end


        function[aPropType]=getPropDataType(this,aPropName)
            try
                switch(aPropName)
                case{this.tunableColumn}
                    aPropType='bool';
                otherwise
                    aPropType='string';
                end
            catch me
                this.reportError(this,me);
            end
        end


        function isValid=isValidProperty(obj,propName)
            switch propName
            case{obj.paramNameColumn,obj.sourceColumn,obj.tunableColumn}
                isValid=true;
            otherwise
                isValid=false;

            end
        end
        function isReadOnly=isReadonlyProperty(obj,propName)
            switch propName
            case{obj.tunableColumn}
                isReadOnly=false;
            otherwise
                isReadOnly=true;
            end
        end
    end
    methods(Access=private)
        function isTunable=getIsTunable(this)
            isTunable=(isequal(this.m_Tunable,'on')||...
            isequal(this.m_Tunable,'1'));
        end
    end
end
