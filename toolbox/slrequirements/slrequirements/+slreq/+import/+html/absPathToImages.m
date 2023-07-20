function html=absPathToImages(html,parentFolder,srcType)














    parentDir=strrep(parentFolder,filesep,'/');

    if contains(html,'object data="')
        html=regexprep(html,'object data="(file:///)?',['object data="file:///',parentDir,'/']);

    else
        if any(strcmpi(srcType,{'WORD','EXCEL'}))

            if contains(html,'if !vml')
                html=regexprep(html,'<!\[if !vml\]>',newline);
                html=regexprep(html,'<!\[endif\]>',newline);
            end
            if contains(html,'v:imagedata')
                html=regexprep(html,' v:shapes="\w*"','');
                html=regexprep(html,'<v:imagedata\ssrc="','<img src="');
                html=regexprep(html,'\so:title="[^/]+/>','/>');
            end

        elseif strcmpi(srcType,'DOORS')

            html=regexprep(html,'<a href="(\S+\.png)"',['<a href="file:///',parentDir,'/$1"']);
        end



        html=regexprep(html,'(<img\s[^>]*src=")([^\.])',['$1file:///',parentDir,'/$2']);




        html=regexprep(html,'(<img\s[^>]*src=")\.([^\.])',['$1file:///',parentDir,'$2']);

        parentofparentdir=fileparts(parentDir);


        html=regexprep(html,'(<img\s[^>]*src=")\.\.',['$1file:///',parentofparentdir]);
    end
end

