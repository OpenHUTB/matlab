function callbackSPCDataTypeWidgets(action,hDialog,tag)














    switch action
    case 'buttonPushEvent'

        updateButtonGrp(hDialog,tag);

    otherwise
        assert(false,'Unknown callback');
    end

    function updateButtonGrp(hDialog,tag)

        [widgetTag,dtTag]=getWidgetAndDataTypeTags(tag);


        if isequal(widgetTag,'UDTShowDataTypeAssistBtn')
            dtTags=hDialog.getUserData(tag);

            nPrms=length(dtTags);

            for i=1:nPrms,
                if~isequal(dtTag,dtTags{i})
                    hideBtnTag=strcat(dtTags{i},'|UDTHideDataTypeAssistBtn');
                    if hDialog.isWidgetValid(hideBtnTag)
                        if(hDialog.isVisible(hideBtnTag))

                            setUDTAssistStatus(hDialog,dtTags{i},false);
                        end
                    end
                end
            end
        end


        Simulink.DataTypePrmWidget.callbackDataTypeWidget('buttonPushEvent',hDialog,tag);



        function setUDTAssistStatus(hDialog,dtTag,status)



            try
                if~isempty(hDialog.getSource.UDTAssistOpen)
                    whichTag=find(strcmp(dtTag,hDialog.getSource.UDTAssistOpen.tags),1);
                    assert(~isempty(whichTag));
                    hDialog.getSource.UDTAssistOpen.status{whichTag}=status;
                end
            catch ME
                if strcmp(ME.identifier,'MATLAB:noSuchMethodOrField')


                else
                    rethrow(ME);
                end
            end



