function doc=chooseSameTypeDoc(req,obj)








    doc='';


    [~,~,ext]=fileparts(req.doc);



    if strcmp(ext,'.rtf')&&rmisl.isDocBlockPath(req.doc)
        try
            hWord=actxGetRunningServer('word.application');
            hDoc=hWord.ActiveDocument;
            if isempty(hDoc)
                errordlg(...
                getString(message('Slvnv:rmi:chooseSameTypeDoc:NoDocblockIsOpen')),...
                getString(message('Slvnv:rmi:chooseSameTypeDoc:ChoosingDocblock')));
                return;
            end
            docPath=hDoc.FullName;
            blkH=docblock('filename2blockhandle',docPath);
            if isempty(blkH)
                errordlg(...
                getString(message('Slvnv:rmi:chooseSameTypeDoc:DocIsNotDocblock')),...
                getString(message('Slvnv:rmi:chooseSameTypeDoc:ChoosingDocblock')));
                return;
            end
            SID=Simulink.ID.getSID(blkH);
            doc=[SID,'.rtf'];
        catch ME %#ok<NASGU>
            errordlg(...
            getString(message('Slvnv:rmi:chooseSameTypeDoc:NoDocblockIsOpen')),...
            getString(message('Slvnv:rmi:chooseSameTypeDoc:ChoosingDocblock')));
        end

    else
        linkType=rmi.linktype_mgr('resolve',req.reqsys,ext);
        if isempty(linkType)||linkType.IsFile||strcmp(linkType.Registration,'linktype_rmi_slreq')
            if isempty(linkType)


                title=getString(message('Slvnv:rmi:chooseSameTypeDoc:LocateTargetDocument'));
                choices={'All Files (*.*)'};
            else
                title=getString(message('Slvnv:rmi:chooseSameTypeDoc:LocateSubstituteDocument'));
                cat_extensions=[linkType.Extensions{:}];
                docExt=regexprep(cat_extensions,'\.',';\*\.');
                docExt=docExt(2:end);
                choices={docExt,[linkType.Label,' (',docExt,')'];...
                '*.*','All Files (*.*)'};
            end
            [filename,pathname]=uigetfile(choices,title);

            if isempty(filename)||~ischar(filename)
                return;
            else
                docPath=[pathname,filename];
            end
            if ischar(obj)
                if rmisl.isSidString(obj)
                    refPath=get_param(strtok(obj,':'),'FileName');
                else
                    refPath=obj;
                end
            else
                refPath=get_param(rmisl.getmodelh(obj),'FileName');
            end
            doc=rmi.userPreferredDocPath(docPath,refPath);
        elseif~isempty(linkType.BrowseFcn)
            doc=strtrim(feval(linkType.BrowseFcn));
        end
    end
end

