

classdef DictionaryEnumTypeMigration<handle
    properties
        mEnumeratedTypeNames='';
        mEnumTypesSource='';
        mDDName='';
    end

    methods

        function obj=DictionaryEnumTypeMigration(...
            enumTypeNames,enumTypesSource,ddName)
            obj.mEnumeratedTypeNames=enumTypeNames;
            obj.mEnumTypesSource=enumTypesSource;
            obj.mDDName=ddName;
        end

        function schema=getDialogSchema(obj)
            image.Type='image';
            image.Tag='image';
            image.RowSpan=[1,1];
            image.ColSpan=[1,1];
            image.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','dialog_info_32.png');

            thereAreEnumsMessage.Name=DAStudio.message('SLDD:sldd:EnumTypeMigrationEnumsDetected',obj.mEnumTypesSource,obj.mDDName);
            thereAreEnumsMessage.WordWrap=true;
            thereAreEnumsMessage.Type='text';
            thereAreEnumsMessage.Tag='DictEnumTypesUsed_GeneralMsg';
            thereAreEnumsMessage.RowSpan=[1,1];
            thereAreEnumsMessage.ColSpan=[2,5];


            typeNamesString='';
            for i=1:length(obj.mEnumeratedTypeNames)
                typeNamesString=[typeNamesString,obj.mEnumeratedTypeNames{i},'<br>'];
            end
            enumTypeList.Text=typeNamesString;
            enumTypeList.Type='textbrowser';
            enumTypeList.Editable=false;
            enumTypeList.Tag='DictEnumTypesUsed_MigrationList';
            enumTypeList.RowSpan=[2,2];
            enumTypeList.ColSpan=[2,4];

            migrationSuggestion.Name=DAStudio.message('SLDD:sldd:EnumTypeMigrationSuggestion');
            migrationSuggestion.WordWrap=true;
            migrationSuggestion.Type='text';
            migrationSuggestion.Tag='DictEnumTypesUsed_MigrationSuggestion';
            migrationSuggestion.RowSpan=[3,3];
            migrationSuggestion.ColSpan=[2,5];

            migrationLearn.Name=DAStudio.message('SLDD:sldd:EnumTypeMigrationLearnMore');
            migrationLearn.Type='hyperlink';
            migrationLearn.Tag='DictEnumTypesUsed_MigrationLearn';
            migrationLearn.RowSpan=[4,4];
            migrationLearn.ColSpan=[2,2];
            migrationLearn.MatlabMethod='helpview';
            migrationLearn.MatlabArgs={[docroot,'/mapfiles/simulink.map'],'data_dictionary'};

            btnOK.Type='pushbutton';
            btnOK.Tag='Simulink:editor:DialogOK';
            btnOK.Name='OK';
            btnOK.MatlabMethod='Simulink.dd.DictionaryEnumTypeMigration.buttonCB';
            btnOK.MatlabArgs={'%dialog',btnOK.Tag};
            btnOK.RowSpan=[5,5];
            btnOK.ColSpan=[3,3];


            schema.DialogTitle=DAStudio.message('SLDD:sldd:EnumTypeMigrationTitle');

            schema.Items={image,thereAreEnumsMessage};

            schema.Items=[schema.Items,enumTypeList,migrationSuggestion,migrationLearn,btnOK];

            schema.StandaloneButtonSet={''};

            schema.DialogTag='DictEnumTypeMigration';
            schema.Sticky=true;
            schema.LayoutGrid=[4,5];
            schema.DisplayIcon=fullfile('toolbox','shared','dastudio','resources','DictionaryIcon.png');

            schema.CloseArgs={'%dialog','%closeaction'};
            schema.CloseCallback='Simulink.dd.DictionaryEnumTypeMigration.closeCB';

        end

    end

    methods(Static)

        function buttonCB(dialogH,btnTag)
            delete(dialogH);
        end

        function closeCB(dialogH,closeAction)
        end

    end

end
