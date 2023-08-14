classdef(Abstract)CommonMessageMask<slrealtime.internal.dds.ui.CommonMask






    methods








        function constantBlkInitFcn(obj,constantBlk)%#ok<INUSL>

        end

        function sysobjInitFcn(obj,sysobjBlock)%#ok<INUSL>

        end
    end


    methods









        function topicEdit(obj,block)
            obj.updateSubsystem(block);
        end



        function topicSelect(~,block,getDlgFcn,type)
            try

                if~dig.isProductInstalled('DDS Blockset')
                    error(message('slrealtime:dds:needDDSBlockset'));
                end

                dd=get_param(bdroot(block),'DataDictionary');
                if isempty(dd)
                    error(message('slrealtime:dds:requiredDataDictionary',block));
                end
                try

                    ddConn=Simulink.data.dictionary.open(dd);
                    if~Simulink.DDSDictionary.ModelRegistry.hasDDSPart(ddConn.filepath)
                        error(message('slrealtime:dds:noDDSinDD',dd));
                    end
                catch ex
                    error(message('slrealtime:dds:invalidDD',ex.message));
                end
                msgDlg=feval(getDlgFcn,type,block);
                topic=get_param(block,'topic');
                xmlPath=get_param(block,'xmlPath');
                qos=get_param(block,'qos');
                msgDlg.setExistingValues(topic,xmlPath,qos);
                msgDlg.openDialog(@dialogCloseCallback);
            catch ME



                reportAsError(MSLDiagnostic(ME));
            end

            function dialogCloseCallback(isAcceptedSelection,selectedTopic,selectedXmlPath,selectedQos)
                if isAcceptedSelection
                    set_param(block,'topic',selectedTopic);
                    set_param(block,'xmlPath',selectedXmlPath);
                    set_param(block,'qos',selectedQos);
                end
            end
        end


        function dictionarySelect(~,block,getDlgFcn)
            try
                msgDlg=feval(getDlgFcn,bdroot(block));
                msgDlg.openDialog(@dicDialogCloseCallback);
            catch ME



                reportAsError(MSLDiagnostic(ME));
            end

            function dicDialogCloseCallback(isAcceptedSelection,selectedDictionary)
                if isAcceptedSelection
                    if~isempty(selectedDictionary)
                        set_param(block,'datadict',selectedDictionary);
                        set_param(bdroot(block),'DataDictionary',selectedDictionary);
                    end
                end
            end
        end

        function openDDSLibraryUI(~,modelName)
            try
                [~,~,ddConn]=dds.internal.simulink.Util.isModelAttachedToDDSDictionary(modelName);
                if~isempty(ddConn)
                    dds.internal.simulink.ui.internal.DDSLibraryUI.open(ddConn.filepath);
                end
            catch ME
                reportAsError(MSLDiagnostic(ME));
            end
        end
    end

end

