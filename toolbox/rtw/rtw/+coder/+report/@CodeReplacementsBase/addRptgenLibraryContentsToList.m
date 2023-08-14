function tflList=addRptgenLibraryContentsToList(obj,aLibrary,tflList)




    import mlreportgen.dom.*;
    aTfl=coder.internal.getTfl(obj.getTargetRegistry,aLibrary);
    if~isempty(aTfl)
        tflName=aTfl.Name;
        thisList=aTfl.TableList;
        cnt=0;
        tflSubList=UnorderedList();
        for idx=1:length(thisList)
            for idx2=1:length(obj.TableInfo)
                if strcmp(obj.TableInfo(idx2).Name,thisList{idx})
                    if~obj.TableInfo(idx2).Inhouse
                        lr=ListItem(thisList{idx});
                        tflSubList.append(lr);
                        cnt=cnt+1;
                    end
                    break
                end
            end
        end
        aList=UnorderedList;
        if cnt>0
            lr=ListItem();
            lr.append(Text(tflName));
            aList.append(lr);
            aList.append(tflSubList);
        else
            lr=ListItem();
            lr.append(tflName);
            aList.append(lr);
        end
        tflList{end+1}=aList;
    end
end
