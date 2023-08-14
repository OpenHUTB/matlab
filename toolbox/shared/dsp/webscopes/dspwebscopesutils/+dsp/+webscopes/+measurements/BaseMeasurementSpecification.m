classdef(Abstract)BaseMeasurementSpecification<handle&matlab.mixin.SetGet





    properties(AbortSet)
        Enabled=false;
    end

    properties(Transient,Hidden)

        Specification;

        Configuration;

        ClientID;
    end



    methods

        function this=BaseMeasurementSpecification(hSpec)
            if nargin>0
                this.Specification=hSpec;
            end
        end

        function flag=isInactiveProperty(this,propName)%#ok<INUSD>
            flag=false;
        end


        function setPropertyValue(this,propName,propValue)
            if~isequal(this.(propName),propValue)


                this.(propName)=propValue;
                source=getMeasurementPropertyName(this);





                propValue=preprocessPropertyValue(this,propName,propValue);
                if~isempty(this.Specification)


                    hMessageHandler=this.Specification.MessageHandler;
                    hMessageHandler.GraphicalSettingsStale=true;
                    hMessageHandler.publishPropertyValue('MeasurementChanged',source,propName,propValue);


                    hMessageHandler.notify('PropertyChanged');
                else


                    action=['set',source,'ParameterValue'];
                    msg=struct('parameter',propName,'value',propValue);
                    dsp.webscopes.internal.BaseWebScope.publishMessage(this.ClientID,action,msg);
                end
            end
        end


        function propValue=getPropertyValue(this,propName)
            propValue=this.(propName);
        end


        function settings=getSettings(this)
            settings=struct('Enabled',this.Enabled);
        end


        function setSettings(this,S)
            propNames=fields(S);
            for idx=1:numel(propNames)
                propName=propNames{idx};
                if isprop(this,propName)
                    propValue=S.(propName);
                    if ischar(propValue)&&any(strcmpi(propValue,{'Inf','-Inf'}))

                        propValue=str2double(propValue);
                    end
                    propValue=propValue(:).';
                    this.(propName)=propValue;
                end
            end
        end


        function S=toStruct(this)
            S=getSettings(this);
        end


        function fromStruct(this,S)
            setSettings(this,S);
        end

        function validProps=getValidDisplayProperties(this,props)
            validProps={};
            for idx=1:numel(props)
                if~isInactiveProperty(this,props{idx})
                    validProps=[validProps,props{idx}];%#ok<AGROW>
                end
            end
        end

        function propValue=preprocessPropertyValue(~,propName,value)%#ok<INUSL> 
            propValue=value;
        end

        function flag=isEnabled(this)
            flag=this.Enabled;
        end
    end



    methods(Abstract,Hidden)
        name=getMeasurementPropertyName;
        name=getMeasurementName;
    end
end
