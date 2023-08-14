classdef Element<handle



    properties(Access=protected)
        mMdl;
        mTree;
        mNode;
        mRefreshChildren;
        mShowActions;
    end

    methods
        function this=Element(mdl,tree,node)
            this.mMdl=mdl;
            this.mTree=tree;
            this.mNode=node;
            this.mRefreshChildren=false;
            this.mShowActions=false;
        end

        function refresh(this)
        end

        function hasSimObj=hasSimObject(this)
            hasSimObj=false;
        end

        function putSimObject(this)
        end

        function setEntryValue(this,newValue)
        end

        function setShowActions(this,showActions)
            this.mShowActions=showActions;
        end

        function showActions=getShowActions(this)
            showActions=this.mShowActions;
        end

        function title=getDialogTitle(this)
            class=this.getClassName();
            name=this.getDisplayLabel();
            if isequal(class,name)
                title=class;
            else
                title=[class,': ',name];
            end
        end

        function tag=getDialogTag(this)
            tag=['DDS',this.getClassName()];
        end

        function className=getClassName(this)
            className='';
            if~isempty(this.mNode)
                try
                    name=class(this.mNode);
                    parsed=split(name,'.');
                    className=parsed{numel(parsed)};
                catch
                end
            end
        end

        function dlgstruct=getDialogSchema(this,arg1)
            dlgstruct.Items={};
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.EmbeddedButtonSet={''};
            dlgstruct.DialogMode='Slim';
            dlgstruct.LayoutGrid=[2,1];
            dlgstruct.DialogTitle='';
            dlgstruct.DialogTag=this.getDialogTag();
            dlgstruct.DialogTitle=this.getDialogTitle();
        end

        function src=getElement(this)
            src=this.mNode;
        end

        function src=getForwardedObject(this)
            src=this.mNode;
        end

        function name=getDisplayLabel(this)
            name='';
            try
                name=this.mNode.getPropertyValue('Name');
            catch
            end
            if isempty(name)
                name=this.getClassName();
            end
        end

        function icon=getDisplayIcon(this)
            path='toolbox/dds/adaptor/+dds/+internal/+simulink/+ui/+internal/resources/';
            objType=this.getClassName();
            icon=[path,objType,'.png'];
        end

        function isValid=isValidProperty(this,propName)
            isValid=true;
            if isempty(propName)
                isValid=false;
                return;
            end
            try
                this.mNode.getPropertyValue(propName);
            catch
                isValid=false;
            end
        end

        function isReadonly=isReadonlyProperty(this,propName)
            isReadonly=false;
            try
                test=this.mNode.getPropertyValue(propName);
                if isempty(test)&&isequal(propName,'Name')

                    isReadonly=true;
                end
            catch
                isReadonly=true;
            end
        end

        function dataType=getPropDataType(this,propName)
            dataType='string';
        end

        function values=getPropAllowedValues(this,propName)
            values='';
        end

        function propVal=getPropDisplayValue(this,propName)

            propVal=this.getPropValue(propName);
        end

        function propVal=getPropValue(this,propName)
            propVal='';
            if isempty(propName)
                return;
            end
            try
                propVal=this.mNode.getPropertyValue(propName);
                if~ischar(propVal)
                    propVal=num2str(propVal);
                end
            catch
                propVal='';
            end
        end

        function setPropValue(this,propName,propVal)
            try
                if~isequal(propName,'Name')||isvarname(propVal)
                    this.mNode.setPropertyValue(propName,propVal);
                end
            catch
            end
        end

        function userData=getUserData(this)
            userData=[];
        end

        function setUserData(this,userData)
        end

        function duplicate(this)
        end

    end


    methods(Access=private)


    end

    methods(Static,Access=public)

        function elementObj=create(ddsMdl,existingList,className,baseName)
            newName=dds.internal.simulink.ui.internal.dds.datamodel.Element.getNewName(existingList,className,baseName);
            elementObj=feval(className,ddsMdl);
            if isprop(elementObj,'Name')
                elementObj.Name=newName;
            end
        end

        function elementObj=duplicateElement(ddsMdl,existingList,node,baseName)
            function destroryTypeMapEntryRef(aNode)
                if isprop(aNode,'Elements')
                    keys=aNode.Elements.keys;
                    for i=1:numel(keys)
                        destroryTypeMapEntryRef(aNode.Elements{keys{i}});
                    end
                end
                if~isempty(aNode.TypeMapEntryRef)
                    aNode.TypeMapEntryRef.destroy();
                end
            end
            name=class(node);
            parsed=split(name,'.');
            className=parsed{numel(parsed)};

            if isempty(baseName)&&isprop(node,'Name')
                baseName=node.Name;
            end
            baseName=[baseName,message('modelexplorer:DAS:NameConflict_Suffix').getString];

            newName=dds.internal.simulink.ui.internal.dds.datamodel.Element.getNewName(existingList,className,baseName);

            jsonSer=mf.zero.io.JSONSerializer;
            jsonStr=jsonSer.serializeToString(node);

            if startsWith(node.MetaClass.mcosName,'dds.datamodel.types')
                jsonParTemp=mf.zero.io.JSONParser;
                jsonParTemp.RemapUuids=1;
                tempObj=jsonParTemp.parseString(jsonStr);
                if~isempty(tempObj.TypeMapEntryRef)
                    destroryTypeMapEntryRef(tempObj);
                end
                jsonStr=jsonSer.serializeToString(tempObj);
            end
            jsonPar=mf.zero.io.JSONParser;
            jsonPar.Model=ddsMdl;
            jsonPar.RemapUuids=1;
            elementObj=jsonPar.parseString(jsonStr);

            if isprop(elementObj,'Name')
                elementObj.Name=newName;
            end
        end

        function newName=getNewName(existingList,className,baseName)
            if isempty(baseName)
                parsed=split(className,'.');
                baseName=parsed{numel(parsed)};
            end
            found=false;
            newName=baseName;
            if~any(ismember(existingList,newName))
                found=true;
            end

            idx=1;
            while~found
                newName=[baseName,num2str(idx)];
                if any(ismember(existingList,newName))
                    idx=idx+1;
                else
                    found=true;
                end
            end
        end

    end
end
