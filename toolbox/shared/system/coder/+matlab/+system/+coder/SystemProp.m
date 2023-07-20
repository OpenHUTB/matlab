classdef SystemProp<handle



%#codegen
%#ok<*EMCLS>

    properties
tunablePropertyChanged
    end




    methods
        function obj=SystemProp(varargin)
            coder.internal.allowHalfInputs;
            coder.allowpcode('plain');
        end
    end

    methods(Hidden)
        function[hasTunableProps,hasTunablePropsProcessing]=initializeTunablePropertyChanged(obj)
            coder.extrinsic('getNumPublicTunableProps');
            coder.extrinsic('hasProcessPropertiesImpl');
            num=coder.internal.const(matlab.system.coder.SystemProp.getNumPublicTunableProps(class(obj)));
            hasTunablePropsProcessing=...
            coder.internal.const(matlab.system.coder.SystemProp.hasProcessPropertiesImpl(class(obj)));
            obj.tunablePropertyChanged=false(1,num);
            hasTunableProps=num>0;
        end

        function clearTunablePropertyChanged(obj)
            coder.inline('always');
            obj.tunablePropertyChanged(:)=false;
        end
    end




    methods
        function set(obj,varargin)

            eml_invariant(numel(obj)==1,...
            eml_message('MATLAB:system:nonScalarSet'));

            eml_invariant(nargin==3&&~isstruct(varargin{1}),...
            eml_message('MATLAB:system:unsupportedSetCodegen'));


            matlab.system.setProp(obj,varargin{1},varargin{2});
        end
        function out=get(obj,prop)













            eml_invariant(numel(obj)==1,...
            eml_message('MATLAB:system:nonScalarGet'));

            eml_invariant(nargin==2,...
            eml_message('MATLAB:system:getOnlyTakesTwoInputsCodegen'));

            out=obj.(prop);
        end
    end



    methods(Static)
        function num=createVersionNumber(bMajor)

            v=version();
            ndx=find(v=='.');
            if strcmp(bMajor,'major')
                num=uint16(str2double(v(1:ndx(1)-1)));
            else
                num=uint16(str2double(v(ndx(1)+1:ndx(2)-1)))*256+...
                uint16(str2double(v(ndx(2)+1:ndx(3)-1)));
            end
        end



    end




    methods(Access=protected)
        function setProperties(obj,narg,varargin)






















            eml_prefer_const(narg);
            eml_prefer_const(varargin);


            if(nargin>1)&&(narg>0)&&~isempty(varargin)



                if matlab.system.isSystemObject(varargin{1})
                    matlab.system.internal.error(...
                    'MATLAB:system:invalidConstructorFirstArgument');
                end
                if narg>length(varargin)
                    matlab.system.internal.error(...
                    'MATLAB:system:invalidSetPropertiesSyntax');
                end

                matlab.system.coder.ProcessConstructorArguments.do(obj,narg,varargin{:});
            end
        end

        function validateCustomDataType(~,~,~,~)
        end

        function flag=isChangedProperty(obj,prop)
            coder.extrinsic('getPropertyIndex');
            if ischar(prop)
                flag=false;%#ok<NASGU>
                idx=0;%#ok<NASGU>
                idx=coder.internal.const(matlab.system.coder.SystemProp.getPropertyIndex(class(obj),prop));
                eml_invariant(idx>0,...
                eml_message('MATLAB:system:invalidIsChangedPropertyParam',prop));
                flag=obj.tunablePropertyChanged(idx);
            else
                flag=false(size(prop));
                for n=coder.unroll(1:numel(prop))
                    if iscell(prop)
                        propN=prop{n};
                    else
                        propN=char(prop(n));
                    end
                    idx=coder.internal.const(matlab.system.coder.SystemProp.getPropertyIndex(class(obj),propN));
                    eml_invariant(idx>0,...
                    eml_message('MATLAB:system:invalidIsChangedPropertyParam',propN));
                    flag(n)=obj.tunablePropertyChanged(idx);
                end
            end
        end
    end




    methods(Access=public,Static)


        function idx=getPropertyIndex(classname,prop)
            mc=meta.class.fromName(classname);
            props=mc.PropertyList;
            idx=0;
            for i=1:length(props)
                mp=props(i);
                if matlab.system.coder.SystemProp.isTunablePublicSetProp(mp)
                    idx=idx+1;
                    if strcmp(mp.Name,prop)
                        return
                    end
                end
            end
            idx=-1;
        end
        function num=getNumPublicTunableProps(classname)
            mc=meta.class.fromName(classname);
            props=mc.PropertyList;
            num=0;
            for i=1:length(props)
                mp=props(i);
                if matlab.system.coder.SystemProp.isTunablePublicSetProp(mp)
                    num=num+1;
                end
            end
        end

        function YES=hasProcessPropertiesImpl(classname)
            mc=meta.class.fromName(classname);
            YES=false;
            wrappedClassName=matlab.system.coder.getWrappedSFunObjectName.do(classname);
            if~isempty(wrappedClassName)

                return;
            end
            methods={'processTunedPropertiesImpl','validatePropertiesImpl'};
            for ii=1:2
                vpImpl=findobj(mc.MethodList,'Name',methods{ii});
                if~strcmp(vpImpl.DefiningClass.Name,'matlab.system.SystemImpl')
                    YES=true;
                    return;
                end
            end
        end

        function flag=isTunablePublicSetProp(mp)
            flag=~iscell(mp.SetAccess)&&strcmp(mp.SetAccess,'public')&&...
            ~(isa(mp,'matlab.system.CustomMetaProp')&&(mp.Nontunable||mp.DiscreteState||mp.ContinuousState));
        end

        function flag=isNontunableProp(className,propName)
            mc=meta.class.fromName(className);
            p=findobj(mc.PropertyList,'Name',propName);
            flag=p.Nontunable;
        end
    end

    methods(Static)

        function kind=matlabCodegenSetPropKind(propName,classDeclaredIn,coderTarget)






            if(strcmp(classDeclaredIn,'coder.internal.matlabCodegenHandle'))


                kind=3;
                return;
            end

            propType=matlab.system.getPropertyTypeForCodegen(classDeclaredIn,propName);

            if strcmp(propType,'Logical')||strcmp(propType,'StringSet')||strcmp(propType,'CustomizedEnumeration')

                kind=3;
                return;
            end

            stateType=matlab.system.getStateTypeForCodegen(classDeclaredIn,propName);

            if strcmp(propType,'DataTypeSet')||strcmp(propType,'PositiveInteger')||...
                strcmp(stateType,'DiscreteState')||strcmp(stateType,'ContinuousState')

                kind=2;
                return;
            end

            if matlab.system.isTunablePropForCodegen(classDeclaredIn,propName)





                if strcmp(coderTarget,'hdl')

                    verifyKind=0;
                else
                    verifyKind=1;
                end
                kind=verifyKind;
                return;
            end

            kind=0;
        end

        function matlabCodegenNotifyAnyProp(obj,propName,classDeclaredIn,~)
            coder.extrinsic('getPropertyIndex');
            if~strcmp(coder.target,'hdl')
                if eml_const(feval('matlab.system.isTunablePropForCodegen',classDeclaredIn,propName))...
                    &&obj.isLockedAndNotReleased()
                    obj.TunablePropsChanged=true;
                    idx=0;%#ok<NASGU>
                    idx=coder.internal.const(matlab.system.coder.SystemProp.getPropertyIndex(class(obj),propName));
                    if idx>0
                        obj.tunablePropertyChanged(idx)=true;
                    end
                end
            end
        end

        function matlabCodegenValidateAnyProp(obj,propName,value,classDeclaredIn,classCalledFrom)

            coder.extrinsic('getPropertyIndex');
            coder.extrinsic('isSubClassOf');

            stateType=eml_const(feval(...
            'matlab.system.getStateTypeForCodegen',classDeclaredIn,propName));
            if~coder.internal.const(strcmp(stateType,'NotState'))
                coder.internal.assert(~isempty(classCalledFrom)&&coder.internal.const(...
                matlab.system.coder.SystemProp.isSubClassOf(...
                classCalledFrom,classDeclaredIn)),...
                'MATLAB:system:stateInvalidPublicSet',propName);
            end
            switch stateType
            case 'DiscreteState'


                validDiscValue=...
                (isnumeric(value)||...
                islogical(value)||...
                isa(value,'embedded.fi'))&&...
                ~issparse(value);
                coder.internal.assert(validDiscValue,'MATLAB:system:unsupportedStateValueDiscrete');

                if isa(value,'embedded.fi')
                    ntValue=numerictype(value);
                    validNTValue=(ntValue.SlopeAdjustmentFactor==1)&&...
                    (ntValue.Bias==0);
                    coder.internal.assert(validNTValue,'MATLAB:system:unsupportedFixptDataTypeStateCodeGen');
                end
            case 'ContinuousState'

                validContValue=isa(value,'double')&&isreal(value)&&...
                isvector(value)&&~issparse(value);
                coder.internal.assert(validContValue,'MATLAB:system:unsupportedStateValueContinuous');
            otherwise

            end

            propType=eml_const(feval(...
            'matlab.system.getPropertyTypeForCodegen',classDeclaredIn,propName));
            switch propType
            case 'StringSet'
                coder.internal.assert(ischar(value)||isstring(value),...
                'MATLAB:system:StringSet:InvalidAssignedType',propName);
                enumSet=eml_const(feval(...
                'matlab.system.getStringSetForCodegen',classDeclaredIn,propName));

                if eml_is_const(value)

                    coder.internal.assert(strlength(value)<=size(enumSet,2),...
                    'MATLAB:system:invalidSetPropertyValueConst',value,propName);
                else
                    coder.internal.assert(strlength(value)<=size(enumSet,2),...
                    'MATLAB:system:invalidSetPropertyValue',propName);
                end
                validValue=false;
                valueWithSpace=[char(value),repmat(' ',1,size(enumSet,2)-strlength(value))];
                for i=coder.unroll(1:size(enumSet,1))
                    if strcmpi(valueWithSpace,enumSet(i,:))
                        validValue=true;
                        break;
                    end
                end
                if eml_is_const(value)

                    coder.internal.assert(validValue,...
                    'MATLAB:system:invalidSetPropertyValueConst',value,propName);
                else
                    coder.internal.assert(validValue,...
                    'MATLAB:system:invalidSetPropertyValue',propName);
                end
            case 'DataTypeSet'
                coder.internal.assert(ischar(value)||isstring(value)||isa(value,'embedded.numerictype'),...
                'MATLAB:system:invalidDataTypeSetPropertyType',propName);
                if ischar(value)||isstring(value)
                    enumSet=eml_const(feval(...
                    'matlab.system.getStringSetForCodegen',classDeclaredIn,propName));

                    if eml_is_const(value)

                        coder.internal.assert(strlength(value)<=size(enumSet,2),...
                        'MATLAB:system:invalidSetPropertyValueConst',value,propName);
                    else
                        coder.internal.assert(strlength(value)<=size(enumSet,2),...
                        'MATLAB:system:invalidSetPropertyValue',propName);
                    end
                    validValue=false;
                    valueWithSpace=[char(value),repmat(' ',1,size(enumSet,2)-strlength(value))];
                    for i=coder.unroll(1:size(enumSet,1))
                        if strcmp(valueWithSpace,enumSet(i,:))
                            validValue=true;
                            break;
                        end
                    end
                    if eml_is_const(value)

                        coder.internal.assert(validValue,...
                        'MATLAB:system:invalidSetPropertyValueConst',value,propName);
                    else
                        coder.internal.assert(validValue,...
                        'MATLAB:system:invalidSetPropertyValue',propName);
                    end
                end
            case 'Logical'
                coder.inline('always');
                validValue=isscalar(value)&&isreal(value)&&...
                (islogical(value)||isnumeric(value))&&~isnan(value)...
                &&~isinf(value);
                coder.internal.assert(validValue,'MATLAB:system:Logical:MustBeLogicalScalar',propName);
            case 'PositiveInteger'
                validValue=isscalar(value)&&isnumeric(value)&&isfinite(value)&&...
                (~isenum(value)&&~issparse(value))&&...
                isreal(value)&&value>0.0&&...
                value==floor(value)&&~isnan(value);
                coder.internal.assert(validValue,'MATLAB:system:PositiveInteger:MustBePosIntValuedScalar',propName);
            otherwise
            end
            matlab.system.coder.SystemProp.matlabCodegenNotifyAnyProp(obj,propName,classDeclaredIn,classCalledFrom);
        end

        function matlabCodegenSetAnyProp(obj,propName,value,classDeclaredIn,classCalledFrom)
            coder.extrinsic('matlab.system.coder.SystemProp.isNontunableProp');
            coder.extrinsic('matlab.system.coder.SystemProp.convertTextToEnumMember');
            coder.extrinsic('matlab.system.coder.SystemProp.convertNumberToEnumMember');
            coder.extrinsic('matlab.system.coder.SystemProp.isDynamicEnumeration');

            if(strcmp(propName,'matlabCodegenIsDeleted'))
                coder.internal.setprop(obj,propName,value,classDeclaredIn);
                return;
            end


            propType=eml_const(feval(...
            'matlab.system.getPropertyTypeForCodegen',classDeclaredIn,propName));

            switch propType
            case 'StringSet'

                matlab.system.coder.SystemProp.matlabCodegenNotifyAnyProp(obj,propName,classDeclaredIn,classCalledFrom);
                coder.internal.assert(ischar(value)||isstring(value),'MATLAB:system:StringSet:InvalidAssignedType',propName);
                enumSet=eml_const(feval(...
                'matlab.system.getStringSetForCodegen',classDeclaredIn,propName));

                if eml_is_const(value)

                    coder.internal.assert(strlength(value)<=size(enumSet,2),...
                    'MATLAB:system:invalidSetPropertyValueConst',value,propName);
                else
                    coder.internal.assert(strlength(value)<=size(enumSet,2),...
                    'MATLAB:system:invalidSetPropertyValue',propName);
                end
                validValue=false;
                numSpaces=size(enumSet,2)-numel(char(value));
                valueWithSpace=[char(value),repmat(' ',1,numSpaces)];

                isNontunableProp=coder.internal.const(...
                matlab.system.coder.SystemProp.isNontunableProp(classDeclaredIn,propName));

                if~eml_is_const(value)&&isNontunableProp




                    coder.internal.setprop(obj,propName,value,classDeclaredIn);
                else
                    for i=coder.unroll(1:size(enumSet,1))
                        if strcmpi(valueWithSpace,enumSet(i,:))
                            validValue=true;
                            correctedValue=enumSet(i,1:end-numSpaces);
                            coder.internal.setprop(obj,propName,correctedValue,classDeclaredIn);
                            break;
                        end
                    end
                end
                if eml_is_const(value)

                    coder.internal.assert(validValue,...
                    'MATLAB:system:invalidSetPropertyValueConst',value,propName);
                else
                    coder.internal.assert(validValue,...
                    'MATLAB:system:invalidSetPropertyValue',propName);
                end
            case 'CustomizedEnumeration'

                matlab.system.coder.SystemProp.matlabCodegenNotifyAnyProp(obj,propName,classDeclaredIn,classCalledFrom);

                isDynamic=coder.internal.const(...
                matlab.system.coder.SystemProp.isDynamicEnumeration(classDeclaredIn,propName));

                if(ischar(value)&&isrow(value))||isstring(value)


                    correctedValue=coder.internal.const(...
                    matlab.system.coder.SystemProp.convertTextToEnumMember(classDeclaredIn,propName,value));
                elseif isDynamic&&isnumeric(value)&&isscalar(value)
                    correctedValue=coder.internal.const(...
                    matlab.system.coder.SystemProp.convertNumberToEnumMember(classDeclaredIn,propName,value));
                else
                    correctedValue=value;
                end

                if isDynamic
                    isValidValue=coder.internal.const(...
                    matlab.system.coder.SystemProp.isValidValueForDynamicEnumeration(obj,propName,correctedValue));

                    if isenum(value)
                        errorValue=char(value);
                    elseif isnumeric(value)&&isscalar(value)
                        errorValue=int2str(value);
                    else
                        errorValue=value;
                    end
                    coder.internal.assert(isValidValue,...
                    'MATLAB:system:Enumeration:InvalidEnumerationSetCodegen',errorValue,propName,class(obj));
                end

                coder.internal.setprop(obj,propName,correctedValue,classDeclaredIn);

            otherwise

                matlab.system.coder.SystemProp.matlabCodegenValidateAnyProp(obj,propName,value,classDeclaredIn,classCalledFrom);
                coder.internal.setprop(obj,propName,logical(value),classDeclaredIn);
            end
        end

        function v=isSubClassOf(classA,classB)

            v=meta.class.fromName(classA)<=meta.class.fromName(classB);
        end

        function validValue=isValidValueForDynamicEnumeration(obj,propName,value)
            coder.extrinsic('matlab.system.coder.SystemProp.getEnumerationValues');
            controllingProps=coder.internal.const(matlab.system.coder.SystemProp.getPropertiesAffectingEnumeration(obj,propName));
            enumSet=coder.internal.const(matlab.system.coder.SystemProp.getEnumerationValues(class(obj),propName,controllingProps));
            validValue=false;
            for i=coder.unroll(1:numel(enumSet))
                if strcmp(char(value),enumSet{i})
                    validValue=true;
                    break;
                end
            end
        end

        function props=getPropertiesAffectingEnumeration(obj,propName)
            coder.extrinsic('matlab.system.coder.SystemProp.getPropertyNamesAffectingEnumeration');
            propNames=coder.internal.const(matlab.system.coder.SystemProp.getPropertyNamesAffectingEnumeration(class(obj),propName));

            for n=coder.unroll(1:numel(propNames))
                props.(propNames{n})=obj.(propNames{n});
            end
        end

        function propNames=getPropertyNamesAffectingEnumeration(className,propName)
            enumClass=getEnumClassName(className,propName);
            fcn=str2func([enumClass,'.propertiesAffectingVisibility']);
            propNames=cellstr(fcn());
        end

        function enumText=getEnumerationValues(className,propName,controllingValues)
            enumClass=getEnumClassName(className,propName);
            fcn=str2func([enumClass,'.activeMembers']);
            activeMembers=fcn(controllingValues);
            enumText=cell(size(activeMembers));
            for n=1:numel(activeMembers)
                enumText{n}=char(activeMembers(n));
            end
        end

        function flag=isDynamicEnumeration(className,propName)
            mc=meta.class.fromName(className);
            mp=findobj(mc.PropertyList,'-depth',0,'Name',propName);
            flag=mp.DynamicEnumeration;
        end

        function correctedValue=convertTextToEnumMember(className,propName,value)



            correctedValue=value;

            metaClass=meta.class.fromName(className);
            metaProp=findobj(metaClass.PropertyList,'-depth',0,'Name',propName);
            enumMetaClass=metaProp.Validation.Class;


            options=cellstr(matlab.system.internal.getEnumerationCustomStrings(metaProp));

            if~isempty(options)
                matchIdx=find(strcmp(options,char(value)),1);
                if~isempty(matchIdx)
                    enumValues=enumeration(enumMetaClass.Name);
                    correctedValue=enumValues(matchIdx);
                    return;
                end
            end


            [enumValues,enumNames]=enumeration(enumMetaClass.Name);
            matchIdx=find(strcmp(enumNames,char(value)),1);
            if~isempty(matchIdx)
                correctedValue=enumValues(matchIdx);
            end
        end

        function correctedValue=convertNumberToEnumMember(className,propName,value)

            mc=meta.class.fromName(className);
            mp=findobj(mc.PropertyList,'-depth',0,'Name',propName);
            enumClass=mp.Validation.Class;

            correctedValue=value;

            isInt=false;
            for n=1:numel(enumClass.SuperclassList)
                isInt=any(enumClass.SuperclassList(n).Name==["int8","uint8","int16","uint16","int32"]);
                if isInt
                    break;
                end
            end

            if~isInt
                return
            end

            enumMembers=enumeration(enumClass.Name);

            matchIdx=find(double(value)==double(enumMembers),1);
            if~isempty(matchIdx)
                correctedValue=enumMembers(matchIdx);
            end
        end
    end
end

function name=getEnumClassName(className,propName)
    mc=meta.class.fromName(className);
    mp=findobj(mc.PropertyList,'-depth',0,'Name',propName);
    name=mp.Validation.Class.Name;
end
