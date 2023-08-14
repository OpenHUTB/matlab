classdef(Hidden)Property<handle&matlab.mixin.Heterogeneous




    properties(SetAccess=protected)
        Name;
    end

    properties
        Description;
        TooltipText;
        Alias;
        IsFacade;
        IsGraphical;
        IsObjectDisplayOnly;
        UseClassDefault;
        Default;
        ClassStringSet;
        StaticRange;
        StringSetValues;
LocalizedStringSetValues
StringSetMessageIdentifiers
EnumerationMembers
        PropertyPortPair;
        CustomPresenter;
        CustomPresenterPropertyGroupsArgument;
WidgetType
Row
IsEditableEnumeration
    end

    properties(Hidden,SetAccess={?matlab.system.display.internal.Property,?matlab.system.display.PropertyGroup})
        AttributesSet=false;
        DefaultSet=false;


        IsNontunable=false;
        IsReadOnly;
        IsTransient=false;
        IsDependent=false;
        IsHidden;
        IsRestrictedToBuiltinType(1,1)logical=false
        IsMustBeMember(1,1)logical=false


        IsLogical;
        IsStringLiteral;
        IsStringSet;
        IsLocalizedStringSet=false;
        IsEnumeration=false;
        IsEnumerationDynamic=false;
        EnumerationName=''
        IsCustomizedEnumeration=false;
        IsControllingAnEnumeration=false;
        ControlledPropertyList={}
        IsSystemObject=false;
        IsUserDefinedDescription=false;
    end

    properties(Dependent,Hidden,SetAccess=protected)
        BlockParameterName;
    end

    properties(Access=protected)
        pBlockParameterName='';
    end

    methods
        function v=get.BlockParameterName(obj)
            v=obj.pBlockParameterName;
        end

        function set.Name(obj,v)
            if isstring(v)&&isscalar(v)
                v=char(v);
            end
            validateattributes(v,{'char'},{},'','Name');
            obj.Name=v;
        end

        function set.Description(obj,v)
            if isstring(v)&&isscalar(v)
                v=char(v);
            end
            validateattributes(v,{'char'},{},'','Description');
            obj.Description=v;
        end

        function set.TooltipText(obj,v)
            if isstring(v)&&isscalar(v)
                v=char(v);
            end
            validateattributes(v,{'char'},{},'','TooltipText');
            obj.TooltipText=v;
        end

        function set.Alias(obj,v)
            if isstring(v)&&isscalar(v)
                v=char(v);
            end
            validateattributes(v,{'char'},{},'','Alias');
            obj.Alias=v;
        end

        function set.IsGraphical(obj,v)
            validateattributes(v,{'logical'},{},'','IsGraphical');
            obj.IsGraphical=v;
        end

        function set.IsFacade(obj,v)
            validateattributes(v,{'logical'},{},'','IsFacade');
            obj.IsFacade=v;
        end

        function set.UseClassDefault(obj,v)
            validateattributes(v,{'logical'},{},'','UseClassDefault');
            obj.UseClassDefault=v;
        end

        function set.CustomPresenter(obj,v)
            if isstring(v)&&isscalar(v)
                v=char(v);
            end
            validateattributes(v,{'char'},{},'','CustomPresenter');
            obj.CustomPresenter=v;
        end

        function set.StaticRange(obj,v)
            if~isempty(v)
                validateattributes(v,{'numeric'},{'size',[1,2]},'','StaticRange');
            end
            obj.StaticRange=v;
        end

        function set.WidgetType(obj,v)
            if~isempty(v)
                validateattributes(v,{'matlab.system.display.internal.WidgetType'},...
                {},'','WidgetType');
            end
            obj.WidgetType=v;
        end

        function set.Row(obj,v)
            if~isempty(v)
                validateattributes(v,{'matlab.system.display.internal.Row'},...
                {},'','Row');
            end
            obj.Row=v;
        end

        function set.IsEditableEnumeration(obj,v)
            validateattributes(v,{'logical'},{},'','IsEditableEnumeration');
            obj.IsEditableEnumeration=v;
        end

        function obj=Property(name,varargin)


            p=inputParser;
            p.addParameter('Description','');
            p.addParameter('TooltipText','');
            p.addParameter('Alias','');
            p.addParameter('IsObjectDisplayOnly',false);
            p.addParameter('IsGraphical',true);
            p.addParameter('IsFacade',false);
            p.addParameter('ClassStringSet',matlab.system.display.internal.ClassStringSet.empty);
            p.addParameter('StaticRange',[]);
            p.addParameter('WidgetType','');
            p.addParameter('Row','');
            p.addParameter('IsEditableEnumeration',false);
            p.addParameter('UseClassDefault',true);
            p.addParameter('Default','');
            p.addParameter('IsLogical',false);
            p.addParameter('IsStringSet',false);
            p.addParameter('IsStringLiteral',[]);
            p.addParameter('PropertyPortPair',false);
            p.addParameter('IsReadOnly',false);
            p.addParameter('IsHidden',false);
            p.addParameter('StringSetValues',[]);
            p.addParameter('CustomPresenter','');
            p.addParameter('CustomPresenterPropertyGroupsArgument',[]);
            p.parse(varargin{:});
            results=p.Results;

            if~ismember('Description',p.UsingDefaults)
                obj.IsUserDefinedDescription=true;
            end


            obj.Name=name;
            obj.Alias=results.Alias;
            obj.Description=results.Description;
            obj.TooltipText=results.TooltipText;
            obj.IsObjectDisplayOnly=results.IsObjectDisplayOnly;
            obj.IsGraphical=results.IsGraphical;
            obj.IsFacade=results.IsFacade;
            obj.PropertyPortPair=results.PropertyPortPair;
            obj.ClassStringSet=results.ClassStringSet;
            obj.StaticRange=results.StaticRange;
            obj.WidgetType=results.WidgetType;
            obj.Row=results.Row;
            obj.IsEditableEnumeration=results.IsEditableEnumeration;
            obj.UseClassDefault=results.UseClassDefault;
            obj.Default=results.Default;
            obj.IsLogical=results.IsLogical;
            obj.IsStringSet=results.IsStringSet;
            obj.IsStringLiteral=results.IsStringLiteral;
            obj.IsReadOnly=results.IsReadOnly;
            obj.IsHidden=results.IsHidden;
            if isstring(results.StringSetValues)


                results.StringSetValues=results.StringSetValues.cellstr;
            end
            obj.StringSetValues=results.StringSetValues;
            obj.CustomPresenter=results.CustomPresenter;
            obj.CustomPresenterPropertyGroupsArgument=results.CustomPresenterPropertyGroupsArgument;
            obj.pBlockParameterName=obj.Name;
        end

        function v=isDataTypeProperty(~)
            v=false;
        end
    end

    methods(Hidden)
        function obj=setAttributes(obj,metaProperties)


            if obj.AttributesSet
                return;
            end

            if obj.IsFacade
                obj.UseClassDefault=false;
                obj.IsNontunable=true;
                obj.AttributesSet=true;
                return;
            end

            allPropNames={metaProperties.Name};
            propName=obj.Name;
            metaProp=metaProperties(strcmp(allPropNames,propName));
            isSystemMetaProp=isa(metaProp,'matlab.system.CustomMetaProp');


            if isSystemMetaProp
                obj.IsNontunable=metaProp.Nontunable;
                obj.PropertyPortPair=metaProp.PropertyPortPolicy;
            end
            obj.IsReadOnly=~matlab.system.SystemProp.isPublicSetProp(metaProp);
            obj.IsTransient=metaProp.Transient;
            if metaProp.Dependent&&~metaProp.ShowOnMaskDialog
                obj.IsDependent=true;
            end

            obj.IsRestrictedToBuiltinType=isRestrictedToBuiltinType(metaProp);


            if~isempty(obj.ClassStringSet)||~isempty(obj.CustomPresenter)
                obj.IsSystemObject=true;
            else

                pairedSetValue=[];
                if isSystemMetaProp&&metaProp.ConstrainedSet
                    metaPairedSet=metaProperties(strcmp(allPropNames,[propName,'Set']));
                    pairedSetValue=metaPairedSet.DefaultValue;
                end

                if isSystemMetaProp&&isa(pairedSetValue,'matlab.system.StringSet')
                    obj.IsStringSet=true;
                    if isempty(obj.StringSetValues)
                        strSetVals=getAllowedValues(pairedSetValue);
                        if isstring(strSetVals)


                            strSetVals=strSetVals.cellstr;
                        end
                        obj.StringSetValues=strSetVals;
                    end
                    if isa(pairedSetValue,'matlab.system.internal.MessageCatalogSet')










                        obj.IsLocalizedStringSet=true;
                        obj.LocalizedStringSetValues=obj.StringSetValues;
                        obj.StringSetMessageIdentifiers=obj.StringSetValues;
                        for n=1:numel(obj.StringSetValues)
                            obj.StringSetMessageIdentifiers{n}=getMessageIdentiferFromIndex(pairedSetValue,n);
                            obj.LocalizedStringSetValues{n}=getString(message(obj.StringSetMessageIdentifiers{n}));
                        end
                    end
                elseif isSystemMetaProp&&~isempty(metaProp.MustBeMember)
                    mbm=metaProp.MustBeMember;
                    obj.IsStringSet=true;
                    obj.IsMustBeMember=true;
                    obj.StringSetValues=cellstr(mbm.Values);
                    obj.LocalizedStringSetValues=cellstr(mbm.LocalizedValues);

                    if~isempty(mbm.MessageIDs)
                        obj.IsLocalizedStringSet=true;
                        obj.StringSetMessageIdentifiers=cellstr(mbm.MessageIDs);
                    else
                        obj.IsLocalizedStringSet=false;
                    end
                elseif matlab.system.internal.isRestrictedToScalarEnumeration(metaProp)
                    obj.IsEnumeration=true;

                    obj.EnumerationMembers=enumeration(metaProp.Validation.Class.Name);

                    if isSystemMetaProp

                        values=cellstr(matlab.system.internal.getEnumerationCustomStrings(metaProp));
                        obj.StringSetValues=values(:);

                        if metaProp.EnumerationUsingMessageCatalog
                            obj.IsCustomizedEnumeration=true;
                            obj.IsLocalizedStringSet=true;


                            stringFcn=str2func(metaProp.Validation.Class.Name+".messageIdentifiers");
                            messageIDs=stringFcn();
                            messageIDs=messageIDs(:);

                            obj.LocalizedStringSetValues=cellstr(matlab.system.internal.lookupMessageCatalogEntries(messageIDs,false,'enumeration'));
                            obj.StringSetMessageIdentifiers=cellstr(messageIDs);

                        elseif metaProp.EnumerationUsingDisplayStrings
                            obj.IsCustomizedEnumeration=true;
                        end

                        if metaProp.DynamicEnumeration
                            obj.IsEnumerationDynamic=true;
                            obj.EnumerationName=metaProp.Validation.Class.Name;
                        end
                    end

                    if~obj.IsCustomizedEnumeration


                        enumClassName=metaProp.Validation.Class.Name;
                        [~,enumMemberNames]=enumeration(enumClassName);

                        obj.StringSetValues=enumMemberNames;
                    end

                elseif isSystemMetaProp&&(metaProp.ScalarLogical||metaProp.Logical)
                    obj.IsLogical=true;
                elseif metaProp.HasDefault&&...
                    (ischar(metaProp.DefaultValue)||isstring(metaProp.DefaultValue))&&...
                    isempty(obj.IsStringLiteral)
                    obj.IsStringLiteral=true;
                end
            end

            if isempty(obj.IsStringLiteral)
                obj.IsStringLiteral=false;
            end


            if isSystemMetaProp&&~isempty(metaProp.ControlledDynamicEnumerations)
                obj.IsControllingAnEnumeration=true;
                obj.ControlledPropertyList=metaProp.ControlledDynamicEnumerations;
            end

            if(isprop(metaProp,'IsObjectDisplayOnly'))
                obj.IsObjectDisplayOnly=obj.IsObjectDisplayOnly||metaProp.IsObjectDisplayOnly;
            end

            obj.AttributesSet=true;
        end

        function v=getValue(obj,sysObj)
            if obj.IsFacade




                v=[];
            else
                v=sysObj.(obj.Name);

                if obj.IsEnumeration
                    v=obj.StringSetValues{v==obj.EnumerationMembers};
                end
            end
        end

        function sysObj=setValue(obj,sysObj,v)
            if~obj.IsFacade
                if obj.IsEnumeration
                    if obj.IsCustomizedEnumeration
                        v=obj.EnumerationMembers(strcmp(obj.StringSetValues,v));
                    end

                    if obj.IsEnumerationDynamic
                        try
                            sysObj.(obj.Name)=v;
                        catch e
                            if~strcmp(e.identifier,'MATLAB:system:Enumeration:InvalidEnumerationSet')






                                rethrow(e);
                            end
                        end
                    else
                        sysObj.(obj.Name)=v;
                    end
                else
                    sysObj.(obj.Name)=v;
                end
            end
        end

        function v=isVisible(obj,sysObj)

            if~obj.IsGraphical
                v=false;
            elseif obj.IsFacade

                v=~obj.IsHidden;
            else
                v=~sysObj.isInactiveProperty(obj.Name);
            end
        end

        function v=isActive(obj,sysObj)



            if~obj.IsGraphical
                v=~sysObj.isInactiveProperty(obj.Name);
            else
                v=obj.isVisible(sysObj);
            end
        end

        function v=getCodegenScriptType(obj,sysObj)
            if(obj.IsFacade||sysObj.isInactiveProperty(obj.Name))&&~obj.IsEnumerationDynamic









                v='none';
            elseif obj.IsSystemObject

                v='systemobjectvalue';
            else

                v='normal';
            end
        end

        function addDialogValue(obj,paramValue,builder)






            if isstring(paramValue)&&isscalar(paramValue)
                paramValue=char(paramValue);
            end
            validateattributes(paramValue,{'char'},{});
            paramName=obj.Name;
            if obj.IsSystemObject



                pBuilder=matlab.system.ui.ConstructorBuilder.parse(obj,paramValue);
                if~isempty(pBuilder)
                    paramValue=pBuilder;
                end
                builder.addObjectParameterValue(paramName,paramValue);
            elseif obj.IsLogical
                builder.addLiteralParameterValue(paramName,paramValue);
            elseif obj.IsStringLiteral||obj.IsStringSet
                builder.addStringParameterValue(paramName,paramValue);
            else
                builder.addLiteralParameterValue(paramName,paramValue);
            end
        end

        function addParameterValue(obj,sysObj,builder)







            if strcmp(obj.getCodegenScriptType(sysObj),'none')
                return;
            end


            if obj.IsSystemObject
                objectValue=toConstructorExpression(sysObj.(obj.Name));
                builder.addObjectParameterValue(obj.Name,objectValue);
            elseif isprop(sysObj,obj.Name)
                builder.addLiteralParameterValue(obj.Name,obj.BlockParameterName);
            end
        end

        function addParsedExpression(obj,expression,builder)




            if obj.IsStringSet||obj.IsStringLiteral...
                ||(obj.IsEnumeration&&(ischar(txt)||isStringScalar(txt)))
                expression=eval(expression);
            end
            obj.addDialogValue(expression,builder);
        end

        function setDefault(obj,sysObj)


            if obj.DefaultSet||~obj.UseClassDefault
                obj.DefaultSet=true;
                return;
            end

            propValue=sysObj.(obj.Name);
            if obj.IsLogical


                if obj.PropertyPortPair

                    if isempty(propValue.DefaultValue)||~propValue.DefaultValue
                        obj.Default='off';
                    else
                        obj.Default='on';
                    end
                else
                    if isempty(propValue)||~propValue
                        obj.Default='off';
                    else
                        obj.Default='on';
                    end
                end

            elseif obj.IsStringSet


                if isempty(propValue)
                    obj.Default=obj.StringSetValues{1};
                else
                    obj.Default=char(propValue);
                end
            elseif obj.IsEnumeration

                if isempty(propValue)
                    idx=1;
                else
                    idx=obj.EnumerationMembers==propValue;
                end

                obj.Default=obj.StringSetValues{idx};
            else
                if isstring(propValue)&&isscalar(propValue)
                    propValue=char(propValue);
                end
                if ischar(propValue)


                    obj.Default=propValue;

                elseif any(strcmp(class(propValue),{'double','float','single','int8','uint8','int16','uint16','int32','uint32','int64','uint64'}))


                    if isempty(propValue)
                        obj.Default='[]';
                    else
                        obj.Default=obj.getDefaultExpression(sysObj);
                    end
                else

                    obj.Default=obj.getDefaultExpression(sysObj);
                end
            end
            obj.DefaultSet=true;
        end

        function strValue=getDefaultExpression(obj,sysObj)

            propName=obj.Name;

            mp=findprop(sysObj,propName);
            definingClass=which(mp.DefiningClass.Name);

            isParsed=false;
            actValue=sysObj.(propName);

            if~isempty(definingClass)
                try
                    t=mtree(definingClass,'-file');





                    n=mtfind(t,'String',propName,'Kind','ID');
                    if~isempty(n)
                        valNode=n.Parent.Right.Tree;
                        if~isempty(valNode)
                            strValue=tree2str(valNode);
                            evalValue=eval(strValue);




                            if isa(evalValue,'embedded.fi')
                                return;
                            end




                            if isequaln(evalValue,actValue)&&...
                                isequal(class(evalValue),class(actValue))
                                return;
                            end
                        end
                    end


                    cls=class(sysObj);
                    ind=strfind(cls,'.');
                    if~isempty(ind)
                        cls=cls(ind(end)+1:end);
                    end
                    src=fileread(definingClass);
                    tc=mtfind(t,'Fname.String',cls);
                    if~isempty(tc)
                        tctr=mtree(src(tc.lefttreepos:tc.righttreepos));
                        n=mtfind(tctr,'String',propName,'Kind','FIELD');

                        if~isempty(n)
                            ind=indices(n);
                            for ii=1:length(ind)
                                nc=n.select(ind(ii));
                                if nc.Parent.Parent.iskind('EQUALS')
                                    strValue=tree2str(nc.Parent.Parent.Right);
                                    evalValue=eval(strValue);
                                    if isequaln(evalValue,actValue)&&...
                                        isequal(class(evalValue),class(actValue))
                                        return;
                                    end
                                end
                            end
                        end
                    end


                    tsm=mtfind(t,'Fname.String',['set.',propName]);
                    if~isempty(tsm)
                        tm=mtree(src(tsm.lefttreepos:tsm.righttreepos));
                        n=mtfind(tm,'String',propName,'Kind','FIELD');
                        if~isempty(n)
                            ind=indices(n);
                            for ii=1:length(ind)
                                nc=n.select(ind(ii));
                                if nc.Parent.Parent.iskind('EQUALS')
                                    strValue=tree2str(nc.Parent.Parent.Right);
                                    evalValue=eval(strValue);
                                    if isequaln(evalValue,actValue)&&...
                                        isequal(class(evalValue),class(actValue))
                                        return;
                                    end
                                end
                            end
                        end
                    end



                    tgm=mtfind(t,'Fname.String',['get.',propName]);
                    if~isempty(tgm)
                        outv=src(tgm.Outs.lefttreepos:tgm.Outs.righttreepos);
                        tm=mtree(src(tgm.lefttreepos:tgm.righttreepos));
                        n=mtfind(tm,'String',outv,'Kind','ID');
                        if~isempty(n)
                            ind=indices(n);
                            for ii=2:length(ind)
                                nc=n.select(ind(ii));
                                if nc.Parent.iskind('EQUALS')
                                    strValue=tree2str(nc.Parent.Right);
                                    evalValue=eval(strValue);
                                    if isequaln(evalValue,actValue)&&...
                                        isequal(class(evalValue),class(actValue))
                                        return;
                                    end
                                end
                            end
                        end
                    end


                    evalVal1=eval(strValue);
                    evalVal2=eval(strValue);
                    if~isequaln(evalVal1,evalVal2)&&...
                        isequal(class(evalValue),class(actValue))
                        isParsed=true;
                    end



                catch me %#ok<NASGU>
                    isParsed=false;
                end
                if~isParsed



                    fieldValue=get(sysObj,propName);
                    strValue=matlab.system.internal.toExpression(fieldValue,'Split',false);
                end
            end
        end
    end



    methods(Hidden,Sealed)
        function varargout=findobj(obj,varargin)
            varargout{:}=findobj@handle(obj,varargin{:});
        end
    end
end

function flag=isRestrictedToBuiltinType(metaProperty)
    validation=metaProperty.Validation;

    flag=~isempty(validation);

    if~flag
        return
    end

    validationClass=validation.Class;
    flag=~isempty(validationClass);

    if~flag
        return
    end

    flag=any(strcmp(validationClass.Name,...
    {'double','float','single','int8','uint8','int16','uint16','int32','uint32','int64','uint64'}));
end
