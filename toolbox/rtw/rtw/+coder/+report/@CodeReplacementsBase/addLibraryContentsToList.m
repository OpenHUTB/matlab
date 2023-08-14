function tflList=addLibraryContentsToList(obj,aLibrary,tflList)




    aTfl=coder.internal.getTfl(obj.getTargetRegistry,aLibrary);
    if~isempty(aTfl)
        tflName=aTfl.Name;
        thisList=aTfl.TableList;
        cnt=0;
        tflSubList=Advisor.List;
        tflSubList.setType('Bulleted');
        for idx=1:length(thisList)
            for idx2=1:length(obj.TableInfo)
                if strcmp(obj.TableInfo(idx2).Name,thisList{idx})
                    if~obj.TableInfo(idx2).Inhouse
                        tflSubList.addItem(thisList{idx});
                        cnt=cnt+1;
                    end
                    break
                end
            end
        end
        if cnt>0
            tflList.addItem([Advisor.Text(tflName),tflSubList]);
        else
            tflList.addItem(tflName);
        end
    end
end
