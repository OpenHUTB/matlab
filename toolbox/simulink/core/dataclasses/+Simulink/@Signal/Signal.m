classdef Signal<Simulink.DataObject&matlab.mixin.Heterogeneous&imported.Simulink.MCoreSignal















    properties(PropertyType='logical scalar',Hidden=true,Transient=true,Dependent=true)
        HasCoderInfo;
    end

    methods

        function h=Signal()



            setupCoderInfo(h);
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


            retVal.CoderInfo=copy(obj.CoderInfo);



            retVal.DataType=obj.DataType;



            retVal.Dimensions=obj.Dimensions;


            retVal.DimensionsMode=obj.DimensionsMode;
            retVal.Complexity=obj.Complexity;
            retVal.SampleTime=obj.SampleTime;
            retVal.SamplingMode=obj.SamplingMode;
            retVal.InitialValue=obj.InitialValue;
            retVal.LoggingInfo=copy(obj.LoggingInfo);
        end
    end


    methods(Hidden)

        function slidParam=getSlidParam(obj)
            slidParam=getSlidParam@imported.Simulink.MCoreSignal(obj);
        end


        function dlgStruct=getDialogSchema(obj,name)




            dlgStruct=dataddg(obj,name,'signal');
        end


        function retVal=isValidProperty(obj,propName,varargin)
            retVal=isValidProperty@imported.Simulink.MCoreSignal(obj,propName);
            if~retVal

                retVal=isValidProperty@Simulink.DataObject(obj,propName,varargin{:});
            else
                if(strcmp(propName,'LoggingInfo'))
                    retVal=false;
                end
            end
            if retVal
                isBusType=regexpi(obj.DataType,'^Bus:','match');
                if(~isempty(isBusType)&&strcmp(propName,'Unit'))
                    retVal=false;
                end
            end
        end


        function retVal=isReadonlyProperty(obj,propName)
            retVal=isReadonlyProperty@imported.Simulink.MCoreSignal(obj,propName);
            if retVal

                retVal=isReadonlyProperty@Simulink.DataObject(obj,propName);
            end
        end
    end


    methods(Hidden)


        function retVal=acceptDrop(varargin)
            retVal=acceptDrop@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=areChildrenOrdered(varargin)
            retVal=areChildrenOrdered@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=areDescendentsReadonly(varargin)
            retVal=areDescendentsReadonly@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=canAcceptDrop(varargin)
            retVal=canAcceptDrop@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=canAcceptMouseDrop(varargin)
            retVal=canAcceptMouseDrop@imported.Simulink.MCoreSignal(varargin{:});
        end

        function closeEditor(varargin)
            closeEditor@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=doDropOperation(varargin)
            retVal=doDropOperation@imported.Simulink.MCoreSignal(varargin{:});
        end

        function evalDialogParams(varargin)
            evalDialogParams@imported.Simulink.MCoreSignal(varargin{:});
        end

        function exploreAction(varargin)
            exploreAction@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=getActionIcon(varargin)
            retVal=getActionIcon@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=getBoundObjectName(varargin)
            retVal=getBoundObjectName@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=getCheckableProperty(varargin)
            retVal=getCheckableProperty@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=getChildren(varargin)
            retVal=getChildren@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=getCommonProperties(varargin)
            retVal=getCommonProperties@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=getContext(varargin)
            retVal=getContext@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=getContextMenu(varargin)
            retVal=getContextMenu@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=getCurrentDialogPrompts(varargin)
            retVal=getCurrentDialogPrompts@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=getDialogSource(varargin)
            retVal=getDialogSource@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=getDisplayIcon(varargin)
            retVal=getDisplayIcon@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=getDisplayToRealProperty(varargin)
            retVal=getDisplayToRealProperty@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=getDropOperations(varargin)
            retVal=getDropOperations@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=getHierarchicalChildren(varargin)
            retVal=getHierarchicalChildren@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=getInfoForIncrementalLoading(varargin)
            retVal=getInfoForIncrementalLoading@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=getInstanceProperties(varargin)
            retVal=getInstanceProperties@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=getMimeData(varargin)
            retVal=getMimeData@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=getMimeType(varargin)
            retVal=getMimeType@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=getParent(varargin)
            retVal=getParent@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=indicesToUnload(varargin)
            retVal=indicesToUnload@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=isDragAllowed(varargin)
            retVal=isDragAllowed@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=isDropAllowed(varargin)
            retVal=isDropAllowed@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=isHiddenObject(varargin)
            retVal=isHiddenObject@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=isHierarchical(varargin)
            retVal=isHierarchical@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=isHierarchyBuilding(varargin)
            retVal=isHierarchyBuilding@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=isHierarchyReadonly(varargin)
            retVal=isHierarchyReadonly@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=isHierarchySimulating(varargin)
            retVal=isHierarchySimulating@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=isLibrary(varargin)
            retVal=isLibrary@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=isModelReference(varargin)
            retVal=isModelReference@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=isObserverReference(varargin)
            retVal=isObserverReference@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=isTunableProperty(varargin)
            retVal=isTunableProperty@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=isEditableProperty(varargin)
            retVal=isEditableProperty@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=isLinked(varargin)
            retVal=isLinked@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=isMasked(varargin)
            retVal=isMasked@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=java(varargin)
            retVal=java@Simulink.DataObject(varargin{:});
        end

        function retVal=openEditor(varargin)
            retVal=openEditor@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=propertyHyperlink(varargin)
            retVal=propertyHyperlink@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=rmiGetString(varargin)
            retVal=rmiGetString@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=rmiIsSupported(varargin)
            retVal=rmiIsSupported@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=rmiSetString(varargin)
            retVal=rmiSetString@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=showChildrenInListView(varargin)
            retVal=showChildrenInListView@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=slWorkspaceType(varargin)
            retVal=slWorkspaceType@imported.Simulink.MCoreSignal(varargin{:});
        end

        function retVal=supportsIncrementalLoading(varargin)
            retVal=supportsIncrementalLoading@imported.Simulink.MCoreSignal(varargin{:});
        end

    end


    methods(Hidden,Sealed)

        function retVal=getPropDataType(obj,propName)

            if isSuperclassProperty(obj,propName)

                retVal=getPropDataType@imported.Simulink.MCoreSignal(obj,propName);
            else

                retVal=getPropDataType@Simulink.DataObject(obj,propName);
            end
        end


        function retVal=getPropAllowedValues(obj,propName)


            if isSuperclassProperty(obj,propName)

                retVal=getPropAllowedValues@imported.Simulink.MCoreSignal(obj,propName);
            else

                retVal=getPropAllowedValues@Simulink.DataObject(obj,propName);
            end
        end


        function retVal=getPossibleProperties(obj)
            coreProps=getPossibleProperties@imported.Simulink.MCoreSignal(obj);
            mcosProps=getPossibleProperties@Simulink.DataObject(obj);
            retVal=unique([coreProps;mcosProps]);


            retVal(strcmp(retVal,'LoggingInfo'))=[];

            if(~obj.LoggingInfo.DataLogging)
                retVal(contains(retVal,'LoggingInfo.'))=[];
            end
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

                retVal=getPropValue@imported.Simulink.MCoreSignal(obj,propName);
            else

                retVal=getPropValue@Simulink.DataObject(obj,propName,varargin{:});
            end
        end


        function setPropValue(obj,propName,propVal,varargin)


            setPropValue@Simulink.DataObject(obj,propName,propVal,varargin{:});
        end


        function retVal=hasPropertyActions(obj,propName,contextObj)
            retVal=hasPropertyActions@Simulink.DataObject(obj,propName,contextObj);
        end


        function retVal=getPropertyActions(obj,propName,propVal)
            retVal=getPropertyActions@Simulink.DataObject(obj,propName,propVal);
        end


        function propDiffs=getPropsWithInconsistentValues(thisObj,otherObj)








            ignore={'Description'};
            propDiffs=Simulink.data.getPropsWithInconsistentValues(thisObj,otherObj,ignore);
        end
    end


    methods(Static,Hidden)

        function writeContentsForSaveVars(obj,vs)



            Simulink.DataObject.writeContentsForSaveVars(obj,vs);


            vs.writeProperty('Dimensions',obj.Dimensions);
            vs.writeProperty('DimensionsMode',obj.DimensionsMode);
            vs.writeProperty('Complexity',obj.Complexity);
            vs.writeProperty('SampleTime',obj.SampleTime);


            if(~strcmp(obj.SamplingMode,'auto'))
                vs.writeProperty('SamplingMode',obj.SamplingMode);
            end

            vs.writeProperty('InitialValue',obj.InitialValue);


            if obj.LoggingInfo.DataLogging
                vs.writePropertyContents('LoggingInfo',obj.LoggingInfo);
            end
        end


        function retVal=canConvertFrom(oldObj)

            retVal=isa(oldObj,'Simulink.Signal');
        end
    end


    methods(Sealed,Access=protected)

        function useLocalCustomStorageClasses(obj,pkgName)








            checkCSCPackageName(obj,pkgName);


            obj.replaceRTWInfo(Simulink.CoderInfo(pkgName,'Signal'));
        end
    end


    methods(Sealed)

        function disp(obj)




            if(isscalar(obj)&&...
                obj.LoggingInfo.DataLogging&&...
                ~strcmp(obj.SamplingMode,'auto'))
                builtin('disp',obj);
            else


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


                if(isscalar(obj))
                    if~obj.LoggingInfo.DataLogging
                        out=regexprep(out,' *LoggingInfo:.*?\n','');
                    end

                    if strcmp(obj.SamplingMode,'auto')
                        out=regexprep(out,' *SamplingMode:.*?\n','');
                    end
                else
                    out=regexprep(out,' *LoggingInfo.*?\n','');
                    out=regexprep(out,' *SamplingMode.*?\n','');
                end

                disp(out);
            end

        end
    end

end




function retVal=isSuperclassProperty(obj,propName)

    persistent superclassProperties
    if isempty(superclassProperties)
        hSuper=findclass(findpackage('Simulink'),'MCoreSignal');
        props=get(hSuper.Properties);
        superclassProperties={props.Name}';
    end

    if ismember(propName,superclassProperties)
        retVal=true;
        return;
    end


    if(strncmp(propName,'CoderInfo.',10)||...
        strncmp(propName,'RTWInfo.',8)||...
        strncmp(propName,'LoggingInfo.',12))
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


