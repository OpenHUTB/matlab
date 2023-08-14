function info=getProfilerLineInfo(aCompleteName)



    name=aCompleteName(1:length(aCompleteName)-9);
    try
        info=callstats('function_lines',name);
    catch

        fPath=split(name,'>');
        mtreeObj=mtree(matlab.internal.getCode(fPath{1}));
        if numel(fPath)==1
            info=unique(mtreeObj.lineno);
        else

            fcns=mtreeObj.Fname;
            fcnIdxs=fcns.indices;
            fcnIdx=strcmp(fcns.strings,fPath{end});
            fcnNode=mtreeObj.select(fcnIdxs(fcnIdx));

            while~fcnNode.iskind('FUNCTION')
                fcnNode=fcnNode.Parent;
            end
            info=unique(fcnNode.Tree.lineno);
        end
    end
