


function result=impOptFile(reqSetName,docName,subDoc)


    if nargin<3
        subDoc='';
    end

    tempOptionsDir=fullfile(tempdir,'RMI','IMPORT');
    if exist(tempOptionsDir,'dir')~=7
        mkdir(tempOptionsDir);
    end

    [~,reqSetName]=fileparts(reqSetName);


    [~,docName]=fileparts(docName);


    if~isempty(subDoc)
        docName=[docName,'-',subDoc];
    end





    reqSetName=slreq.utils.getMD5hash(reqSetName);



    docName=slreq.utils.getMD5hash(docName);


    optionsFile=[reqSetName,'_',docName,'.mat'];

    result=fullfile(tempOptionsDir,optionsFile);

    if ispc
        result=strrep(result,filesep,'/');
    end
end

