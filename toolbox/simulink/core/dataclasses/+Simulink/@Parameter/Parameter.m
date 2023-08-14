classdef Parameter<Simulink.DataObject&matlab.mixin.Heterogeneous&imported.Simulink.MCoreParameter















    properties(PropertyType='logical scalar',Hidden=true,Transient=true,Dependent=true)
        HasCoderInfo;
    end

    methods

        function h=Parameter(varargin)



            setupCoderInfo(h);

            try
                switch nargin
                case 0

                case 1
                    h.Value=varargin{1};
                otherwise
                    expErr='MATLAB:maxrhs';
                    error(message(expErr));
                end

            catch err
                throwAsCaller(err);
            end
        end


        function setupCoderInfo(obj)




            useLocalCustomStorageClasses(obj,'Simulink');
        end

        function set.HasCoderInfo(h,value)
            h.CoderInfo.HasCoderInfo=value;
        end

        function value=get.HasCoderInfo(h)
            value=h.CoderInfo.HasCoderInfo;
        end
    end


    methods(Access=protected)

        function retVal=copyElement(obj)













            retVal=copyElement@Simulink.DataObject(obj);


            try
                retVal.CoderInfo=copy(obj.CoderInfo);
            catch
                setupCoderInfo(retVal);
            end


            retVal.Value=obj.Value;



            retVal.DataType=obj.DataType;


            if slfeature('ModelArgumentValueInterface')>1
                retVal.Complexity=obj.Complexity;
            end



            if ischar(obj.Dimensions)||...
                obj.hasUserDefinedDimensions
                retVal.Dimensions=obj.Dimensions;
            end





        end
    end


    methods(Hidden)

        function slidParam=getSlidParam(obj)
            slidParam=getSlidParam@imported.Simulink.MCoreParameter(obj);
        end


        function dlgStruct=getDialogSchema(obj,name)




            dlgStruct=dataddg(obj,name,'data');
        end


        function retVal=isValidProperty(obj,propName,varargin)
            retVal=isValidProperty@imported.Simulink.MCoreParameter(obj,propName);
            if~retVal

                retVal=isValidProperty@Simulink.DataObject(obj,propName,varargin{:});
            end
            if retVal
                isBusType=regexpi(obj.DataType,'^Bus:','match');
                if((~isempty(isBusType)||isstruct(obj.Value))&&strcmp(propName,'Unit'))
                    retVal=false;
                end
            end
        end


        function retVal=isReadonlyProperty(obj,propName)
            retVal=isReadonlyProperty@imported.Simulink.MCoreParameter(obj,propName);
            if retVal

                retVal=isReadonlyProperty@Simulink.DataObject(obj,propName);
            end
        end

    end


    methods(Hidden)


        function retVal=acceptDrop(varargin)
            retVal=acceptDrop@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=areChildrenOrdered(varargin)
            retVal=areChildrenOrdered@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=areDescendentsReadonly(varargin)
            retVal=areDescendentsReadonly@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=canAcceptDrop(varargin)
            retVal=canAcceptDrop@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=canAcceptMouseDrop(varargin)
            retVal=canAcceptMouseDrop@imported.Simulink.MCoreParameter(varargin{:});
        end

        function closeEditor(varargin)
            closeEditor@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=doDropOperation(varargin)
            retVal=doDropOperation@imported.Simulink.MCoreParameter(varargin{:});
        end

        function evalDialogParams(varargin)
            evalDialogParams@imported.Simulink.MCoreParameter(varargin{:});
        end

        function exploreAction(varargin)
            exploreAction@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=getActionIcon(varargin)
            retVal=getActionIcon@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=getBoundObjectName(varargin)
            retVal=getBoundObjectName@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=getMiscDataForCopy(varargin)
            retVal=getMiscDataForCopy@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=getCheckableProperty(varargin)
            retVal=getCheckableProperty@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=getChildren(varargin)
            retVal=getChildren@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=getCommonProperties(varargin)
            retVal=getCommonProperties@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=getContext(varargin)
            retVal=getContext@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=getContextMenu(varargin)
            retVal=getContextMenu@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=getCurrentDialogPrompts(varargin)
            retVal=getCurrentDialogPrompts@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=getDialogSource(varargin)
            retVal=getDialogSource@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=getDisplayIcon(varargin)
            retVal=getDisplayIcon@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=getDisplayToRealProperty(varargin)
            retVal=getDisplayToRealProperty@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=getDropOperations(varargin)
            retVal=getDropOperations@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=getHierarchicalChildren(varargin)
            retVal=getHierarchicalChildren@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=getInfoForIncrementalLoading(varargin)
            retVal=getInfoForIncrementalLoading@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=getInstanceProperties(varargin)
            retVal=getInstanceProperties@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=getMimeData(varargin)
            retVal=getMimeData@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=getMimeType(varargin)
            retVal=getMimeType@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=getParent(varargin)
            retVal=getParent@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=indicesToUnload(varargin)
            retVal=indicesToUnload@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=isDragAllowed(varargin)
            retVal=isDragAllowed@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=isDropAllowed(varargin)
            retVal=isDropAllowed@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=isHiddenObject(varargin)
            retVal=isHiddenObject@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=isHierarchical(varargin)
            retVal=isHierarchical@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=isHierarchyBuilding(varargin)
            retVal=isHierarchyBuilding@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=isHierarchyReadonly(varargin)
            retVal=isHierarchyReadonly@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=isHierarchySimulating(varargin)
            retVal=isHierarchySimulating@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=isLibrary(varargin)
            retVal=isLibrary@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=isModelReference(varargin)
            retVal=isModelReference@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=isObserverReference(varargin)
            retVal=isObserverReference@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=isTunableProperty(varargin)
            retVal=isTunableProperty@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=isEditableProperty(varargin)
            retVal=isEditableProperty@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=isLinked(varargin)
            retVal=isLinked@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=isMasked(varargin)
            retVal=isMasked@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=java(varargin)
            retVal=java@Simulink.DataObject(varargin{:});
        end

        function retVal=openEditor(varargin)
            retVal=openEditor@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=propertyHyperlink(varargin)
            retVal=propertyHyperlink@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=rmiGetString(varargin)
            retVal=rmiGetString@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=rmiIsSupported(varargin)
            retVal=rmiIsSupported@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=rmiSetString(varargin)
            retVal=rmiSetString@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=showChildrenInListView(varargin)
            retVal=showChildrenInListView@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=slWorkspaceType(varargin)
            retVal=slWorkspaceType@imported.Simulink.MCoreParameter(varargin{:});
        end

        function retVal=supportsIncrementalLoading(varargin)
            retVal=supportsIncrementalLoading@imported.Simulink.MCoreParameter(varargin{:});
        end

    end


    methods(Hidden,Sealed)

        function retVal=getPropDataType(obj,propName)

            if isSuperclassProperty(obj,propName)

                retVal=getPropDataType@imported.Simulink.MCoreParameter(obj,propName);
            else

                retVal=getPropDataType@Simulink.DataObject(obj,propName);
            end
        end


        function retVal=getPropAllowedValues(obj,propName)


            if isSuperclassProperty(obj,propName)

                retVal=getPropAllowedValues@imported.Simulink.MCoreParameter(obj,propName);
            else

                retVal=getPropAllowedValues@Simulink.DataObject(obj,propName);
            end
        end


        function retVal=getPossibleProperties(obj)
            coreProps=getPossibleProperties@imported.Simulink.MCoreParameter(obj);

            mcosProps=getPossibleProperties@Simulink.DataObject(obj);




            mcosProps(strcmp(mcosProps,'Value.ExpressionString'))=[];

            retVal=unique([coreProps;mcosProps]);
        end


        function retVal=getDialogProxy(obj)
            retVal=getDialogProxy@Simulink.DataObject(obj);
        end


        function retVal=getForwardedObject(obj)
            retVal=getForwardedObject@Simulink.DataObject(obj);
        end


        function retVal=getDisplayClass(obj)
            retVal=getDisplayClass@Simulink.DataObject(obj);
        end


        function retVal=getDisplayLabel(obj)
            retVal=getDisplayLabel@Simulink.DataObject(obj);
        end


        function retVal=getFullName(obj)
            retVal=getFullName@Simulink.DataObject(obj);
        end


        function retVal=getPropValue(obj,propName,varargin)
            if isSuperclassProperty(obj,propName)

                retVal=getPropValue@imported.Simulink.MCoreParameter(obj,propName,false);

                if(strcmp(propName,'Value')&&isa(obj.Value,'Simulink.data.Expression'))
                    isEditMode=true;
                    retVal=obj.Value.ExpressionString;
                    if(true==isEditMode)
                        if(~isstring(retVal))
                            retVal=string(retVal);
                        end
                        retVal="="+retVal;
                    end
                end
            else

                retVal=getPropValue@Simulink.DataObject(obj,propName,varargin{:});
            end
        end


        function setPropValue(obj,propName,propVal,varargin)



            if(strcmp(propName,'Value'))



                propVal=strtrim(propVal);

                ast=mtree(propVal);
                ids=ast.mtfind('Kind','ID');

                if(~isempty(ids)&&~startsWith(propVal,'=')&&(false==startsWithslexpr(obj,propVal)))
                    propVal=discoverParameterExpressionUsage(propVal);
                    if(strcmp(propVal,'n/a'))
                        return;
                    end
                end

                if(startsWith(propVal,'='))
                    newPropVal=strip(propVal,'left','=');




                    if(true==startsWithslexpr(obj,newPropVal))
                        propVal=newPropVal;
                    else
                        newPropVal=slexpr(newPropVal);
                        eval(['obj.',propName,' = newPropVal;']);
                        return;
                    end
                end
            end

            setPropValue@Simulink.DataObject(obj,propName,propVal,varargin{:});
        end


        function retVal=hasPropertyActions(obj,propName,contextObj)
            retVal=hasPropertyActions@Simulink.DataObject(obj,propName,contextObj);
        end


        function retVal=getPropertyActions(obj,propName,propVal)
            if isequal(propName,'Value')

                newPropVal=strip(propVal,'left');

                if(startsWith(newPropVal,'=')||isa(obj.Value,'Simulink.data.Expression'))

                    retVal.enabled=false;
                    retVal.visible=true;
                    retVal.command='';
                    retVal.label=DAStudio.message('modelexplorer:DAS:LaunchVariableEditorToolTip');
                    return;
                end
            end
            retVal=getPropertyActions@Simulink.DataObject(obj,propName,propVal);
        end


        function propDiffs=getPropsWithInconsistentValues(thisObj,otherObj)








            ignore={'Description'};
            propDiffs=Simulink.data.getPropsWithInconsistentValues(thisObj,otherObj,ignore);
        end


        function retVal=convertFrom(obj,oldObj)














            if(isa(oldObj,'Simulink.Parameter'))
                retVal=convertFrom@Simulink.DataObject(obj,oldObj);
                return;
            end
            retVal=obj;
            retVal.Value=oldObj;
        end


        function retVal=getCompiledBaseNumericTypeName(obj)

            retVal=getCompiledBaseNumericTypeName@imported.Simulink.MCoreParameter(obj);
        end
    end


    methods(Static,Hidden)

        function writeContentsForSaveVars(obj,vs)




            value=obj.Value;
            if isnumeric(value)||islogical(value)||isa(value,'Simulink.data.Expression')

            else

                value=vs.writeToTempVar(value);
            end
            vs.writeProperty('Value',value);


            if slfeature('ModelArgumentValueInterface')>1
                vs.writeProperty('Complexity',obj.Complexity);
            end


            if ischar(obj.Dimensions)
                assert(~obj.hasUserDefinedDimensions,['Parameter object '...
                ,'cannot have both numeric and symbolic dimensions simultaneously.']);
                vs.writeProperty('Dimensions',obj.Dimensions);
            elseif obj.hasUserDefinedDimensions
                assert(~ischar(obj.Dimensions),['Parameter object '...
                ,'cannot have both numeric and symbolic dimensions simultaneously.']);
                vs.writeComment('Set user-defined numeric Dimensions')
                vs.writeProperty('Dimensions',obj.Dimensions);
            end



            Simulink.DataObject.writeContentsForSaveVars(obj,vs);
        end


        function retVal=canConvertFrom(oldObj)

            if isa(oldObj,'Simulink.Parameter')
                retVal=true;
            else
                retVal=imported.Simulink.MCoreParameter.canConvertFrom(oldObj);
            end
        end


    end


    methods(Sealed,Access=protected)

        function useLocalCustomStorageClasses(obj,pkgName)








            checkCSCPackageName(obj,pkgName);


            obj.replaceRTWInfo(Simulink.CoderInfo(pkgName,'Parameter'));
        end
    end


    methods(Sealed,Hidden)
        function retVal=getIsValueExpressionPreserved(obj)
            retVal=obj.getIsValueExpressionPreservedImpl();
        end

        function retVal=getResolvedNumericValue(obj)
            retVal=obj.getResolvedNumericValueImpl();
        end

        function retVal=startsWithslexpr(~,propVal)
            propVal=strtrim(propVal);
            match=regexp(propVal,'^slexpr\s*\(','once');
            if(~isempty(match)&&(1==match))
                retVal=true;
            else
                retVal=false;
            end
        end
    end

    methods(Sealed)
        function disp(obj)



            desktopMode=false;
            try
                desktopMode=desktop('-inuse');
            catch
            end

            if desktopMode
                out=evalc('builtin(''disp'', obj);');
            else
                out=evalc(['featVal = feature(''hotlinks'', 0);',...
                'builtin(''disp'', obj);',...
                'feature(''hotlinks'', featVal);']);
            end

            if(numel(obj)==1)
                if~isempty(obj.Value)&&isa(obj.Value,'Simulink.data.Expression')
                    exprStr=obj.Value.ExpressionString;
                    exprStr="slexpr"+"("+'"'+exprStr+'"'+")";
                    exprStr="Value: "+exprStr+"\n";
                    out=regexprep(out,'Value:.*Simulink.data.Expression]\n',exprStr);
                end
            end

            disp(out);
        end
    end


    methods(Sealed,Access=private)

        function hasUserDefinedDims=hasUserDefinedDimensions(obj)
            hasUserDefinedDims=false;
            if slfeature('ModelArgumentValueInterface')<1
                return;
            end

            if~isempty(obj.Value)
                return;
            end

            if any(obj.Dimensions<1)
                return;
            end

            hasUserDefinedDims=true;
        end
    end
end




function retVal=isSuperclassProperty(obj,propName)

    persistent superclassProperties
    if isempty(superclassProperties)
        hSuper=findclass(findpackage('Simulink'),'MCoreParameter');
        props=get(hSuper.Properties);
        superclassProperties={props.Name}';
    end

    if ismember(propName,superclassProperties)
        retVal=true;
        return;
    end


    if(strncmp(propName,'CoderInfo.',10)||...
        strncmp(propName,'RTWInfo.',8))
        retVal=true;
        return
    end


    if(strcmp(propName,'HeaderFile')&&...
        ~isprop(obj,'HeaderFile'))
        retVal=true;
        return;
    end

    retVal=false;
end


