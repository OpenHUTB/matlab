function annotationInfo=highlightPathToStruct(highlightPath)




    hp=string(highlightPath);
    colonIndices=regexp(hp,"::(?!:)","start");
    annotationPath=hp.extractBefore(colonIndices(end));

    slashIndices=regexp(annotationPath,"(?<!/)/(//)*(?!/)","start");

    annotationInfo=struct(...
    'ParentPath',extractBefore(annotationPath,slashIndices(end)),...
    'Path',annotationPath,...
    'Name',unEscapeSlashes(extractAfter(annotationPath,slashIndices(end))),...
    'SID',hp.extractAfter(colonIndices(end)+1)...
    );
end

function strOut=unEscapeSlashes(strIn)
    strOut=regexprep(strIn,'//','/');
end
