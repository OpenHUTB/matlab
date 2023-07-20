function isEditable=isEditableProperty(this,propName)





    if isempty(this.object.ConceptualArgs)
        isEditable=false;
        return;
    end

    if length(propName)>1&&strcmp(propName(1:2),'In')
        isEditable=conceptualArgEdit(this,propName);
    elseif length(propName)>6&&strcmp(propName(1:6),'ImplIn')
        isEditable=implementationArgEdit(this,propName);
    else
        switch propName
        case{'Name','NumIn'}
            isEditable=false;
        case{'ImplReturnType'}
            isEditable=false;
            if~strcmp(this.EntryType,'RTW.TflCustomization')&&...
                ~isempty(this.object.Implementation.Return)
                isEditable=true;
            end
        case{'Implementation'}
            isEditable=false;
            if~strcmp(this.EntryType,'RTW.TflCustomization')
                isEditable=true;
            end
        otherwise
            isEditable=true;
        end
    end


    function isEditable=conceptualArgEdit(this,propName)
        endIndex=strfind(propName,'Type')-1;
        inputIndex=str2double(propName(3:endIndex));
        isEditable=false;
        try
            if~isempty(this.object.ConceptualArgs)
                if inputIndex<=length(this.object.ConceptualArgs)-1
                    isEditable=true;
                end
            end
        catch %#ok<CTCH>
            isEditable=false;
        end


        function isEditable=implementationArgEdit(this,propName)
            endIndex=strfind(propName,'Type')-1;
            inputIndex=str2double(propName(7:endIndex));
            isEditable=false;
            try
                if~strcmp(this.EntryType,'RTW.TflCustomization')&&...
                    ~isempty(this.object.Implementation.Arguments)
                    if inputIndex<=length(this.object.Implementation.Arguments)
                        isEditable=true;
                    end
                end
            catch %#ok<CTCH>
                isEditable=false;
            end
