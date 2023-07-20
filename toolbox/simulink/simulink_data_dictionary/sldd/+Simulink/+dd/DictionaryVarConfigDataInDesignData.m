

classdef DictionaryVarConfigDataInDesignData<handle
    properties
        mVarConfigDataNames='';
        mDDName='';
    end

    methods

        function obj=DictionaryVarConfigDataInDesignData(...
            varConfigDataNames,ddName)
            obj.mVarConfigDataNames=varConfigDataNames;
            obj.mDDName=ddName;
        end

        function schema=getDialogSchema(obj)
            image.Type='image';
            image.Tag='image';
            image.Alignment=3;
            image.RowSpan=[1,1];
            image.ColSpan=[1,1];
            image.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','dialog_info_32.png');

            thereAreVarConfigDataInDesignDataMessage.Name=DAStudio.message('SLDD:sldd:VarConfigDataInDesignData',obj.mDDName);
            thereAreVarConfigDataInDesignDataMessage.WordWrap=true;
            thereAreVarConfigDataInDesignDataMessage.Type='text';
            thereAreVarConfigDataInDesignDataMessage.Tag='DictVarConfigData_GeneralMsg';
            thereAreVarConfigDataInDesignDataMessage.RowSpan=[1,1];
            thereAreVarConfigDataInDesignDataMessage.ColSpan=[2,5];


            typeNamesString='';
            for i=1:length(obj.mVarConfigDataNames)
                typeNamesString=[typeNamesString,obj.mVarConfigDataNames{i},'<br>'];
            end
            varConfigDataList.Text=typeNamesString;
            varConfigDataList.Type='textbrowser';
            varConfigDataList.Editable=false;
            varConfigDataList.Tag='DictVarConfigData_DataList';
            varConfigDataList.RowSpan=[2,2];
            varConfigDataList.ColSpan=[2,5];

            varConfigDataSuggestion.Name=DAStudio.message('SLDD:sldd:VarConfigDataInDesignDataSuggestion');
            varConfigDataSuggestion.WordWrap=true;
            varConfigDataSuggestion.Type='text';
            varConfigDataSuggestion.Tag='DictEnumTypesUsed_MigrationSuggestion';
            varConfigDataSuggestion.RowSpan=[3,3];
            varConfigDataSuggestion.ColSpan=[2,5];

            btnMoveNow.Type='pushbutton';
            btnMoveNow.Tag='DictVarConfigData_MoveNow';
            btnMoveNow.Name=DAStudio.message('SLDD:sldd:VarConfigDataInDesignDataMoveNowButton');
            btnMoveNow.MatlabMethod='Simulink.dd.DictionaryVarConfigDataInDesignData.buttonCB';
            btnMoveNow.MatlabArgs={'%dialog',btnMoveNow.Tag};
            btnMoveNow.RowSpan=[1,1];
            btnMoveNow.ColSpan=[1,1];

            btnMoveLater.Type='pushbutton';
            btnMoveLater.Tag='DictVarConfigData_MoveLater';
            btnMoveLater.Name=DAStudio.message('SLDD:sldd:VarConfigDataInDesignDataMoveLaterButton');
            btnMoveLater.MatlabMethod='Simulink.dd.DictionaryVarConfigDataInDesignData.buttonCB';
            btnMoveLater.MatlabArgs={'%dialog',btnMoveLater.Tag};
            btnMoveLater.RowSpan=[1,1];
            btnMoveLater.ColSpan=[2,2];

            buttons.Type='panel';
            buttons.Tag='buttonPanel';
            buttons.Items={btnMoveNow,btnMoveLater};
            buttons.LayoutGrid=[1,2];
            buttons.RowSpan=[4,4];
            buttons.ColSpan=[4,5];

            schema.DialogTitle=DAStudio.message('SLDD:sldd:VarConfigDataInDesignDataTitle');
            schema.Items={image,thereAreVarConfigDataInDesignDataMessage};

            schema.Items=[schema.Items,varConfigDataList,varConfigDataSuggestion,buttons];

            schema.StandaloneButtonSet={''};

            schema.DialogTag='DictVarConfigData';
            schema.Sticky=true;
            schema.LayoutGrid=[4,5];
            schema.DisplayIcon=fullfile('toolbox','shared','dastudio','resources','DictionaryIcon.png');

            schema.CloseArgs={'%dialog','%closeaction'};
            schema.CloseCallback='Simulink.dd.DictionaryVarConfigDataInDesignData.closeCB';

        end

    end

    methods(Static)

        function buttonCB(dialogH,btnTag)
            if isequal(btnTag,'DictVarConfigData_MoveNow')

                dlgsrc=dialogH.getDialogSource;
                assert(isa(dlgsrc,'Simulink.dd.DictionaryVarConfigDataInDesignData'));
                e=[];
                try
                    ddConn=Simulink.dd.open(dlgsrc.mDDName);
                    for i=1:length(dlgsrc.mVarConfigDataNames)
                        varConfigDataName=dlgsrc.mVarConfigDataNames{i};
                        varConfigDataPath=['Global.',varConfigDataName];

                        varConfigDataObject=ddConn.getEntry(varConfigDataPath);
                        varConfigDataSource=ddConn.getEntryDataSource(varConfigDataPath);

                        if(strcmp(dlgsrc.mDDName,varConfigDataSource))

                            ddConn.insertEntry('Configurations',varConfigDataName,varConfigDataObject);
                        else

                            destConn=Simulink.dd.open(varConfigDataSource);
                            destConn.insertEntry('Configurations',varConfigDataName,varConfigDataObject);
                            destConn.close;
                        end

                        ddConn.deleteEntry(varConfigDataPath);
                    end
                    ddConn.show;
                    ddConn.close;
                catch e
                    errordlg(e.message,DAStudio.message('SLDD:sldd:VarConfigDataInDesignDataMoveError'));
                end
                if isempty(e)
                    msgbox(DAStudio.message('SLDD:sldd:VarConfigDataInDesignDataMoveSuccess',...
                    length(dlgsrc.mVarConfigDataNames)));
                end
            end

            delete(dialogH);

        end

        function closeCB(dialogH,closeAction)
        end

    end

end
