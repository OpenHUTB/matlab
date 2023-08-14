

classdef DictionaryMigrationResults<handle
    properties
        mMsgGeneral='';
        mMsgSpecifics='';
    end

    methods

        function obj=DictionaryMigrationResults(msgGeneral,msgSpecifics)
            obj.mMsgGeneral=msgGeneral;
            obj.mMsgSpecifics=msgSpecifics;
        end

        function schema=getDialogSchema(obj)
            image.Type='image';
            image.Tag='image';
            image.RowSpan=[1,1];
            image.ColSpan=[1,1];
            if isequal(obj.mMsgGeneral,'SLDD:sldd:MigrationError')
                image.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','warningicon.gif');
            else
                image.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','dialog_info_32.png');
            end

            description.Name=DAStudio.message(obj.mMsgGeneral);
            description.Type='text';
            description.WordWrap=true;
            description.Tag='GeneralMsg';
            description.RowSpan=[1,1];
            description.ColSpan=[2,4];
            description.Alignment=9;

            details.Text=obj.mMsgSpecifics;
            details.Type='textbrowser';
            details.Editable=false;
            details.Tag='SpecificMsg';
            details.RowSpan=[2,2];
            details.ColSpan=[2,4];

            schema.DialogTitle=DAStudio.message('SLDD:sldd:MigrateTitle');
            schema.DialogTag='SLDDMigrateResults';
            schema.StandaloneButtonSet={'OK'};
            schema.Sticky=true;
            schema.LayoutGrid=[2,4];
            schema.Items={image,description};
            if~isempty(details.Text)
                schema.Items=[schema.Items,details];
            end
        end


    end

end
