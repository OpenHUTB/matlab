classdef Const<dds.internal.simulink.ui.internal.dds.datamodel.types.Type



    properties(Access=private)
    end

    methods
        function this=Const(mdl,tree,node)
            this@dds.internal.simulink.ui.internal.dds.datamodel.types.Type(mdl,tree,node);
        end

        function dlgStruct=getDialogSchema(this,arg1)

            dlgStruct=da_mxarray_get_schema(this);
            for i=1:numel(dlgStruct.Items)
                if isfield(dlgStruct.Items{i},'ObjectProperty')&&...
                    isequal(dlgStruct.Items{i}.ObjectProperty,'Value')
                    dlgStruct.Items{i}.Source=this;
                    break;
                end
            end

            curLayout=dlgStruct.LayoutGrid;
            lastRow=curLayout(1)+1;
            fullNameText.Name=DAStudio.message('dds:ui:TypeFullname');
            fullNameText.RowSpan=[lastRow,lastRow];
            fullNameText.ColSpan=[1,1];
            fullNameText.Type='text';
            fullNameText.Tag='TypeFullName_tag';
            fullNameVal.Name=this.mFullNameStr;
            fullNameVal.RowSpan=[lastRow,lastRow];
            fullNameVal.ColSpan=[2,2];
            fullNameVal.Type='text';
            fullNameVal.Tag='TypeFullNameVal_tag';
            shortNameText.Name=DAStudio.message('dds:ui:TypeShortname');
            shortNameText.RowSpan=[lastRow+1,lastRow+1];
            shortNameText.ColSpan=[1,1];
            shortNameText.Type='text';
            shortNameText.Tag='TypeShortName_tag';
            shortNameVal.Name=this.mShortNameStr;
            shortNameVal.RowSpan=[lastRow+1,lastRow+1];
            shortNameVal.ColSpan=[2,2];
            shortNameVal.Type='text';
            shortNameVal.Tag='TypeShortNameVal_tag';
            dlgStruct.Items=[dlgStruct.Items(:)',...
            {fullNameText},{fullNameVal},...
            {shortNameText},{shortNameVal}];
            dlgStruct.RowStretch=[0,0,0,dlgStruct.RowStretch];
            dlgStruct.LayoutGrid=[curLayout(1)+3,curLayout(2)];
        end
        function isValid=isValidProperty(this,propName)
            if ismember(propName,{'Value','Dimensions','Complexity'})
                isValid=true;
            else
                isValid=isValidProperty@dds.internal.simulink.ui.internal.dds.datamodel.types.Type(this,propName);
            end
        end
        function isReadonly=isReadonlyProperty(this,propName)
            if isequal(propName,'Value')
                isReadonly=false;
            elseif ismember(propName,{'DataType','Dimensions','Complexity'})
                isReadonly=true;
            else
                isReadonly=isReadonlyProperty@dds.internal.simulink.ui.internal.dds.datamodel.types.Type(this,propName);
            end
        end

        function propValue=getPropValue(this,propName)
            propValue=[];
            switch propName
            case 'DataType'
                propValue=class(this.mSimObject);
            case 'Value'
                propValue=DAStudio.MxStringConversion.convertToString(this.mSimObject);
            case 'Dimensions'
                tempVal=size(this.mSimObject);
                propValue=strcat('[',strcat(num2str(tempVal),']'));
            case 'Complexity'
                if(isnumeric(this.mSimObject))
                    if(isreal(this.mSimObject))
                        propValue='real';
                    else
                        propValue='complex';
                    end
                else
                    propValue='N/A';
                end
            otherwise
                propValue=getPropValue@dds.internal.simulink.ui.internal.dds.datamodel.types.Type(this,propName);
            end
        end

        function setPropValue(this,propName,propValue)
            if isequal(propName,'Value')
                this.mSimObject=eval(propValue);
            else
                setPropValue@dds.internal.simulink.ui.internal.dds.datamodel.types.Type(this,propName,propValue);
            end
        end
    end


    methods(Static,Access=public)

        function typeObj=create(ddsMdl,~,typeLibNode,name)
            types=dds.internal.simulink.ui.internal.dds.datamodel.types.TypeLibrary.getTypesList(typeLibNode);
            txn=ddsMdl.beginTransaction;
            typeObj=dds.internal.simulink.ui.internal.dds.datamodel.Element.create(ddsMdl,types,'dds.datamodel.types.Const',name);
            typeObj.Type=dds.datamodel.types.Integer(ddsMdl);
            typeObj.ValueStr='0';
            typeLibNode.Elements.add(typeObj);
            dds.internal.simulink.ui.internal.dds.datamodel.types.Type.makeNameUnique(ddsMdl,typeObj);
            dds.internal.simulink.getSimObjectFor(ddsMdl,typeObj);
            txn.commit;
        end

    end



    methods(Access=private)


    end
end
