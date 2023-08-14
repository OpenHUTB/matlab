function propValue=getPropValue(this,propName)



    switch propName
    case{'name','Tfldesigner_Name'}
        propValue=this.Name;
    case{'Tfldesigner_Description'}
        if strcmpi(this.Type,'TflRegistry')
            propValue=this.object.get(propName);
        else
            propValue=this.Description;
        end
    case{'Version','Tfldesigner_Version'}
        if~strcmpi(this.Type,'TflRegistry')
            if~isempty(this.object)
                propValue=this.object.Version;
            else
                propValue='0.0';
            end
        else
            propValue='';
        end
    otherwise
        propValue='';
    end