function props=getPossibleProperties(this)




    props={...
'Name'
'Priority'
'SaturationMode'
'RoundingMode'...
    };

    props=[props;conceptualArgProps(this)];

    if~strcmp(class(this.object),'RTW.TflCustomization')
        props=[props;implementationArgProps(this)];
    else
        props=[props;'SupportNonFinite'];
    end



    function props=conceptualArgProps(this)
        props={};

        props=[props;'Out1Type'];
        props=[props;'Out2Type'];
        props=[props;'In1Type'];
        props=[props;'In2Type'];

        if~isempty(this.object)
            if~isempty(this.object.ConceptualArgs)
                for i=3:length(this.object.ConceptualArgs)-1
                    arg=['In',num2str(i),'Type'];
                    props=[props;arg];%#ok
                end
            end
        end


        function props=implementationArgProps(this)
            props={};

            props=[props;'Implementation'];
            props=[props;'ImplReturnType'];
            props=[props;'ImplIn1Type'];
            props=[props;'ImplIn2Type'];
            props=[props;'ImplIn3Type'];
            if~isempty(this.object)
                for i=3:length(this.object.Implementation.Arguments)
                    arg=['ImplIn',num2str(i),'Type'];
                    props=[props;arg];%#ok
                end
            end