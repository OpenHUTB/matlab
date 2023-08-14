function[filename,userCanceled]=volgetfile(varargin)



    persistent cached_path;


    need_to_initialize_path=isempty(cached_path);
    if need_to_initialize_path
        cached_path='';
    end


    if nargin==0
        filterSpec=createImageFilterSpec();
    else
        filterSpec=varargin{1};
    end

    dialogTitle=getString(message('images:fileGUIUIString:getFileWindowTitle'));

    [fname,pathname,filterindex]=uigetfile(filterSpec,dialogTitle,cached_path);



    userCanceled=(filterindex==0);
    if~userCanceled
        cached_path=pathname;
        filename=fullfile(pathname,fname);
    else
        filename='';
    end


    function filterSpec=createImageFilterSpec()



        [desc,ext]=parseImageFormats();
        nformats=length(desc);
        filterSpec=cell([nformats+2,2]);


        filterSpec{1,2}=getString(message('images:volumeViewerToolgroup:allImageFiles'));
        filterSpec{nformats+2,1}='*.*';
        filterSpec{nformats+2,2}=getString(message('images:volumeViewerToolgroup:allFiles'));

        for i=1:nformats
            thisExtension=ext{i};
            numExtensionVariants=length(thisExtension);
            thisExtensionString=strcat('*.',thisExtension{1});
            for j=2:numExtensionVariants
                thisExtensionString=strcat(thisExtensionString,';*.',thisExtension{j});
            end


            if(i==1)
                filterSpec{1,1}=thisExtensionString;
            else
                filterSpec{1,1}=strcat(thisExtensionString,';',filterSpec{1,1});
            end

            filterSpec{i+1,1}=thisExtensionString;
            filterSpec{i+1,2}=strcat(desc{i},' (',thisExtensionString,')');
        end

        function[desc,ext]=parseImageFormats

            desc={'Analyze 7.5',...
            'Digital Imaging and Communications in Medicine',...
            'Nearly Raw Raster Data',...
            'Neuroimaging Informatics Technology Initiative',...
            'Tagged Image File Format'};

            ext={{'hdr'},{'dcm'},{'nrrd'},{'nii','nii.gz'},{'tif','tiff'}};



