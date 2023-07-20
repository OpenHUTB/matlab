function auxInfoIncludes=modify_buildInfo_for_coder(buildInfo,updateBuildInfoArgs)


    auxInfoIncludes={};
    for i=1:numel(updateBuildInfoArgs)
        if~isempty(updateBuildInfoArgs{i})
            methodName=updateBuildInfoArgs{i}{1};
            if numel(updateBuildInfoArgs{i})>2


                methodArgs=updateBuildInfoArgs{i}(2:end);
            else

                methodArgs=updateBuildInfoArgs{i}{2};
            end
            if isequal(methodName,'addIncludeFiles')
                auxInfoIncludes=[auxInfoIncludes,methodArgs{1}];%#ok<AGROW>
            end
            feval(methodName,buildInfo,methodArgs{:});
        end
    end
end
