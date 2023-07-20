function out=makeSupportingFunctionsCodeElems(this,d,out,fcnData)






    userMsg=getString(message('RptgenSL:csl_emlfcn:user'));
    userIdx=strcmp({fcnData.Type},userMsg);
    fcnData=fcnData(userIdx);

    [~,uniqueIdx]=unique({fcnData.Path});
    fcnData=fcnData(uniqueIdx);

    nFcns=numel(fcnData);
    if nFcns<1
        return;
    end

    for fcnIdx=1:nFcns
        fcn=fcnData(fcnIdx);


        elem=d.createElement('emphasis',fcn.Name);
        elem.setAttribute('role','bold');
        elem=d.createElement('para',elem);
        out.appendChild(elem);


        path=strrep(fcn.Path,'$matlabroot$',matlabroot);
        [~,~,ext]=fileparts(path);
        if strcmpi(ext,".mlx")

            mFilePath=strcat(tempname,".m");



            matlab.internal.liveeditor.openAndConvert(char(path),char(mFilePath));

            scriptTxt=fileread(mFilePath);

            delete(mFilePath);
        else

            scriptTxt=fileread(path);
        end


        if this.highlightScriptSyntax
            if rptgen.use_java
                script=com.mathworks.widgets.CodeAsXML.xmlize(java(d),scriptTxt);
            else
                script=rptgen.internal.docbook.CodeAsXML.xmlize(d.Document,scriptTxt);
            end
        else
            script=d.createElement('programlisting',scriptTxt);
        end
        out.appendChild(script);
    end

end