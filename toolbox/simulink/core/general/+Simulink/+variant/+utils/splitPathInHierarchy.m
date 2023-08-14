function pathComponents=splitPathInHierarchy(pathInHierarchy)



















    pathComponents=regexp(pathInHierarchy,'(?<!/)/(?!/)','split');
end
