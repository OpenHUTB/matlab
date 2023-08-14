function output=compareFiles(h,evolution1Id,evolution2Id,fileName)




    currentTree=h.TreeListManager.CurrentSelected;
    output=evolutions.internal.compareFiles(currentTree,evolution1Id,...
    evolution2Id,fileName);
end

