classdef ValueType

    properties
        DataType='double'
        Min=[]
        Max=[]
        Unit=''
        Complexity='real'
        Dimensions=1
        DimensionsMode='Fixed'
        Description=''
    end

    properties(Hidden,Access=protected)
        be=Simulink.BusElement;
    end

    methods(Access=protected)
        function customValidator(obj,prop,val)

            obj.be.(prop)=val;


            if slfeature('SLValueTypeBusSupport')==0&&...
                isequal(prop,'DataType')&&startsWith(val,'Bus:')
                throwAsCaller(MException(message('Simulink:DataType:ValueTypeDoesNotSupportBusesLocal')));
            end


            if isequal(prop,'DataType')&&startsWith(val,'ValueType:')
                throwAsCaller(MException(message('Simulink:DataType:ValueTypeDoesNotSupportRecursiveValueType')));
            end
        end
    end

    methods
        function obj=ValueType(~)
            obj.DataType=obj.be.DataType;
            obj.Min=obj.be.Min;
            obj.Min=obj.be.Max;
            obj.Unit=obj.be.Unit;
            obj.Complexity=obj.be.Complexity;
            obj.Dimensions=obj.be.Dimensions;
            obj.DimensionsMode=obj.be.DimensionsMode;
            obj.Description=obj.be.Description;
        end

        function obj=set.DataType(obj,val)
            try
                obj.customValidator('DataType',val);
            catch e

                newError=MException(e.identifier,strrep(e.message,'BusElement','ValueType'));
                throwAsCaller(newError);
            end
            obj.DataType=val;
        end

        function dt=get.DataType(obj)
            dt=obj.DataType;
        end

        function obj=set.Min(obj,val)
            setVal=val;

            if~isnumeric(val)
                numericVal=str2num(val);
                if~isempty(numericVal)
                    setVal=numericVal;
                end
            end
            try
                obj.customValidator('Min',setVal);
            catch e
                throwAsCaller(MException('Simulink:DataType:ValueTypeMinValueMustBeFiniteRealDoubleScalar',...
                'Minimum of a Value Type object must be a finite real double scalar value'));
            end
            obj.Min=setVal;
        end

        function min=get.Min(obj)
            min=obj.Min;
        end

        function obj=set.Max(obj,val)
            setVal=val;

            if~isnumeric(val)
                numericVal=str2num(val);
                if~isempty(numericVal)
                    setVal=numericVal;
                end
            end
            try
                obj.customValidator('Max',setVal);
            catch e
                throwAsCaller(MException('Simulink:DataType:ValueTypeMaxValueMustBeFiniteRealDoubleScalar',...
                'Maximum of a Value Type object must be a finite real double scalar value'));
            end
            obj.Max=setVal;
        end

        function max=get.Max(obj)
            max=obj.Max;
        end

        function obj=set.Unit(obj,val)
            try
                obj.customValidator('Unit',val);
            catch e

                newError=MException(e.identifier,strrep(e.message,'BusElement','ValueType'));
                throwAsCaller(newError);
            end
            obj.Unit=val;
        end

        function unit=get.Unit(obj)
            unit=obj.Unit;
        end

        function obj=set.Complexity(obj,val)
            try
                obj.customValidator('Complexity',val);
            catch e

                newError=MException(e.identifier,strrep(e.message,'BusElement','ValueType'));
                throwAsCaller(newError);
            end
            obj.Complexity=val;
        end

        function c=get.Complexity(obj)
            c=obj.Complexity;
        end

        function obj=set.Dimensions(obj,val)
            setVal=val;

            if~isnumeric(val)
                numericVal=str2num(val);
                if~isempty(numericVal)
                    setVal=numericVal;
                end
            end
            obj.customValidator('Dimensions',setVal);
            obj.Dimensions=setVal;
        end

        function dims=get.Dimensions(obj)
            dims=obj.Dimensions;
        end

        function obj=set.DimensionsMode(obj,val)
            try
                obj.customValidator('DimensionsMode',val);
            catch e

                newError=MException(e.identifier,strrep(e.message,'BusElement','ValueType'));
                throwAsCaller(newError);
            end
            obj.DimensionsMode=val;
        end

        function dMode=get.DimensionsMode(obj)
            dMode=obj.DimensionsMode;
        end

        function obj=set.Description(obj,val)
            try
                obj.customValidator('Description',val);
            catch e

                newError=MException(e.identifier,strrep(e.message,'BusElement','ValueType'));
                throwAsCaller(newError);
            end
            obj.Description=val;
        end

        function desc=get.Description(obj)
            desc=obj.Description;
        end
    end


    methods(Static,Hidden)

        function writeContentsForSaveVars(obj,vs)
            vs.writeProperty('Description',obj.Description);
            vs.writeProperty('DataType',obj.DataType);
            vs.writeProperty('Min',obj.Min);
            vs.writeProperty('Max',obj.Max);
            vs.writeProperty('Unit',obj.Unit);
            vs.writeProperty('DimensionsMode',obj.DimensionsMode);
            vs.writeProperty('Complexity',obj.Complexity);
            vs.writeProperty('Dimensions',obj.Dimensions);
        end
    end

    methods(Sealed,Hidden)

        function ret=getAutoCompleteData(h,tag,partialText)
            ret={};
            if contains(tag,'Unit')
                ret=Simulink.UnitPrmWidget.getUnitSuggestions(partialText);
            end
        end
    end


    methods

        function fObj=getForwardedObject(h)
            fObj=h;
        end


        function propValues=getPropAllowedValues(h,propName)
            propValues={};
            if isempty(h.be)
                return;
            end


            propValues=h.be.getPropAllowedValues(propName);
        end


        function propDT=getPropDataType(h,propName)
            propDT={};
            if isempty(h.be)
                return;
            end


            propDT=h.be.getPropDataType(propName);
        end


        function propValue=getPropValue(h,propName)
            propValue={};
            if h.isValidProperty(propName)
                propValue=h.(propName);





                if strcmp(propName,'Dimensions')
                    propValue=mat2str(propValue);
                    return;
                end
                if any(strcmp(propName,{'Min','Max'}))
                    doublePrecision=16;
                    propValue=mat2str(propValue,doublePrecision);
                    return;
                end
            end
        end


        function result=isEditableProperty(h,propName)
            result=h.be.isEditableProperty(propName);
        end


        function result=isReadonlyProperty(h,propName)
            result=h.be.isReadonlyProperty(propName);
        end


        function result=isValidProperty(h,propName)
            result=false;


            if~isempty(find(strcmp(h.be.getProperties,propName),1))
                result=true;
            end


            if result&&(strcmpi(propName,'SampleTime')==1||...
                strcmpi(propName,'Name')==1)
                result=false;
            end
        end


        function fileName=getDisplayIcon(~)
            fileName=fullfile('toolbox','shared','dastudio','resources','SimulinkSignal.png');
        end


        function dlgstruct=getDialogSchema(h,name)
            dlgstruct=valueTypeGetDialogSchema(h,name);
        end
    end

    methods(Hidden)
        function openvar(objectName,~)
            if slfeature('TypeEditorStudio')>0
                typeeditor('Create',objectName);
            else
                valueTypeObject=evalin('base',objectName);


















                DAStudio.Dialog(valueTypeObject,objectName,'DLG_STANDALONE');
            end
        end
    end
end
