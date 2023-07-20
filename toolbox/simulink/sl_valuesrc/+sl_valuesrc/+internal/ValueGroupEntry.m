classdef ValueGroupEntry<sl_valuesrc.internal.ValueEntry





    properties(Access=private)
    end


    methods(Static,Access=public)
    end


    methods(Access=public)
        function thisObj=ValueGroupEntry(srcObj,defObj,controllerObj,parentObj)
            thisObj@sl_valuesrc.internal.ValueEntry(srcObj,defObj,controllerObj,parentObj);
        end

        function readonly=isReadonlyProperty(thisObj,propName)
            if isequal(propName,'Default Value')
                readonly=true;
            else
                readonly=true;
            end
        end

        function propVal=getPropValue(thisObj,propName)
            switch propName
            case 'Default Value'
                propVal=thisObj.getDefaultValue();
            case 'Effective Value'
                propVal=thisObj.mControllerObj.getEffectiveValue(thisObj.mSrcObj);
                if~ischar(propVal)
                    propVal=DAStudio.MxStringConversion.convertToString(propVal);
                end
            case 'Overlay'
                [propVal,~]=getOverlayDetails(thisObj);
            otherwise
                propVal=getPropValue@sl_valuesrc.internal.ValueEntry(thisObj,propName);
            end
        end

        function getPropertyStyle(thisObj,propName,propertyStyle)
            if isequal(propName,'Overlay')
                [~,filename]=getOverlayDetails(thisObj);
                if~isempty(filename)
                    [path,name,ext]=fileparts(filename);
                    filedisp=['(',name,ext,')'];
                    propertyStyle.WidgetInfo=struct('Type','label','Text',filedisp,'Location','right');
                end
            end
            if isequal(propName,'Overlay')||isequal(propName,'Effective Value')
                try
                    if~isempty(thisObj.mParentObj)&&~(thisObj.mParentObj.getActive())
                        propertyStyle.ForegroundColor=[.5,.5,.5];
                    end
                catch
                end
            end
        end

        function setPropValue(thisObj,propName,value)
            if isequal(propName,'Default Value')
                thisObj.mSrcObj.setValue(value);
            end
        end

        function remove(thisObj)
            thisObj.mSrcObj.destroy();
        end

        function dlgStruct=getDialogSchema(thisObj,arg1)
            dlgStruct=[];
            obj=thisObj.mControllerObj.getDefinitionObject(thisObj.mSrcObj);
            if~isempty(obj)
                try
                    dlgStruct=obj.getDialogSchema(arg1);


                    objGrp.Name='';
                    objGrp.Type='panel';
                    objGrp.Items=dlgStruct.Items;
                    if isfield(dlgStruct,'LayoutGrid')
                        objGrp.LayoutGrid=dlgStruct.LayoutGrid;
                    end
                    if isfield(dlgStruct,'RowStretch')
                        objGrp.RowStretch=dlgStruct.RowStretch;
                    end
                    if isfield(dlgStruct,'ColStretch')
                        objGrp.ColStretch=dlgStruct.ColStretch;
                    end
                    objGrp.RowSpan=[1,1];
                    objGrp.ColSpan=[1,2];

                    [overlayName,overlayFile]=getOverlayDetails(thisObj);

                    nameLbl.Name=message('sl_valuesrc:messages:NameLabel').getString;
                    nameLbl.Type='text';
                    nameLbl.RowSpan=[1,1];
                    nameLbl.ColSpan=[1,1];
                    nameFld.Name=overlayName;
                    nameFld.Tag='name';
                    nameFld.Type='text';
                    nameFld.RowSpan=[1,1];
                    nameFld.ColSpan=[2,2];

                    [path,name,ext]=fileparts(overlayFile);
                    filedisp=[name,ext];

                    fileLbl.Name=message('sl_valuesrc:messages:FileLabel').getString;
                    fileLbl.Type='text';
                    fileLbl.RowSpan=[2,2];
                    fileLbl.ColSpan=[1,1];
                    fileFld.Name=filedisp;
                    fileFld.Tag='file';
                    fileFld.Type='text';
                    fileFld.RowSpan=[2,2];
                    fileFld.ColSpan=[2,2];

                    metaGrp.Name=message('sl_valuesrc:messages:OverlayLabel').getString;
                    metaGrp.Type='group';
                    metaGrp.LayoutGrid=[2,2];
                    metaGrp.ColStretch=[0,1];
                    metaGrp.RowSpan=[2,2];
                    metaGrp.ColSpan=[1,2];
                    metaGrp.Items={nameLbl,nameFld,fileLbl,fileFld};
                    if isempty(overlayFile)
                        metaGrp.Visible=false;
                    end

                    dlgStruct.Items={objGrp,metaGrp};
                    dlgStruct.LayoutGrid=[2,2];
                    dlgStruct.ColStretch=[0,0];
                    dlgStruct.RowStretch=[1,0];

                    dlgStruct.DisableDialog=true;
                catch ME

                end
            end
        end

        function val=getEffectiveValue(thisObj)
            val=[];
            try
                if~isempty(thisObj.mParentObj)&&thisObj.mParentObj.getActive()
                    val=thisObj.mSrcObj.getValueThrowError();
                end
                if isempty(propVal)
                    val=thisObj.getDefaultValue();
                end
            catch ME
            end
        end

    end


    methods(Access=private)

        function propVal=getDefaultValue(thisObj)
            obj=thisObj.mDefinitionsObj.getDefinitionObj(thisObj.mSrcObj.getName());
            try
                propVal=obj.getValue();

                if~ischar(propVal)
                    propVal=DAStudio.MxStringConversion.convertToString(propVal);
                end
            catch ME
            end
        end

        function[overlayName,overlayFile]=getOverlayDetails(thisObj)
            overlay=[];
            try
                if thisObj.mParentObj.getActive()
                    overlay=thisObj.mSrcObj.getEffectiveOverlayThrowError();
                end
                if isempty(overlay)
                    overlayName='–';
                    overlayFile='';
                else
                    overlayName=overlay.getName();
                    overlayFile=overlay.getSource();
                end
            catch me
                overlayName='–';
                overlayFile='';
            end
        end
    end

end