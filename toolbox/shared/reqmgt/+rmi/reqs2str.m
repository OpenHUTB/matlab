function result=reqs2str(reqs)



    if isempty(reqs)
        result='{}';
        return;
    end


    reqCell=[escapeString({reqs.reqsys}')...
    ,escapeString({reqs.doc}')...
    ,escapeString({reqs.id}')...
    ,util_bool_2_cellstr([reqs.linked])...
    ,escapeString({reqs.description}')...
    ,escapeString({reqs.keywords}')];


    s='{';
    [r,c]=size(reqCell);
    for i=1:r
        for j=1:c
            s=[s,'''',reqCell{i,j},'''',' '];%#ok<AGROW>
        end
        if(i<r),s=[s,'; '];end %#ok<AGROW>
    end
    s=[s,'}'];

    result=s;

    function result=escapeString(inStr)


        result=strrep(inStr,'''','''''');


        result=strrep(result,sprintf('\n'),' ');
        result=strrep(result,sprintf('\r'),'');


        function out=util_bool_2_cellstr(in)
            in=in(:)+1;
            values={'false','true'};
            out=values(in)';

