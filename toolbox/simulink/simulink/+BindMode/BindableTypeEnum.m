

classdef BindableTypeEnum
    enumeration
        NONE,SLSIGNAL,SLPARAMETER,SLPORT,VARIABLE,SFCHART,SFSTATE,SFDATA,EXPRESSION,DSM,SIMSCAPEVARIABLE,BUSOBJECT,BUSLEAFSIGNAL;
    end

    methods(Static)
        function enumType=getEnumTypeFromChar(bindableType)
            bindableType=lower(bindableType);
            enumType=BindMode.BindableTypeEnum.NONE;
            if(strcmp(bindableType,'slsignal')||strcmp(bindableType,'signal'))
                enumType=BindMode.BindableTypeEnum.SLSIGNAL;
            elseif(strcmp(bindableType,'slparameter')||strcmp(bindableType,'parameter'))
                enumType=BindMode.BindableTypeEnum.SLPARAMETER;
            elseif(strcmp(bindableType,'slport')||strcmp(bindableType,'port'))
                enumType=BindMode.BindableTypeEnum.SLPORT;
            elseif(strcmp(bindableType,'variable'))
                enumType=BindMode.BindableTypeEnum.VARIABLE;
            elseif(strcmp(bindableType,'sfchart'))
                enumType=BindMode.BindableTypeEnum.SFCHART;
            elseif(strcmp(bindableType,'sfstate'))
                enumType=BindMode.BindableTypeEnum.SFSTATE;
            elseif(strcmp(bindableType,'sfdata'))
                enumType=BindMode.BindableTypeEnum.SFDATA;
            elseif(strcmp(bindableType,'expression'))
                enumType=BindMode.BindableTypeEnum.EXPRESSION;
            elseif(strcmp(bindableType,'dsm'))
                enumType=BindMode.BindableTypeEnum.DSM;
            elseif(strcmp(bindableType,'simscapevariable'))
                enumType=BindMode.BindableTypeEnum.SIMSCAPEVARIABLE;
            elseif(strcmp(bindableType,'busobject'))
                enumType=BindMode.BindableTypeEnum.BUSOBJECT;
            elseif(strcmp(bindableType,'busleafsignal'))
                enumType=BindMode.BindableTypeEnum.BUSLEAFSIGNAL;
            end
        end
    end
end
