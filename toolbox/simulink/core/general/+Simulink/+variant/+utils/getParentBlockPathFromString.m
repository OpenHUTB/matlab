function[parentPath,name]=getParentBlockPathFromString(blockPath)










    [reverseName,reverseParentPath]=strtok(blockPath(end:-1:1),'/');

    parentPath=reverseParentPath(end:-1:2);

    name=reverseName(end:-1:1);

end