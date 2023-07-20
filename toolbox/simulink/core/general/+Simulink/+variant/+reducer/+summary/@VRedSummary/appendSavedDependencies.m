function appendSavedDependencies(rpt)




    import mlreportgen.dom.*



    depMsg=message('Simulink:VariantReducer:ReducerDepArtifacts');
    depMsgHead=Heading1(depMsg.getString());
    depMsgHead.Style={Bold,Color('black'),BackgroundColor('white')};
    append(rpt,depMsgHead);




    depContainer=Container();
    depMsg=message('Simulink:VariantReducer:ModifiedDataFiles');
    depHeading=Heading2(depMsg.getString());
    depHeading.Style={Bold,Color('black'),BackgroundColor('white')};
    append(depContainer,depHeading);

    depFiles=rpt.RepData.FileDependencies;


    idAttr=CustomAttribute('id','dependentFiles');
    depContainer.CustomAttributes=idAttr;

    if isempty(depFiles)
        notapplicableMsg=message('Simulink:VariantReducer:NotApplicableFields');
        par=Paragraph(notapplicableMsg.getString());
        append(depContainer,par);
        append(rpt,depContainer);
        return;
    end


    modDataFilesAbstract=message('Simulink:VariantReducer:ModifiedDataFilesAbstract');
    abstract=Paragraph(modDataFilesAbstract.getString());
    abstract.Style={Color('black'),BackgroundColor('white'),FontSize('12pt')};
    idAttr=CustomAttribute('id','savedfilesabstract');
    abstract.CustomAttributes=idAttr;
    append(depContainer,abstract);


    redMATfiles={};
    redDDfiles={};
    redSLXCfiles={};
    copiedDepFiles={};

    for fId=1:numel(depFiles)
        [~,fileName,ext]=fileparts(depFiles{fId});
        switch lower(ext)
        case '.mat'
            redMATfiles{end+1}=[fileName,'.mat'];%#ok<*AGROW>
        case '.sldd'
            redDDfiles{end+1}=[fileName,'.sldd'];
        case '.slxc'
            redSLXCfiles{end+1}=[fileName,'.slxc'];
        otherwise
            copiedDepFiles{end+1}=[fileName,ext];
        end
    end


    appendReducedfiles(depContainer,redMATfiles,'.mat');
    appendReducedfiles(depContainer,redDDfiles,'.sldd');
    appendReducedfiles(depContainer,redSLXCfiles,'.slxc');

    if~isempty(copiedDepFiles)

        depcopyMsg=message('Simulink:VariantReducer:DependentFiles');
        depcopyHeading=Heading2(depcopyMsg.getString());
        depcopyHeading.Style={Bold,Color('black'),BackgroundColor('white')};
        append(depContainer,depcopyHeading);

        depcopyabsMsg=message('Simulink:VariantReducer:DependentFilesAbstract');
        abstract=Paragraph(depcopyabsMsg.getString());
        abstract.Style={Color('black'),BackgroundColor('white'),FontSize('12pt')};
        idAttr=CustomAttribute('id','copiedfileabstract');
        abstract.CustomAttributes=idAttr;
        append(depContainer,abstract);


        depList=UnorderedList(copiedDepFiles);

        idAttr=CustomAttribute('id','copiedFiles');
        depList.CustomAttributes=idAttr;
        append(depContainer,depList);
    end


    append(rpt,depContainer);
end

function appendReducedfiles(depContainer,redfiles,ext)
    if isempty(redfiles)
        return;
    end

    if strcmpi(ext,'.mat')
        heading='Simulink:VariantReducer:ModifiedMATFiles';
        abstract='Simulink:VariantReducer:ModifiedMATFilesReason';
        id='reducedMATfiles';
    elseif strcmpi(ext,'.sldd')
        heading='Simulink:VariantReducer:ModifiedDDFiles';
        abstract='Simulink:VariantReducer:ModifiedDDFilesReason';
        id='reducedDDfiles';
    elseif strcmpi(ext,'.slxc')
        heading='Simulink:VariantReducer:ModifiedSLXCFiles';
        abstract='Simulink:VariantReducer:ModifiedSLXCFilesReason';
        id='reducedslxcfiles';
    else


        return;
    end

    import mlreportgen.dom.*


    matfileMsg=message(heading);
    matfileHeading=Heading3(matfileMsg.getString());
    matfileHeading.Style={Bold,Color('black'),BackgroundColor('white')};
    append(depContainer,matfileHeading);

    abstractMsg=message(abstract);
    abstract=Paragraph(abstractMsg.getString());
    abstract.Style={Color('black'),BackgroundColor('white'),FontSize('12pt')};
    idAttr=CustomAttribute('id','reducedfileabstract');
    abstract.CustomAttributes=idAttr;
    append(depContainer,abstract);


    redFileList=UnorderedList(redfiles);


    idAttr=CustomAttribute('id',id);
    redFileList.CustomAttributes=idAttr;

    append(depContainer,redFileList);
end



