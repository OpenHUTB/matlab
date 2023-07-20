classdef DefaultPISchema<handle




    properties(Access=private)
        DictionaryName(1,:)char;
    end

    methods(Access=public)

        function this=DefaultPISchema(dictionaryName)
            this.DictionaryName=dictionaryName;
        end

        function dlgStruct=getDialogSchema(~)


            descriptionBrowser.Type='textbrowser';
            descriptionBrowser.Text=['<p>',...
            message('interface_dictionary:common:UnselectedPIText').getString(),...
            '</p>'];
            descriptionBrowser.Tag='DescriptionBrowser';

            dlgStruct=struct;
            dlgStruct.DialogTitle='';
            dlgStruct.Items={descriptionBrowser};
            dlgStruct.DialogTag='shared_dict_default_dialog';
            dlgStruct.StandaloneButtonSet={''};
            dlgStruct.EmbeddedButtonSet={''};
            dlgStruct.DialogMode='Slim';
        end
    end


    methods(Hidden)

        function out=getPropertySchema(this)
            out=this;
        end

        function s=getObjectName(this)
            s=this.DictionaryName;
        end

        function tf=supportTabView(~)
            tf=false;
        end

        function mode=rootNodeViewMode(~,rootProp)
            mode='Undefined';
            if isempty(rootProp)||strcmp(rootProp,'InterfaceDictionary:Properties')
                mode='SlimDialogView';
            end
        end

        function subprops=subProperties(~,prop)
            subprops={};
            if isempty(prop)
                subprops{1}='InterfaceDictionary:Properties';
            end
        end

        function showPropertyHelp(~,prop)
            if isempty(prop)
                helpview(fullfile(docroot,'mapfiles','simulink.map'),'autosar_shared_dictionary');
            end
        end

        function label=propertyDisplayLabel(~,prop)
            label=prop;
            if strcmp(prop,'InterfaceDictionary:Properties')
                label=getString(message('interface_dictionary:common:propInspectorTitle'));
            end
        end

        function objType=getObjectType(~)
            objType='';
        end
    end
end


