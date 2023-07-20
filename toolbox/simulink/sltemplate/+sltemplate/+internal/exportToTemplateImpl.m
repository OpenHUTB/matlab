function filename=exportToTemplateImpl(obj,filename,varargin)








    p=inputParser;
    p.StructExpand=true;
    p.addParameter('Group','',@isscalarstring);
    p.addParameter('Title','',@isscalarstring);
    p.addParameter('Author','',@isscalarstring);
    p.addParameter('Description','',@isscalarstring);
    p.addParameter('ThumbnailFile','',@isscalarstring);
    p.parse(varargin{:});
    opts=p.Results;

    function b=isscalarstring(v)
        b=ischar(v)||(isstring(v)&&numel(v)==1);
    end


    if isstring(filename)
        filename=char(filename);
    end


    filename=Simulink.loadsave.resolveNew(filename,'sltx');
    sltemplate.internal.utils.throwIfInvalidFileExtension(filename);

    if i_isLegacyProjectTemplate(obj)

        i_convertLegacyProjectTemplate(obj,filename);

    elseif isscalarstring(obj)||(isnumeric(obj)&&ishandle(obj))






        filename=sltemplate.internal.exportModelToTemplate(obj,filename,varargin{:});

    elseif isa(obj,'matlab.project.Project')||isa(obj,'slproject.ProjectManager')||isa(obj,'matlab.internal.project.api.Project')
        try

            jTmpRoot=java.io.File(obj.RootFolder);



            title=opts.Title;
            if isempty(title)
                title=obj.Name;
            end



            jTemplate=java.io.File(filename);
            jSpec=com.mathworks.toolbox.slproject.project.templates.nocode.EditableTemplateSpecification(jTemplate);
            jSpec.setName(title);
            jSpec.setDescription(opts.Description);
            jSpec.setAuthor(opts.Author);
            jSpec.setGroup(opts.Group);
            if~isempty(opts.ThumbnailFile)
                jSpec.setThumbnailFile(java.io.File(opts.ThumbnailFile));
            end

            i_createProjectTemplate(jTmpRoot,jSpec);

        catch E
            if~isa(E,'matlab.exception.JavaException')
                rethrow(E);
            end


            m=i_to_MException(E.ExceptionObject);
            throw(m);
        end
    else
        DAStudio.error('sltemplate:Export:UnexpectedInput');
    end
end


function iszip=i_isLegacyProjectTemplate(obj)
    iszip=false;
    if ischar(obj)
        [~,~,ext]=fileparts(obj);
        if strcmp(ext,'.zip')
            iszip=true;
        end
    end
end

function i_convertLegacyProjectTemplate(obj,filename)
    try
        tmpRoot=tempname;
        mkdir(tmpRoot);

        jTmpRoot=java.io.File(tmpRoot);
        jZipFile=java.io.File(Simulink.loadsave.resolveFile(obj,'zip'));
        jTemplate=java.io.File(filename);


        extractor=com.mathworks.toolbox.slproject.project.templates.nocode.zip.ZipTemplateExtractor(jZipFile);


        jOldSpec=extractor.getSpecification;
        jNewSpec=com.mathworks.toolbox.slproject.project.templates.nocode.EditableTemplateSpecification(jTemplate,jOldSpec);


        factory=com.mathworks.toolbox.slproject.project.metadata.monolithic.MonolithicManagerFactory;
        cache=com.mathworks.toolbox.slproject.project.FileStatusCache;
        extractor.extract(jTmpRoot,jTmpRoot,factory,cache);


        i_createProjectTemplate(jTmpRoot,jNewSpec);

    catch E
        if~isa(E,'matlab.exception.JavaException')
            rethrow(E);
        end

        m=i_to_MException(E.ExceptionObject);
        throw(m);
    end
end

function i_createProjectTemplate(jRoot,jSpec)
    com.mathworks.toolbox.slproject.project.templates.nocode.sltx.SltxTemplateCreator.createFromMATLAB(jRoot,jSpec);
end

function m=i_to_MException(j)
    c=char(j.getClass.getName);
    id=strrep(c,'.',':');
    if strncmp(id,'com:mathworks:toolbox:',22)
        id=id(23:end);
    end
    m=MException(id,'%s',char(j.getLocalizedMessage));






end


