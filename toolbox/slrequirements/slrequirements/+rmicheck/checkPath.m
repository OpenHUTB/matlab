function[success,valid_path]=checkPath(sys,doc,refData)



    success=true;
    valid_path='';


    if any(strcmp(sys,{'other','linktype_rmi_word'}))&&rmisl.isDocBlockPath(doc)
        return;
    end


    try
        linkType=rmi.getLinktype(sys,doc);
        if~linkType.IsFile
            return;
        end
    catch ME %#ok<NASGU>




    end


    if ischar(refData)
        switch exist(refData)%#ok<EXIST>
        case 7
            refSource=refData;
        case 2
            refSource=fileparts(refData);
        case 4

            [myDir,myName]=fileparts(refData);
            if isempty(myDir)
                refSource=fileparts(get_param(myName,'FileName'));
            else
                refSource=myDir;
            end
        otherwise

            refSource=refData;
        end
    else
        refSource=fileparts(get_param(refData,'FileName'));
    end


    docPath=rmisl.locateFile(doc,refSource);
    if isempty(docPath)
        error(message('Slvnv:reqmgt:req_check_path:DocumentNotFound'));
    end





    if ispc


        new_path=rmi.userPreferredDocPath(docPath,refSource);


        if strcmpi(doc,new_path)
            success=true;
            valid_path='';
        elseif any(doc==filesep)




            unified=strrep(doc,filesep,'/');
            if strcmpi(unified,new_path)
                success=true;
                valid_path='';
            else
                success=false;
                valid_path=new_path;
            end
        else
            success=false;
            valid_path=new_path;
        end

    else


        if doc(1)=='/'
            success=false;
            if isempty(refSource)
                valid_path=rmiut.relative_path(docPath,pwd);
            elseif exist(refSource,'dir')==7
                valid_path=rmiut.relative_path(docPath,refSource);
            else
                [refDir,~,~]=fileparts(refSource);
                valid_path=rmiut.relative_path(docPath,refDir);
            end
        else
            success=true;
            valid_path='';
        end

    end

end

