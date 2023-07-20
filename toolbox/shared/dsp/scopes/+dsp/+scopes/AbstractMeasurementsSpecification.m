classdef(Hidden,Abstract)AbstractMeasurementsSpecification<handle&...
    matlab.mixin.SetGet&...
    matlab.mixin.CustomDisplay




    properties(AbortSet,Dependent,SetObservable)


        Enable;
    end

    properties(Transient,Hidden)

        Application;

        hVisual;
    end

    properties(Hidden,Dependent)
        Line;
        TargetChannels;
        TargetLines;
        Results;
    end

    properties(Access=protected)

        pMeasurementObject;

        pMeasurementLocalObject;


        pMeasurementUpdatedListener;
    end

    properties(Access=protected,Abstract=true)

        MeasurerName;
    end

    methods
        function set.Enable(obj,val)
            validateattributes(val,{'logical'},{'scalar'},'','Enable');
            if~isempty(obj.hVisual)
                t=obj.pMeasurementObject;
                t.Enable=val;
                if isvalid(obj)
                    allMeasurementsMap=getExtension(obj.Application.ExtDriver,'Tools:Measurements');
                    allMeasurementsMap.MeasurementMap(obj.MeasurerName)=obj;
                end
            else
                obj.pMeasurementLocalObject.Enable=val;
            end
            if isvalid(obj)
                eventName=getMeasurementUpdatedEventName(obj);
                notify(obj,eventName);
            end
        end
        function val=get.Enable(obj)
            if~isempty(obj.hVisual)
                val=obj.pMeasurementObject.Enable;
            else
                val=obj.pMeasurementLocalObject.Enable;
            end
        end

        function val=get.Results(obj)
            val=obj.pMeasurementObject.Measurement;
        end

        function set.Line(obj,val)
            obj.pMeasurementObject.Line=val;
        end
        function val=get.Line(obj)
            val=obj.pMeasurementObject.Line;
        end

        function set.TargetChannels(obj,val)
            obj.pMeasurementObject.TargetChannels=val;
        end
        function val=get.TargetChannels(obj)
            val=obj.pMeasurementObject.TargetChannels;
        end

        function set.TargetLines(obj,val)
            obj.pMeasurementObject.TargetLines=val;
        end
        function val=get.TargetLines(obj)
            val=obj.pMeasurementObject.TargetLines;
        end

        function redoMeasurement(obj,updateReadout,fullUpdate)
            obj.pMeasurementObject.redoMeasurement(updateReadout,fullUpdate);
        end

        function updateDialogColors(obj,fg,bg)
            obj.pMeasurementObject.updateDialogColors(fg,bg);
        end

        function clearMeasurement(obj)
            obj.pMeasurementObject.clearMeasurement();
        end
    end

    methods(Hidden)

        function propList=getValidPropertyList(obj)
            propList=getPropertyGroups(obj);
        end

        function[flag,props,vals]=getMeasurementsChangedProps(obj)
            defaultMeasureSpec=getDefaultMeasurementsSpec(obj);
            flag=false;
            props={};
            vals={};
            ctr=1;
            validProps=getValidPropertyList(obj);
            validProps=validProps.PropertyList;

            for idx=1:numel(validProps)

                if isnumeric(defaultMeasureSpec.(validProps{idx}))

                    if defaultMeasureSpec.(validProps{idx})~=obj.(validProps{idx})
                        flag=true;
                        props{ctr}=validProps{idx};%#ok<AGROW>
                        vals{ctr}=mat2str(obj.(validProps{idx}));%#ok<AGROW>
                        ctr=ctr+1;
                    end
                elseif islogical(defaultMeasureSpec.(validProps{idx}))

                    if xor(defaultMeasureSpec.(validProps{idx}),obj.(validProps{idx}))
                        flag=true;
                        props{ctr}=validProps{idx};%#ok<AGROW>
                        propVal=obj.(validProps{idx});
                        if propVal
                            vals{ctr}='true';%#ok<AGROW>
                        else
                            vals{ctr}='false';%#ok<AGROW>
                        end
                        ctr=ctr+1;
                    end

                else

                    if~strcmpi(defaultMeasureSpec.(validProps{idx}),obj.(validProps{idx}))
                        flag=true;
                        props{ctr}=validProps{idx};%#ok<AGROW>
                        vals{ctr}=strcat('''',obj.(validProps{idx}),'''');%#ok<AGROW>
                        ctr=ctr+1;
                    end
                end
            end
        end

        function name=getMeasurementName(~)%#ok<STOUT>

        end

        function name=getMeasurementObjectName(~)%#ok<STOUT>

        end
    end

    methods(Access=private)

        function delete(~)


        end
    end

    methods(Access=protected)
        function[value,ind]=validateEnum(~,value,propName,validValues)
            value=convertStringsToChars(value);
            validateattributes(value,{'char'},{},'',propName);
            ind=find(ismember(lower(validValues),lower(value))==1,1);
            if isempty(ind)
                error(message('dspshared:SpectrumAnalyzer:invalidEnumValue',value,propName));
            end
            value=validValues{ind};
        end

        function setupMeasurementObject(~,~)

        end

        function spec=getDefaultMeasurementsSpec(~)%#ok<STOUT>

        end

        function flag=isSimulinkScope(obj)
            hSource=obj.hVisual.Application.DataSource;
            if isempty(hSource)
                flag=true;
            else
                flag=strcmpi(hSource.Type,'Simulink');
            end
        end
    end

    methods(Access=protected,Abstract=true)
        eventName=getMeasurementUpdatedEventName(obj);
    end
end

