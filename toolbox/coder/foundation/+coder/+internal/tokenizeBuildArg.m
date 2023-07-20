function tokens=tokenizeBuildArg(buildArg)














    tokenRegExp='(((\\ )|\S)+)';
    tokens=regexp(buildArg,tokenRegExp,'tokens');
