function spec=readSpecification(javaFile,createThumbnail)




    import com.mathworks.toolbox.slproject.project.templates.nocode.EditableTemplateSpecification;

    if nargin<2
        createThumbnail=false;
    end

    import matlab.internal.project.packaging.PackageReader;

    reader=PackageReader(char(javaFile.getAbsolutePath));

    spec=EditableTemplateSpecification(javaFile);
    spec.setName(reader.Title);
    spec.setAuthor(reader.Author);
    spec.setDescription(reader.Description);
    spec.setGroup(reader.Group);
    spec.setType(reader.Type);
    if~isempty(reader.RequiredProducts)
        spec.setRequiredProducts(java.util.Arrays.asList(reader.RequiredProducts));
    end

    if createThumbnail&&reader.HasThumbnail
        thumbnail=[tempname,'.png'];
        reader.extract('Thumbnail',thumbnail);
        spec.setThumbnailFile(java.io.File(thumbnail));
    end

end

