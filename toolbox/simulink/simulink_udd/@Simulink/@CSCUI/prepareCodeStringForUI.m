function multiline=prepareCodeStringForUI(singleline)











    begin=1;


    multiline='';



    firstslashes=regexp(singleline,'\\[n\\]');


    for idx=firstslashes

        multiline=[multiline,singleline(begin:(idx-1))];%#ok

        nextchar=singleline(idx+1);


        if '\'==nextchar
            multiline=[multiline,'\'];%#ok


        elseif 'n'==nextchar
            multiline=[multiline,newline];%#ok
        end


        begin=idx+2;
    end


    multiline=[multiline,singleline(begin:end)];
end


