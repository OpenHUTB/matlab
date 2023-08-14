function disp(msg,msgVerbosity,currentVerbosity,printNewLine)








    if nargin<2
        msgVerbosity=1;
    end


    if nargin<3
        currentVerbosity=dnnfpgafeature('Verbose');
    end

    if nargin<4
        printNewLine=true;
    end

    if isa(msg,'message')
        msg=msg.getString;
    end

    if(printNewLine)
        linedelim=newline;
    else
        linedelim='';
    end


    if msgVerbosity<=currentVerbosity




        fprintf('%s',['### ',msg,linedelim]);
    end

end
