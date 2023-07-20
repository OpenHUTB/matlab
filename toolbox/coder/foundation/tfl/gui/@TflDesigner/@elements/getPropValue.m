function propValue=getPropValue(this,propName)



    if isempty(propName)
        propValue='';
        return;
    end

    if length(propName)>1&&strcmp(propName(1:2),'In')
        propValue=getConceptualArgValue(this,propName);
    elseif length(propName)>6&&strcmp(propName(1:6),'ImplIn')
        propValue=getImplementationArgValue(this,propName);
    else
        switch propName
        case{'Name','name'}
            if strcmpi(this.Type,'TflEntry')
                if~isempty(this.conceptualargs)
                    propValue=this.getEnumString(this.object.Key);
                else
                    propValue=this.Name;
                end
            else
                propValue=this.Name;
            end
        case{'Implementation','ImplementationName'}
            propValue='';
            if~isa(this.object,'RTW.TflCustomization')&&...
                ~isempty(this.object.Implementation)
                propValue=this.object.Implementation.Name;
            end
        case{'NumIn'}
            propValue='';
            if~isempty(this.object.ConceptualArgs)
                names={this.object.ConceptualArgs(:).Name};
                len=find(strcmp(names,'u1'),1);
                if~isempty(len)
                    propValue=num2str(length(this.object.ConceptualArgs)-(len-1));
                else
                    propValue=num2str(0);
                end
            end
        case{'Out1Type','Out2Type'}
            try
                endIndex=strfind(propName,'Type')-1;
                index=propName(4:endIndex);
                if~isempty(this.object.ConceptualArgs)
                    argnames={this.object.ConceptualArgs(:).Name};
                    index=find(strcmp(argnames,['y',index]),1);
                    if~isempty(index)
                        propValue=this.object.ConceptualArgs(index).toString;
                        if isempty(propValue)
                            propValue='embedded';
                        end
                    else
                        propValue='';
                    end
                else
                    propValue='';
                end
            catch %#ok<CTCH>
                propValue='';
            end
        case{'ImplReturnType'}
            propValue='';
            if~isa(this.object,'RTW.TflCustomization')&&...
                ~isempty(this.object.Implementation.Return)
                propValue=this.object.Implementation.Return.toString;
            end
        case{'Namespace'}
            propValue='';
            if~isa(this.object,'RTW.TflCustomization')&&...
                strcmpi(class(this.object.Implementation),'RTW.CPPImplementation')
                propValue=this.object.getNameSpace;
            end
        case{'SaturationMode','RoundingMode'}
            propValue=this.getEnumString(this.object.get(propName));
        case{'SupportNonFinite'}
            propValue='';
            if strcmp(this.EntryType,'RTW.TflCustomization')
                propValue=this.getEnumString(this.object.SupportNonFinite);
            end
        case{'ArrayLayout'}
            propValue=this.getEnumString(this.object.ArrayLayout);
        otherwise
            try
                propValue='';
                if isprop(this.object,propName)
                    propValue=this.object.get(propName);
                    if isnumeric(propValue)||islogical(propValue)
                        propValue=num2str(propValue);
                    end
                end
            catch ME %#ok
                propValue='';
            end
        end
    end



    function propValue=getConceptualArgValue(this,propName)
        propValue='';
        if isempty(this.object.ConceptualArgs)
            return;
        end
        endIndex=strfind(propName,'Type')-1;
        inputIndex=propName(3:endIndex);
        try
            cargs=this.object.ConceptualArgs;
            names={cargs(:).Name};
            argindex=find(strcmp(names,['u',inputIndex]),1);
            if~isempty(argindex)
                propValue=cargs(argindex).toString;
                if isempty(propValue)
                    propValue='embedded';
                end
            end
        catch %#ok<CTCH>
            propValue='';
        end


        function propValue=getImplementationArgValue(this,propName)
            endIndex=strfind(propName,'Type')-1;
            inputIndex=str2double(propName(7:endIndex));

            iargs=this.object.Implementation.Arguments;
            try
                if~strcmp(this.EntryType,'RTW.TflCustomization')&&...
                    ~isempty(iargs)&&length(iargs)>=inputIndex
                    propValue=iargs(inputIndex).toString;
                    if isempty(propValue)
                        propValue='embedded';
                    end
                else
                    propValue='';
                end
            catch %#ok<CTCH>
                propValue='';
            end




