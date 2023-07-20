function propValue=getPropValues(this,propName)




    propValue='';
    switch lower(propName)
    case 'name'
        propValue=this.Name;
    case{'datatype','type'}
        propValue=this.DataType;
    case 'dimensions'
        propValue=mat2str(this.Dimensions);
    case 'sampletime'
        propValue=mat2str(this.SampleTime);
    case 'complexity'
        propValue=this.Complexity;
    case 'samplingmode'
        propValue=this.SamplingMode;
    case 'dimensionsmode'
        propValue=this.DimensionsMode;
    case 'min'
        doublePrecision=16;
        propValue=mat2str(this.Min,doublePrecision);
    case 'max'
        doublePrecision=16;
        propValue=mat2str(this.Max,doublePrecision);
    case 'unit'
        propValue=this.Unit;
    case 'docunits'
        propValue=this.DocUnits;
    case 'description'
        propValue=this.Description;
    end

    if slfeature('SLDataDictionarySetUserData')>0&&...
        ~isempty(this.TargetUserData)
        [token,rem]=strtok(propName,'.');
        if strcmp(token,'TargetUserData')
            customPropName=rem(2:end);
            propValue=this.TargetUserData.getPropValue(customPropName);
            return;
        end
    end


