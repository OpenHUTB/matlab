function[sfunctionName,libFileList,srcFileList,objFileList,...
    addIncPaths,addLibPaths,addSrcPaths,...
    preProcDefList,preProcUndefList,unrecognizedInfo]=parseAutoBuildXml(xmlPath)





    modelDescriptionDoc=parseFile(matlab.io.xml.dom.Parser,xmlPath);

    addSrcPaths={};
    srcFileList={};
    libFileList={};
    objFileList={};
    addIncPaths={};
    addLibPaths={};
    preProcDefList={};
    preProcUndefList={};
    unrecognizedInfo={};

    envPathList={};









    sfunctionName=char(modelDescriptionDoc.getElementsByTagName('sfunctionFile').item(0).getTextContent());
    [xmlFolder,~,~]=fileparts(xmlPath);
    defaultPath=fullfile(xmlFolder,'..','src');
    addSrcPaths={addSrcPaths{:},defaultPath};
    sfunctionName=[defaultPath,'/',sfunctionName];


    nums=modelDescriptionDoc.getElementsByTagName('srcFile').getLength();
    for i=0:nums-1
        srcFile=char(modelDescriptionDoc.getElementsByTagName('srcFile').item(i).getTextContent());
        srcFileList={srcFileList{:},srcFile};
    end



    nums=modelDescriptionDoc.getElementsByTagName('srcPath').getLength();
    for i=0:nums-1
        srcPath=char(modelDescriptionDoc.getElementsByTagName('srcPath').item(i).getTextContent());
        addSrcPaths={addSrcPaths{:},srcPath};
    end


    nums=modelDescriptionDoc.getElementsByTagName('libFile').getLength();
    for i=0:nums-1
        libFile=char(modelDescriptionDoc.getElementsByTagName('libFile').item(i).getTextContent());
        libFileList={libFileList{:},libFile};
    end



    nums=modelDescriptionDoc.getElementsByTagName('objFile').getLength();
    for i=0:nums-1
        objFile=char(modelDescriptionDoc.getElementsByTagName('objFile').item(i).getTextContent());
        objFileList={objFileList{:},objFile};
    end



    nums=modelDescriptionDoc.getElementsByTagName('incPath').getLength();
    for i=0:nums-1
        incPath=char(modelDescriptionDoc.getElementsByTagName('incPath').item(i).getTextContent());
        addIncPaths={addIncPaths{:},incPath};
    end
    defaultIncludePath=fullfile(xmlFolder,'..','include');
    addIncPaths={addIncPaths{:},defaultIncludePath};

    nums=modelDescriptionDoc.getElementsByTagName('libPath').getLength();
    for i=0:nums-1
        libPath=char(modelDescriptionDoc.getElementsByTagName('libPath').item(i).getTextContent());
        addLibPaths={addLibPaths{:},libPath};
    end


    nums=modelDescriptionDoc.getElementsByTagName('preProc').getLength();
    for i=0:nums-1
        preProc=char(modelDescriptionDoc.getElementsByTagName('preProc').item(i).getTextContent());
        preProcDefList={preProcDefList{:},preProc};
    end



    nums=modelDescriptionDoc.getElementsByTagName('prePrcU').getLength();
    for i=0:nums-1
        prePrcU=char(modelDescriptionDoc.getElementsByTagName('prePrcU').item(i).getTextContent());
        preProcUndefList={preProcUndefList{:},prePrcU};
    end


    nums=modelDescriptionDoc.getElementsByTagName('unrecognizedItem').getLength();
    for i=0:nums-1
        unrecognizedItem=char(modelDescriptionDoc.getElementsByTagName('unrecognizedItem').item(i).getTextContent());
        unrecognizedInfo={unrecognizedInfo{:},unrecognizedItem};
    end

end

