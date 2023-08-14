function cbe_postclose(me,e)%#ok (callback)




    if~isempty(me)&&~me.getRoot.iseditorbusy
        resume=saveTables(me);
        if isempty(resume)||strcmpi(resume,DAStudio.message('RTW:tfldesigner:CancelText'))
            return;
        else
            delete(me);
        end

    end


    function resume=saveTables(me)

        children=me.getRoot.children;
        resume=DAStudio.message('RTW:tfldesigner:DontSaveText');
        if~isempty(children)
            me.show;
            for i=1:length(children)
                if children(i).isDirty
                    msg=DAStudio.message('RTW:tfldesigner:ExitWithoutSavingMessageDialog',children(i).Name);
                    resume=questdlg(msg,DAStudio.message('RTW:tfldesigner:TflDesignerText'),...
                    DAStudio.message('RTW:tfldesigner:SaveText'),...
                    DAStudio.message('RTW:tfldesigner:DontSaveText'),...
                    DAStudio.message('RTW:tfldesigner:CancelText'),...
                    DAStudio.message('RTW:tfldesigner:SaveText'));
                    if strcmpi(resume,DAStudio.message('RTW:tfldesigner:SaveText'))
                        TflDesigner.setcurrenttreenode(children(i));
                        children(i).okToClose=false;

                        TflDesigner.cba_export;
                        if~children(i).okToClose
                            resume='';
                            break;
                        end
                    elseif strcmpi(resume,DAStudio.message('RTW:tfldesigner:CancelText'))
                        break;
                    end
                end
            end
        end

