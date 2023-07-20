function dPath=docBlockTempPath(name,check)






    SID=strtok(name,'.');
    try
        docBlockHandle=Simulink.ID.getHandle(SID);
    catch Mex %#ok<*NASGU>


        try
            namePrefix=strtok(name,':');
            load_system(namePrefix);
            docBlockHandle=Simulink.ID.getHandle(SID);
        catch Mex2
            docBlockHandle=[];
        end
    end
    if isempty(docBlockHandle)
        if nargin==1||~check
            warning(message('Slvnv:rmisl:docBlockTempPath:FailedToLocate',name));
        end
        dPath='';
        return;
    else

        try
            mType=get_param(docBlockHandle,'MaskType');
            if isempty(mType)
                warning(message('Slvnv:rmisl:docBlockTempPath:IsNotDocBlock',num2str(docBlockHandle)));
                dPath='';
                return;
            elseif~strcmp(mType,'DocBlock')
                warning(message('Slvnv:rmisl:docBlockTempPath:IsNotDocBlock',mType));
                dPath='';
                return;
            end
        catch Mex
            warning(message('Slvnv:rmisl:docBlockTempPath:IsNotDocBlock',Mex.message));
            dPath='';
            return;
        end
    end

    docBlockObject=get_param(docBlockHandle,'Object');
    docBlockFullName=docBlockObject.getFullName();

    if nargin>1&&check



        word_state=rmi.mdlAdvState('word');
        if word_state==0




            [success,msg]=rmicheck.rmicheckitem_pre('word');
            if success
                hWord=rmicom.wordRpt('init');
            else
                error(message('Slvnv:reqmgt:com_word_check_app:FailedToInit',msg));
            end
        elseif word_state==1

            hWord=rmicom.wordRpt('get');
        else


            error(message('Slvnv:reqmgt:com_word_check_app:ExternalSession'));
        end

    else


        hWord=rmicom.wordApp();
    end



    docblock('edit_document',docBlockFullName);
    hDoc=hWord.ActiveDocument;
    dPath=hDoc.FullName;
    if reqmgt('rmiFeature','UseDotNet')
        dPath=dPath.char;
    end
end
